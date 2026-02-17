# frozen_string_literal: true

class INatGet::Data::Parser::Part::PrjSearch < INatGet::Data::Parser::Part::Assoc

  def initialize parser
    super parser, nil, model: nil
  end

  def parse target, source
    return nil unless target.is_collection
    params = source[:search_parameters]
    quality_grades = []
    term_id = nil
    term_value_id = nil
    members_only = false
    params.each do |para|
      case para[:field]
      when 'quality_grade'
        quality_grades = para[:value]
      when 'members_only'
        members_only = para[:value]
      when 'term_id'
        term_id = para[:value]
      when 'term_value_id'
        term_value_id = para[:value]
      end
    end
    make_quality_grades target.id, quality_grades
    make_terms target.id, term_id, term_value_id
    { members_only: members_only }
  end

  private

  def make_quality_grades p_id, quality_grades
    qg_mod = INatGet::Data::Model::ProjectQualityGrade
    condition = Sequel.&({ project_id: p_id }, Sequel.~({ quality_grade: quality_grades }))
    qg_mod.where(condition).delete
    quality_grades -= qg_mod.where(project_id: p_id).select_map(:quality_grade)
    quality_grades.each do |qg|
      qg_mod.create project_id: p_id, quality_grade: qg
    end
  end

  def make_terms p_id, term_id, term_value_id
    pt_mod = INatGet::Data::Model::ProjectTerm
    condition = { project_id: p_id }
    if term_id && term_value_id
      record = pt_mod.with_pk p_id
      if record
        record.update term_id: term_id, term_value_id: term_value_id
      else
        pt_mod.create project_id: p_id, term_id: term_id, term_value_id: term_value_id
      end
    else
      pt_mod.where(condition).delete
    end
  end

end
