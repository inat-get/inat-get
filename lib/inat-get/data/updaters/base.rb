# frozen_string_literal: true

require 'is-duration'

require_relative '../../info'

# @api private
class INatGet::Data::Updater

  include IS::Duration

  # @private
  def initialize
    @config = INatGet::App::Setup::config[:caching] || {}
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
    make_request condition.to_api
  end

  # @private
  def update_by_ids! *ids
    interval = parse_duration(@config.dig(:refs, self.manager.endpoint) || @config.dig(:refs, :default))
    if interval
      point = Time::now - interval
      fresh = self.model.where(id: ids, cached: (point .. )).select_map(:id)
      ids -= fresh
    end
    endpoint = self.manager.endpoint + '/' + ids.map(&:to_s).join(',')
    requests = { endpoint: endpoint, query: {} }
    requests.each do |rq|
      make_request rq
    end
  end

  # @private
  HARD_LIMIT = 24 * 60 * 60

  # @private
  def make_request request
    endpoint = request[:endpoint]
    query = request[:query]
    record = nil
    if endpoint == self.endpoint
      # ⮴ В противном случае мы запрашиваем конкретные id/sid, которых не нашлось в базе, или нашлись, но недостаточно свежие.
      #   Соответственно, смысла в дальнейших проверках, равно как и в сохранении запроса, нет.
      query.transform_values! { |v| v.is_a?(Enumerable) ? v.sort : v }
      prepared = { endpoint: endpoint, query: query }
      json = JSON.generate prepared, sort_keys: true, space: ''
      hash = Digest::MD5::hexdigest json
      endless_query = query.reject { |k, _| k == :d2 || k == :created_d2 }
      endless_prepared = { endpoint: endpoint, query: query }
      endless_json = JSON.generate endless_prepared, sort_keys: true, space: ''
      endless_hash = Digest::MD5::hexdigest endless_json

      fresh_point = Time::now - parse_duration(@config.dig(:update) || 0)

      found = false
      rq_model = INatGet::Data::Model::Request
      rq_model.db.transaction(isolation: :committed) do
        record = INatGet::Data::Model::Request.with_pk(hash)
        if record
          found = true
          if record.finished == nil && record.started > (Time::now - HARD_LIMIT)
            while record.finished == nil
              sleep 0.01
              record.reload
            end
            return :other
          end
          return :fresh if record.finished > fresh_point
          record.update started: Time::now, finished: nil
        else
          record = rq_model.create hash: hash, endless: endless_hash, query: json, started: Time::now, freshed: now, finished: nil
        end
      end
      updated_since = nil
      if found
        updated_since = record.started
      else
        endless_record = rq_model.where(endless: endless_hash).exclude(finished: nil).order(:finished.desc).first
        if endless_record
          return :fresh if endless_record.finished > fresh_point
          if allow_updated_since
            saved_json = endless_record.query
            saved_data = JSON.parse saved_json, symbolize_names: true
            saved_d2 = saved_data.dig :query, :d1
            saved_d2 = Time.parse saved_d2 if saved_d2
            saved_cd2 = saved_data.dig :query, :created_d2
            saved_cd2 = Time.parse saved_cd2 if saved_cd2
            updated_since = [ endless_record.started, saved_d2, saved_cd2 ].compact.min
          end
        end
      end
      query[:updated_since] = updated_since if allow_updated_since && updated_since
      # TODO: глубокая проверка на охватывающие запросы
    end
    request = { endpoint: endpoint, query: query }
    execute_request request
    if endpoint == self.endpoint
      record.update finished: Time::now if record
      # TODO: дальнейшие этапы обновления кэша: refresh и recache
    end
  end

  # @private
  def execute_request request
    # TODO: implement
  end

  # @group Descendant Rules

  # @return [Boolean]
  def allow_updated_since() = false

  # @return [Boolean]
  def allow_id_above() = false

  # @return [Boolean]
  def allow_locale() = false

  # @endgroup

end
