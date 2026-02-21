# frozen_string_literal: true

class INatGet::Data::Parser::Part::Subprojects < INatGet::Data::Parser::Part::Links

  def initialize parser
    super parser, :subprojects, model: INatGet::Data::Model::Project
  end

  def parse target, source
    return nil unless target.is_umbrella
    subprojects = []
    params = source[:search_parameters] || []
    params.each do |para|
      if para[:field] == 'project_id'
        subprojects += para[:value]
      end
    end
    manager = INatGet::Data::Manager::Projects::instance
    subprojects = manager.get(*subprojects).compact.map(&:id)
    field = @parser.model.association_reflection(@name)[:pks_setter_method].to_s.chomp("=").gsub('_setter', '').to_sym
    { field => subprojects }
  end

end
