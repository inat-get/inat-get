# frozen_string_literal: true

require_relative 'scalar'

class INatGet::Data::Parser::Part::TimeDetails < INatGet::Data::Parser::Part

  def apply target, source
    fields = {}
    @args.each do |arg|
      details = source["#{ arg }_details".to_sym]
      append = parse_details arg, details
      fields.merge! append
    end
    @kwargs.each do |key, value|
      details = source[key]
      append = parse_details value, details
      fields.merge! append
    end
    target.set(**fields)
  end

  private

  def parse_details target_prefix, source
    result = {}
    result["#{ target_prefix }_year".to_sym ] = source[:year]
    result["#{ target_prefix }_month".to_sym] = source[:month]
    result["#{ target_prefix }_week".to_sym ] = source[:week]
    result["#{ target_prefix }_day".to_sym  ] = source[:day]
    result["#{ target_prefix }_hour".to_sym ] = source[:hour]
    result
  end

end
