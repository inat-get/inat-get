# frozen_string_literal: true

require_relative '../../dsl/conditions/special/project_users'
require_relative 'links'

class INatGet::Data::Parser::Part::PrjMembers < INatGet::Data::Parser::Part::Links

  def initialize parser
    super parser, :members, model: INatGet::Data::Model::User, source_ids: :user_ids
  end

  def parse target, source
    condition = INatGet::Data::DSL::Condition::Special::ProjectUsers::new target.id
    INatGet::Data::Updater::ProjectUsers::instance.update! condition
    result = super target, source
    result
  end

end
