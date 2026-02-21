# frozen_string_literal: true

require 'is-duration'

require_relative '../../info'
require_relative '../../utils/json'
require_relative '../../sys/context'

# @api private
class INatGet::Data::Updater

  include IS::Duration
  include INatGet::System::Context

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
      check_shutdown!
      endpoint = "#{ self.endpoint }/#{ slice.map(&:to_s).join(',') }"
      execute_request(endpoint, {})
    end
  end

  HARD_STOP = 2 * 24 * 60 * 60

  # @private
  def wrap_request request
    endpoint = request[:endpoint]
    query = request[:query]
    # Запрос конкретного набора id — не кэшируем — нет смысла
    return execute_request(endpoint, query) unless endpoint == self.endpoint

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
          raise "Too old business" if start_point - record.busy > HARD_STOP
          sleep 0.01
          record.reload
        end
        return :fresh if record.finished > actual_point
        record.update busy: start_point
        found = true
      else
        record = rq_model.create hash: rq_hash, endless: el_hash, endpoint: endpoint, query: rq_json, started: start_point, freshed: start_point, busy: start_point
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
      unless updated_since
        # Попытаемся найти охватывающий запрос (в endless-логике)
        database = rq_model.db
        dataset = rq_model.where(endpoint: endpoint).exclude(finished: nil)
        project_ids = query[:project_id]
        if project_ids
          hashes_by_projects = database[:request_projects].where(project_id: project_ids)
            .group(:request_hash).having { count(project_id) >= project_ids.size }
            .select(:request_hash)
          dataset = dataset.where(hash: hashes_by_projects)
        end
        place_ids = query[:place_id]
        if place_ids
          hashes_by_places = database[:request_places].where(place_id: place_ids)
            .group(:request_hash).having { count(place_id) >= place_ids.size }
            .select(:request_hash)
          dataset = dataset.where(hash: hashes_by_places)
        end
        taxon_ids = query[:taxon_id]
        if taxon_ids
          hashes_by_taxa = database[:request_taxa].where(taxon_id: taxon_ids)
            .group(:request_hash).having { count(taxon_id) >= taxon_ids.size }
            .select(:request_hash)
          dataset = dataset.where(hash: hashes_by_taxa)
        end
        user_ids = query[:user_id]
        if user_ids
          hashes_by_users = database[:request_users].where(user_id: user_ids)
            .group(:request_hash).having { count(user_id) >= user_ids.size }
            .select(:request_hash)
          dataset = dataset.where(hash: hashes_by_users)
        end
        dataset.order(:started.desc).limit(10).each do |rec|
          saved_json = rec.query
          saved_data = JSON.load saved_json, symbolize_names: true
          cover_data = saved_data.reject { |k, _| k == :d2 || k.to_s.end_with?('_d2') }
          cover_data.each do |k, v|
            if k == :d1 || k.to_s.end_with?('_d1')
              cover_data[k] = Time.parse(v) rescue v
            end
          end
          if query_covers?(cover_data, query)
            dates = saved_data.select { |k, _| k == "d2" || k.end_with?("_d2") }.values.compact.map { |v| Time.parse(v) rescue nil }.compact
            updated_since = [rec.started, *dates].min
            break
          end
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
        record.update busy: nil, started: started, finished: Time::now
      else
        record.update busy: nil
      end
    end

    if allow_updated_since?
      fresh_point = start_point - parse_duration(@config.dig(:caching, :refresh, :interval) || 0)
      if record.fresh < fresh_point
        # TODO: этап refresh, к версии 0.9.6
        # TODO: этап recache, к версии 0.9.6
      end
    end
    
    result
  end

  # @private
  # Возвращаем :done, если загрузка прошла успешно, :error — в случае ошибки:
  #   от этого будут зависеть изменения в requests при освобождении записи.
  def execute_request endpoint, query
    if allow_locale?
      locale = @config.dig :api, :locale
      preferred_place = @config.dig :api, :preferred_place
      query[:locale] = locale if locale
      query[:preferred_place_id] = preferred_place if preferred_place
    end
    result = nil
    if allow_id_above?
      query[:order] = 'asc'
      query[:order_by] = 'id'
      id_above = nil
      until result
        query[:id_above] = id_above if id_above
        check_shutdown!
        response = api.get({ endpoint: endpoint, query: query })
        if response[:status] == :error
          result = :error
        else
          self.model.db.transaction do
            check_shutdown! { self.model.db.rollback_on_exit }
            self.parser.parse! response[:results]
          end
          result = :done if response[:total_results] >= response[:per_page]
          id_above = response[:results].last[:id]
        end
      end
    else
      page = nil
      until result
        query[:page] = page if page
        check_shutdown!
        response = api.get({ endpoint: endpoint, query: query })
        if response[:status] == :error
          result = :error
        else
          self.model.db.transaction do
            check_shutdown! { self.model.db.rollback_on_exit }
            self.parser.parse! response[:results]
          end
          processed = response[:page] * response[:per_page]
          result = :done if processed >= response[:total_results]
          page = response[:page] + 1
        end
      end
    end
    result
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

  # @private
  def query_covers? base, actual
    base.each do |key, value|
      av = actual[key]
      return false unless av
      case value
      when Time
        return false if value > av
      when Enumerable
        return false if (av - value).size > 0
      else
        return false if value != av
      end
    end
    true
  end

end
