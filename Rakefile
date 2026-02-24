# frozen_string_literal: true

require "rspec/core/rake_task"

namespace :spec do

  RSpec::Core::RakeTask::new :unit do |spec|
    spec.pattern = 'spec/unit/**/*_spec.rb'
    spec.rspec_opts = '--format documentation'
  end

  RSpec::Core::RakeTask::new :data do |spec|
    spec.pattern = 'spec/data/**/*_spec.rb'
    spec.rspec_opts = '--format documentation'
  end

  RSpec::Core::RakeTask::new :infra do |spec|
    spec.pattern = 'spec/infra/**/*_spec.rb'
    spec.rspec_opts = '--format documentation'
  end

  task release: [ :unit, :data ]

end

RSpec::Core::RakeTask.new(:spec)

task default: 'spec:unit'
