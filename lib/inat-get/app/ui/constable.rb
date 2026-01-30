# frozen_string_literal: true

# # Title
# Ololo, bla-bla-bla.
#
# This
class Constable

  # @group Config Attributes

  # @return [Array<Hash|String>]
  attr_reader :defs

  # @return [IO]
  attr_reader :term

  # @endgroup

  # @group Config Methods

  # @yield
  def initialize(term = $stdout, &block)
    @term = term
    @inactivate_when = lambda { |row| row[:active] == false }

    @defs = []
    @rows = []
    @summary_row = {}
    @started = Time::now

    configure(&block) if block_given?
  end

  # @yield
  # @return [self]
  def configure &block
    raise ArgumentError, "Block must be specified", caller_locations unless block_given?
    instance_eval(&block)
    self
  end

  # @endgroup

  # @group Data Attributes

  # @return [Array<Hash>]
  attr_reader :rows

  # @return [Time]
  attr_reader :started

  # @endgroup

  # @group Data Methods

  # Update specified data row and refresh corresponding line. If row change state to inactive, refresh whole screen.
  # @param [Hash] data
  # @option data [Object] :id Row identifier. Must be existing in current table.
  # @option data [Object] any Updated data fields.
  # @return [Hash] Updated row
  def update **data
    raise ArgumentError, 'Id field is not specified', caller_locations unless @id
    data.transform_keys! { |k| k.to_sym }
    id = data[@id]
    raise ArgumentError, "Id field ('#{ @id }') not specified in data.", caller_locations unless id
    row = find_row data[@id]
    raise ArgumentError, "Row with id = #{ id } is not found", caller_locations unless row
    row.merge! data
    if row[:_active] && @inactivate_when.call(row)
      row[:_active] = false
      refresh_table
    else
      refresh_line row
    end
    row
  end

  # Add and initialize new data row. Then refresh screen.
  # @param [Hash] data
  # @return [Hash] Added row
  def append **data
    data.transform_keys! { |k| k.to_sym }
    data[:_active] = true
    data[:_started] = Time::now
    row = {}
    row.merge! data
    @rows << row
    refresh_table
    row
  end

  # @endgroup

  private

  # @private
  def refresh_table
  end

  # @private
  def refresh_line row
  end

  # @group Control Codes

  INVERT = "\e[7m"
  RESET = "\e[0m"
  HIGHLIGHT = "\e[1m"
  CLEAR_LINE = "\e[K"

  # @endgroup

  # @private
  def find_row id
  end

  # @group Config DSL

  # @return [void]
  def terminal io
    raise ArgumentError, "Invalid terminal value: #{ io.inspect }", caller_locations unless io.is_a?(IO)
    @term = io
  end

  # @return [void]
  def column name, id: false, value: nil, calc: nil, format: nil, align: :left, summary: nil
    name = name.to_sym
    @id = name if id
    # TODO: implement
  end

  # @return [void]
  def delimiter value = ' '
    value = value.to_s
    # TODO: implement
  end

  # @return [void]
  def summary show = true, prefix: INVERT, **data
    # TODO: implement
  end

  # @return [void]
  # @yield
  # @yieldparam [Hash] row
  def inactivate_when &block
    raise ArgumentError, 'Block must be specified', caller_locations unless block_given?
    @inactivate_when = block
  end

  # @endgroup

end
