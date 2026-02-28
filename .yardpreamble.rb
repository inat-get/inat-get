ENV['SEQUEL_MIGRATIONS_DIR'] = './share/inat-get/db/migrations/'

module WF

  def warn message, category = nil, **kwargs
    case message
    when /literal string will be frozen in the future/, /character class has duplicated range/, /yardpreamble/
      # do nothing
    else
      super message
    end
  end

end
Warning.extend WF
