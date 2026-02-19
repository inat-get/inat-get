# frozen_string_literal: true

require 'is-duration'

require_relative '../../info'

# @api private
class INatGet::Data::Updater

  include IS::Duration

  # @private
  def initialize
    @config = INatGet::App::Setup::config || {}
  end

  # @group Update

  # @overload update! condition
  #   @param [INatGet::Data::DSL::Condition] conditions
  # @overload update! *ids
  #   @param [Array<Integer, String>] ids
  # @return [void]
  def update! *args
    if args.size == 1 && args.first.is_a?(INatGet::Data::DSL::Condition)
      update_by_condition! arg.first
    else
      update_by_ids!(*args)
    end
  end

  # @endgroup

  # @group Descendants Specificators

  # @return [INatGet::Data::Parser]
  def parser() = self.manager.parser

  # @return [INatGet::Data::Manager]
  def manager() = raise NotImplementedError, "Not implemented method 'manager' for abstract class", caller_locations

  # @return [INatGet::Data::Model]
  def model() = self.manager.model

  # @return [INatGet::Data::Helper]
  def helper() = self.manager.helper

  # @return [Symbol]
  def endpoint() = self.manager.endpoint

  # @endgroup

  private

  # @private
  def api
    @api ||= Thread::current[:api]
  end

  # @private
  def update_by_condition! condition
    condition.to_api.each do |request|
      wrap_request request
    end
  end

  # @private
  def update_by_ids! *ids
    interval = parse_duration(@config.dig(:caching, :refs, self.manager.endpoint) || @config.dig(:caching, :refs, :default))
    if interval
      point = Time::now - interval
      fresh = self.model.where(id: ids, cached: (point .. )).select_map(:id)
      ids -= fresh
    end
    ids.each_slice(@config.dig(:api, :pager) || 200) do |slice|
      endpoint = "#{ self.endpoint }/#{ slice.map(&:to_s).join(',') }"
      execute_request(endpoint, {})
    end
  end

  # # @private
  # HARD_LIMIT = 24 * 60 * 60

  # # @private
  # def make_request request
  #   endpoint = request[:endpoint]
  #   query = request[:query]
  #   record = nil
  #   if endpoint == self.endpoint
  #     # ⮴ В противном случае мы запрашиваем конкретные id/sid, которых не нашлось в базе, или нашлись, но недостаточно свежие.
  #     #   Соответственно, смысла в дальнейших проверках, равно как и в сохранении запроса, нет.
  #     query.transform_values! { |v| v.is_a?(Enumerable) ? v.sort : v }
  #     prepared = { endpoint: endpoint, query: query }
  #     json = JSON.generate prepared, sort_keys: true, space: ''
  #     hash = Digest::MD5::hexdigest json
  #     endless_query = query.reject { |k, _| k == :d2 || k == :created_d2 }
  #     endless_prepared = { endpoint: endpoint, query: query }
  #     endless_json = JSON.generate endless_prepared, sort_keys: true, space: ''
  #     endless_hash = Digest::MD5::hexdigest endless_json

  #     fresh_point = Time::now - parse_duration(@config.dig(:update) || 0)

  #     found = false
  #     rq_model = INatGet::Data::Model::Request
  #     rq_model.db.transaction(isolation: :committed) do
  #       record = INatGet::Data::Model::Request.with_pk(hash)
  #       if record
  #         found = true
  #         if record.finished == nil && record.started > (Time::now - HARD_LIMIT)
  #           while record.finished == nil
  #             sleep 0.01
  #             record.reload
  #           end
  #           return :other
  #         end
  #         return :fresh if record.finished > fresh_point
  #         record.update started: Time::now, finished: nil
  #       else
  #         record = rq_model.create hash: hash, endless: endless_hash, query: json, started: Time::now, freshed: now, finished: nil
  #       end
  #     end
  #     updated_since = nil
  #     if found
  #       updated_since = record.started
  #     else
  #       endless_record = rq_model.where(endless: endless_hash).exclude(finished: nil).order(:finished.desc).first
  #       if endless_record
  #         return :fresh if endless_record.finished > fresh_point
  #         if allow_updated_since
  #           saved_json = endless_record.query
  #           saved_data = JSON.parse saved_json, symbolize_names: true
  #           saved_d2 = saved_data.dig :query, :d1
  #           saved_d2 = Time.parse saved_d2 if saved_d2
  #           saved_cd2 = saved_data.dig :query, :created_d2
  #           saved_cd2 = Time.parse saved_cd2 if saved_cd2
  #           updated_since = [ endless_record.started, saved_d2, saved_cd2 ].compact.min
  #         end
  #       end
  #     end
  #     query[:updated_since] = updated_since if allow_updated_since && updated_since
  #     # TO DO: глубокая проверка на охватывающие запросы
  #   end
  #   request = { endpoint: endpoint, query: query }
  #   execute_request request
  #   if endpoint == self.endpoint
  #     record.update finished: Time::now if record
  #     # TO DO: дальнейшие этапы обновления кэша: refresh и recache
  #   end
  # end

  # @private
  def wrap_request request
    endpoint = request[:endpoint]
    query = request[:query]
    # Запрос конкретного набора id — не кэшируем — нет смысла
    return execute_request(endpoint, query) unless endpoint == self.endpoint

    # TODO: Определяем updated_since, если возможно

    # Формируем ключи и данные
    query.transform_values! { |v| v.is_a?(Enumerable) ? v.sort : v }
    rq_json = JSON.generate({ endpoint: endpoint, query: query }, sort_keys: true, space: '')
    rq_hash = Digest::MD5::hexdigest rq_json
    el_query = query.reject { |k, _| k == :d2 || k.to_s.end_with?('_d2') }
    el_json = JSON.generate({ endpoint: endpoint, query: el_query }, sort_keys: true, space: '')
    el_hash = Digest::MD5::hexdigest el_json

    start_point = Time::now
    actual_point = point - parse_duration(@config.dig(:caching, :update))

    # Захватываем requests
    rq_model = INatGet::Data::Model::Request
    record = nil
    found = false
    rq_model.db.transaction(isolation: :committed) do
      record = rq_model.with_pk(rq_hash)
      if record
        while record.busy
          sleep 0.01
          record.reload
        end
        return :fresh if record.finished > actual_point
        record.update busy: true
        found = true
      else
        record = rq_model.create hash: rq_hash, endless: el_hash, endpoint: endpoint, query: rq_json, started: start_point, freshed: start_point, busy: true
        set_request_projects record, query[:project_id] if query[:project_id]
        set_request_places   record, query[:place_id]   if query[:place_id]
        set_request_taxa     record, query[:taxon_id]   if query[:taxon_id]
        set_request_users    record, query[:user_id]    if query[:user_id]
      end
    end

    # Устанавливаем updated_since
    if allow_updated_since?
      updated_since = nil
      if found
        updated_since = record.started
      else
        el_record = rq_model.where(endless: el_hash).order(:started.desc).first
        if el_record
          saved_json = el_record.query
          saved_data = JSON.load saved_json, symbolize_names: false
          dates = saved_data.select { |k, _| k == 'd2' || k.end_with?('_d2') }.values.compact.map { |v| Time.parse(v) rescue nil }.compact
          updated_since = [ el_record.started, *dates ].min
        end
      end
      query[:updated_since] = updated_since if updated_since
    end

    # Выполняем запрос
    result = :empty
    begin
      result = execute_request endpoint, query
    rescue => e
      result = :error
      logger.error e.message
    end

    # Освобождаем requests
    rq_model.db.transaction(isolation: :committed) do
      if result == :done
        record.update busy: false, started: started, finished: Time::now
      else
        record.update busy: false
      end
    end
    
    # TODO: Определяем необходимость этапа refresh
    # TODO:   Этап recache

    result
  end

  # @private
  # Возвращаем :done, если загрузка прошла успешно, :error — в случае ошибки:
  #   от этого будут зависеть изменения в requests при освобождении записи.
  def execute_request endpoint, query
    # TODO: implement
  end

  # @group Descendant Rules

  # @return [Boolean]
  def allow_updated_since?() = false

  # @return [Boolean]
  def allow_id_above?() = false

  # @return [Boolean]
  def allow_locale?() = false

  # @endgroup

  # @private
  def project_pks
    @project_pks ||= INatGet::Data::Model::Request.association_reflection(:projects)[:pks_setter_method]
  end

  # @private
  def place_pks
    @place_pks ||= INatGet::Data::Model::Request.association_reflection(:places)[:pks_setter_method]
  end

  # @private
  def taxon_pks
    @taxon_pks ||= INatGet::Data::Model::Request.association_reflection(:taxa)[:pks_setter_method]
  end

  # @private
  def user_pks
    @user_pks ||= INatGet::Data::Model::Request.association_reflection(:users)[:pks_setter_method]
  end

  # @private
  def set_request_projects record, ids
    record.send project_pks, ids
  end

  # @private
  def set_request_places record, ids
    record.send place_pks, ids
  end

  # @private
  def set_request_taxa record, ids
    record.send taxon_pks, ids
  end

  # @private
  def set_request_users record, ids
    record.send user_pks, ids
  end

end
