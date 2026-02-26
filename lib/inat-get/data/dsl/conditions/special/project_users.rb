# frozen_string_literal: true

require_relative '../base'

# @api private
module INatGet::Data::DSL::Condition::Special; end

class INatGet::Data::DSL::Condition::Special::ProjectUsers < INatGet::Data::DSL::Condition

  def initialize project_id
    @project_id = project_id
  end

  # def model() = INatGet::Data::Model::User

  def api_query
    [ { endpoint: "projects/#{ @project_id }/members", query: {} } ]
  end

end
