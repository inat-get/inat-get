# frozen_string_literal: true

class INatGet::Data::Parser::Part::Links < INatGet::Data::Parser::Part

  def apply target, source
    parser = @args.first
    name = @args[1]
    src_name = @kwargs[:src] || name
    value = source[src_name]
    if value
      value = parser.parse! value
    else
      src_ids = @kwargs[:ids] || get_src_ids(src_name)
      ids = source[src_ids]
      value = parser.manager.get(*ids) if ids
    end
    pks = value.map(&:id)
    field = target.class.association_pks_getters[name]
    target.set(field => pks)
  end

  private

  # @private
  def get_src_ids name
    if name == :taxa
      :taxon_ids
    else
      str_name = name.to_s
      single = if str_name.end_with?('ies')
        str_name.sub(/ies$/, 'y')
      elsif str_name.end_with?('ses')
        str_name.sub(/ses$/, 's')
      elsif str_name.end_with?('xes')
        str_name.sub(/xes$/, 'x')
      elsif str_name.end_with?('shes')
        str_name.sub(/shes$/, 'sh')
      elsif str_name.end_with?('s') && !str_name.end_with?('ss')
        str_name.sub(/s$/, '')
      else
        str_name
      end
      "#{ single }_ids".to_sym
    end
  end

end
