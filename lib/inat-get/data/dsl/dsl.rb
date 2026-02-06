# frozen_string_literal: true

require 'date'

require_relative '../info'

module INatGet::Data::DSL

  include INatGet::Data::DSL::Condition
  
  def observations **query
    # TODO: implement
    # Возвращает Dataset с соответствующим условием
  end

  def observation id
    observations(id: id).first
  end

  def taxa **query
    # TODO: implement
    # Возвращает датасет с соотвествующим условием
  end

  def taxon id
    taxa(id: id).first
  end

  def place id_or_slug
    # TODO: implement
  end

  def project id_or_slug
    # TODO: implement
  end

  def user id_or_login
    # TODO: implement
  end

  def today
    Date.today
  end

  def now
    Time.now
  end

  def version
    INatGet::Info::VERSION
  end

end
