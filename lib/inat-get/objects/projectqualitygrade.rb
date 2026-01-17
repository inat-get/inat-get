# frozen_string_literal: true

require "sequel"

require_relative "../info"

module INatGet::Models; end

class INatGet::Models::ProjectQualityGrade < Sequel::Model(:project_quality_grades)

  many_to_one :project

end
