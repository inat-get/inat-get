# frozen_string_literal: true

require 'is-duration'

require_relative '../../info'
require_relative '../../utils/json'
require_relative '../../sys/context'
require_relative '../models/request'

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
    return nil if @config[:offline]
    if args.size == 1 && args.first.is_a?(INatGet::Data::DSL::Condition)
      update_by_condition! args.first
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
    api_query = condition.api_query
    api_query.each do |request|
      wrap_request request
    end
  end

  # @private
  def update_by_ids! *ids
    return [] if ids.empty?
    interval = parse_duration(@config.dig(:caching, :refs, self.manager.endpoint) || @config.dig(:caching, :refs, :default))
    if interval
      point = (Time::now.to_time - interval).to_time
      # TODO: учесть slugs и uuids
      fresh = self.model.where(id: ids, cached: (point .. )).select_map(:id)
      ids -= fresh
    end
    ids.each_slice(self.slice_size) do |slice|
      check_shutdown!
      endpoint = "#{ self.endpoint }/#{ slice.map(&:to_s).join(',') }"
      execute_request(endpoint, {})
    end
  end

  # @private
  def slice_size
    @config.dig(:api, :pager) || 200
  end

  HARD_STOP = 2 * 24 * 60 * 60

  # @private
  def wrap_request request
    endpoint = request[:endpoint]
    query = request[:query]
    # Запрос конкретного набора id — не кэшируем — нет смысла
    return execute_request(endpoint, query) unless endpoint == self.endpoint

    # Формируем ключи и данные
    query.transform_values! { |v| v.is_a?(Enumerable) && !v.is_a?(::Range) ? v.sort : v }
    rq_json = JSON.generate({ endpoint: endpoint, query: query }, sort_keys: true, space: '')
    rq_hash = Digest::MD5::hexdigest rq_json
    el_query = query.reject { |k, _| k == :d2 || k.to_s.end_with?('_d2') }
    el_json = JSON.generate({ endpoint: endpoint, query: el_query }, sort_keys: true, space: '')
    el_hash = Digest::MD5::hexdigest el_json

    start_point = Time::now
    actual_point = start_point - parse_duration(@config.dig(:caching, :update))

    # Захватываем requests
    rq_model = INatGet::Data::Model::Request
    record = nil
    found = false
    rq_model.db.transaction(isolation: :committed, mode: :immediate) do
      record = rq_model.with_pk(rq_hash)
      if record
        while record.busy
          raise "Too old business" if start_point - record.busy > HARD_STOP
          sleep 0.1
          record.reload
        end
        return :fresh if record.finished > actual_point
        record.update busy: start_point
        found = true
      else
        record = rq_model.create full: rq_hash, endless: el_hash, endpoint: endpoint.to_s, query: rq_json, started: start_point, freshed: start_point, busy: start_point
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
        el_record = rq_model.where(endless: el_hash).exclude(full: rq_hash).order(:started.desc).first
        if el_record
          saved_json = el_record.query
          saved_data = JSON.parse saved_json, symbolize_names: false
          dates = saved_data.select { |k, _| k == 'd2' || k.end_with?('_d2') }.values.compact.map { |v| ::Time.parse(v) rescue nil }.compact
          updated_since = [ el_record.started, *dates ].min
        end
      end
      unless updated_since
        # Попытаемся найти охватывающий запрос (в endless-логике)
        database = rq_model.db
        dataset = rq_model.where(endpoint: endpoint.to_s).exclude(finished: nil)
        project_ids = query[:project_id]
        if project_ids
          hashes_by_projects = database[:request_projects].where(project_id: project_ids)
            .group(:request_hash).having { count(project_id) >= project_ids.size }
            .select(:request_hash)
          cond_by_projects = { full: hashes_by_projects }
          hashes_any_projects = database[:request_projects].select(:request_hash).distinct
          cond_without_projects = Sequel.~(full: hashes_any_projects)
          dataset = dataset.where(Sequel.|(cond_by_projects, cond_without_projects))
        end
        place_ids = query[:place_id]
        if place_ids
          hashes_by_places = database[:request_places].where(place_id: place_ids)
            .group(:request_hash).having { count(place_id) >= place_ids.size }
            .select(:request_hash)
          cond_by_places = { full: hashes_by_places }
          hashes_any_places = database[:request_places].select(:request_hash).distinct
          cond_without_places = Sequel.~(full: hashes_any_places)
          dataset = dataset.where(Sequel.|(cond_by_places, cond_without_places))
        end
        taxon_ids = query[:taxon_id]
        if taxon_ids
          hashes_by_taxa = database[:request_taxa].where(taxon_id: taxon_ids)
            .group(:request_hash).having { count(taxon_id) >= taxon_ids.size }
            .select(:request_hash)
          cond_by_taxa = { full: hashes_by_taxa }
          hashes_any_taxa = database[:request_taxa].select(:request_hash).distinct
          cond_without_taxa = Sequel.~(full: hashes_any_taxa)
          dataset = dataset.where(Sequel.|(cond_by_taxa, cond_without_taxa))
        end
        user_ids = query[:user_id]
        if user_ids
          hashes_by_users = database[:request_users].where(user_id: user_ids)
            .group(:request_hash).having { count(user_id) >= user_ids.size }
            .select(:request_hash)
          cond_by_users = { full: hashes_by_users }
          hashes_any_users = database[:request_users].select(:request_hash).distinct
          cond_without_users = Sequel.~(full: hashes_any_users)
          dataset = dataset.where(Sequel.|(cond_by_users, cond_without_users))
        end
        dataset.order(:started.desc).limit(10).each do |rec|
          saved_json = rec.query
          saved_data = JSON.parse(saved_json, symbolize_names: true)[:query]
          cover_data = saved_data.reject { |k, _| k == :d2 || k.to_s.end_with?('_d2') }
          cover_data.each do |k, v|
            if k == :d1 || k.to_s.end_with?('_d1')
              cover_data[k] = ::Time.parse(v) rescue v
            end
          end
          if query_covers?(cover_data, query)
            dates = saved_data.select { |k, _| k == "d2" || k.end_with?("_d2") }.values.compact.map { |v| ::Time.parse(v) rescue nil }.compact
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
    rq_model.db.transaction(isolation: :committed, mode: :immediate) do
      if result == :done
        record.update busy: nil, started: start_point, finished: ::Time::now
      else
        record.update busy: nil
      end
    end

    if allow_updated_since?
      fresh_point = start_point - parse_duration(@config.dig(:caching, :refresh, :interval) || 0)
      if record.freshed < fresh_point
        # TODO: этап refresh, к версии 0.9.6
        # TODO: этап recache, к версии 0.9.6
      end
    end
    
    result
  end

  # @private
  def console
    @console ||= Thread::current[:console]
  end

  # @private
  # Возвращаем :done, если загрузка прошла успешно, :error — в случае ошибки:
  #   от этого будут зависеть изменения в requests при освобождении записи.
  def execute_request endpoint, query
    query.transform_values! do |v| 
      case v
      when Enumerable
        v.map(&:to_s).join(',')
      when ::Time, Date
        v.xmlschema
      else
        v
      end
    end
    if allow_locale?
      locale = @config.dig :api, :locale
      preferred_place = @config.dig :api, :preferred_place
      query[:locale] = locale if locale
      query[:preferred_place_id] = preferred_place if preferred_place
    end
    result = nil
    current_total = nil
    previous_total = Thread::current[:total] || 0
    if allow_id_above? && endpoint == self.endpoint
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
          unless current_total
            current_total = response[:total_results]
            current_total += previous_total
            console.update total: current_total, status: 'update...'
            Thread::current[:total] = current_total
          end
          # self.model.db.transaction(isolation: :committed, mode: :immediate) do
            check_shutdown! { self.model.db.rollback_on_exit }
            response[:results].each do |data| 
              self.parser.parse! data
              current_current = (Thread::current[:current] || 0) + 1
              console.update current: current_current, status: 'update...'
              Thread::current[:current] = current_current
            end
          # end
          result = :done if response[:total_results] <= response[:per_page]
          id_above = response[:results].last&.[](:id)
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
          unless current_total
            current_total = response[:total_results]
            current_total += previous_total
            console.update total: current_total, status: 'update...'
            Thread::current[:total] = current_total
          end
          # self.model.db.transaction(isolation: :committed, mode: :immediate) do
            check_shutdown! { self.model.db.rollback_on_exit }
            response[:results].each do |data|
              self.parser.parse! data
              current_current = (Thread::current[:current] || 0) + 1
              console.update current: current_current, status: 'update...'
              Thread::current[:current] = current_current
            end
          # end
          processed = response[:page] * response[:per_page]
          result = :done if processed >= response[:total_results]
          page = response[:page] + 1
        end
      end
    end
    console.update status: 'processing...'
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
  def set_request_projects record, ids
    record.send :project_pks=, Array(ids)
  end

  # @private
  def set_request_places record, ids
    record.send :place_pks=, Array(ids)
  end

  # @private
  def set_request_taxa record, ids
    record.send :taxon_pks=, Array(ids)
  end

  # @private
  def set_request_users record, ids
    record.send :user_pks=, Array(ids)
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
