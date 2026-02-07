# frozen_string_literal: true

require_relative '../../info'

# @api private
class INatGet::Data::Parser

  def parse! src
    case src
    when Enumerable
      src.map { |s| entry!(s) }
    else
      entry! src
    end
  end

  # @return [Sequel::Model]
  def fake(data) = raise NorImplementedError, "Not implemented method 'fake' of abstract class", caller_locations

  def identification! src
    # TODO: implement
  end

  def observation! src
    # TODO: implement
  end

  def place! src
    # TODO: implement
  end

  def project! src
    # TODO: implement
  end

  def taxon! src
    # TODO: implement
  end

  def user! src
    # TODO: implement
  end

end
