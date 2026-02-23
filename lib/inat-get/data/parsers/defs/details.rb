# frozen_string_literal: true

require_relative 'copy'

class INatGet::Data::Parser::Part::Details < INatGet::Data::Parser::Part::Copy

  def parse source
    fields = {}
    @names.each do |name|
      details = source["#{ name }_details".to_sym]
      if details
        data = parse_details details, prefix: name
        fields.merge! data
      end
    end
    @aliases.each do |name, src_name|
      details = source[src_name]
      if details
        data = parse_details details, prefix: name
        fields.merge! data
      end
    end
    fields
  end

  private

  # @private
  def parse_details details, prefix:
    result = {
      "#{ prefix }_year".to_sym  => details[:year],
      "#{ prefix }_month".to_sym => details[:month],
      "#{ prefix }_week".to_sym  => details[:week],
      "#{ prefix }_day".to_sym   => details[:day],
      "#{ prefix }_hour".to_sym  => details[:hour]
    }
    if prefix == :observed
      result.merge!({ "#{ prefix }_winter".to_sym => winter(details[:year], details[:month]) })
    end
    result
  end

  # @private
  def winter year, month
    case month
    when 1..4
      year
    when 5..9
      nil
    when 10..12
      year + 1
    end
  end

end
