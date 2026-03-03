# frozen_string_literal: true

# @private
class String

  def singular
    case self
    when 'taxa'
      'taxon'
    when 'species'
      'species'
    when /ies$/
      sub(/ies$/, 'y')
    when /ses$/
      sub(/ses$/, 's')
    when /xes$/
      sub(/xes$/, 'x')
    when /shes$/
      sub(/shes$/, 'sh')
    when /ss$/
      self
    when /s$/
      sub(/s$/, '')
    else
      self
    end
  end

end
