# frozen_string_literal: true

class INatGet::Data::Parser::Part::Model < INatGet::Data::Parser::Part

  def apply target, source
    fields = {}
    parser = @args.first
    args = @args[1..]
    args.each do |arg|
      fields[arg] = parse_ref parser, source, arg
    end
    @kwargs.each do |s_key, t_key|
      fields[t_key] = parse_ref parser, source, s_key
    end
    target.set(**fields)
  end

  private

  def parse_ref parser, source, source_key
    value = source[source_key]
    value = parser.entry! value if value
    unless value 
      value_id = source["#{ source_key }_id".to_sym]
      value = parser.manager.get value_id if value_id
    end
    value
  end

end
