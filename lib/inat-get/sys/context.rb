# frozen_string_literal: true

require_relative '../info'

# @api private
module INatGet::System; end

module INatGet::System::Context

  class << self

    # @!attribute [rw] shutdown
    # @return [Boolean]
    def shutdown= value
      @@context_shutdown = value
    end

    # @return [Boolean]
    def shutdown
      @@context_shutdown ||= false
    end

  end

  def shutdown?
    @@context_shutdown ||= false
    !!@@context_shutdown
  end

  # Check shutdown mode and interrupt execution if needed
  #
  # If {#shutdown?} — execute block if given, than exit with `Errno::EINTR::Errno` code.
  # @yield Do something before exit.
  # @return [void]
  def check_shutdown!
    if shutdown?
      yield if block_given?
      exit(Errno::EINTR::Errno)
    end
  end

  module_function :shutdown?, :check_shutdown!

end
