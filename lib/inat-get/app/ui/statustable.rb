# frozen_string_literal: true

require 'io/console'

class StatusTable

  # @return [Hash]
  attr_reader :cols

  # @return [Array<Symbol>]
  attr_reader :columns

  # @return [Array<Hash>]
  attr_reader :rows

  # @return [Time]
  attr_reader :started_at

  # @group Initialization DSL

  def initialize output, *column_defs, &block
    @output = output
    @started_at = Time::now
    @cols = {}
    @columns = []
    @rows = []
    instance_eval(&block) if block_given?
  end

  # @endgroup

  # @return [void]
  def update **data
    data = data.transform_keys(&:to_sym)
    row = if @id_column
      @rows.find { |r| r[@id_column] == data[@id_column] }
    else
      raise ArgumentError, "Identification column is not defined", caller_locations
    end
    raise ArgumentError, "Column with id = #{ data[@id_column].inspect } not found", caller_locations unless row
    row.merge! data
    self.write
  end

  # @return [void]
  def append **data
    data = data.transform_keys(&:to_sym)
    row = if @id_column
      @rows.find { |r| r[@id_column] == data[@id_column] }
    else
      nil
    end
    raise ArgumentError, "Row with id = #{ data[@id_column].inspect } already exists", caller_locations if row
    if @id_column && !data[@id_column]
      if @cols[@id_column][:auto]
        data[@id_column] = @rows.map { |r| r[@id_column] }.max.succ
      else
        raise ArgumentError, "Value of '#{ @id_column }' must be set for identification", caller_locations
      end
    end
    data[:started_at] ||= Time::now
    @rows << data
    @output.puts ''
    self.write
  end

  # @return [String]
  attr_accessor :status

  # @return [IO]
  attr_reader :output

  private

  # @private
  # @return [void]
  def write
    win_width = @output.winsize[1] || 80
    plain_rows = []
    sort_key = @sort_by || :started_at
    sorted = @rows.sort_by { |r| r[sort_key] }
    sorted.reverse! if @sort_order == :desc
    plain = sorted.map do |row|
      @columns.map do |column|
        case column
        when String
          column
        when Symbol
          column_def = @cols[column]
          value = if column_def[:func]
            column_def[:func].call(column, row)
          else
            row[column]
          end
          if column_def[:format]
            value = format(column_def[:format], value)
          else
            value = value.to_s
          end
        else
          raise ArgumentError, "Invalid column definition: #{ column.inspect }", caller_locations
        end
      end
    end
    func_lambda = lambda { |column| @rows.map { |row| @cols[column][:func].call(column, row) } }
    value_lambda = lambda { |column| @rows.map { |row| row[column] } }
    summary = if @summary
      @columns.map do |column|
        case column
        when String
        column
        when Symbol
          defs = @cols[column]
          values = if defs[:func]
            func_lambda.call(column)
          else
            value_lambda.call(column)
          end
          value = case defs[:summary]
          when :sum
            values.sum
          when :avg
            values.sum / values.count if values.count != 0
          when :min
            values.min
          when :max
            values.max
          when :time
            Time::now - @started_at
          when :title
            @summary_title
          when :status
            @status
          when Proc
            defs[:summary].call(column, @rows)
          else
            nil
          end
          if defs[:format]
            format(defs[:format], value)
          else
            value.to_s
          end
        end
      end
    else
      nil
    end
    widths = []
    @columns.each_index do |idx|
      widths << (plain + [summary].compact).map { |r| r[idx].width }.max
    end
    text = "\e[#{(plain + [summary].compact).size}A"
    plain.each do |row|
      line = ''
      @columns.each_index do |idx|
        width = widths[idx]
        value = row[idx]
        align = if @columns[idx].is_a?(Symbol)
          @cols.dig(@columns[idx], :align) || :left
        else
          :left
        end 
        case align
        when :right
          line += value.rjust(width)
        when :center
          line += value.center(width)
        else
          line += value.ljust(width)
        end
      end
      text += "\e[0m#{ line.truncate win_width }\e[0m\e[K\n"
    end
    if @summary
      line = ''
      @columns.each_index do |idx|
        width = widths[idx]
        value = summary[idx]
        align = if @columns[idx].is_a?(Symbol)
          @cols.dig(@columns[idx], :align) || :left
        else
          :left
        end
        case align
        when :right
          line += value.rjust(width)
        when :center
          line += value.center(width)
        else
          line += value.ljust(width)
        end
      end
      text += (@summary_prefix || "\e[0m") + "#{ line.truncate win_width }\e[0m\e[K\n"
    end
    @output.puts text
  end

  # @private
  def format fmt, value
    if fmt == :time
      value = value.to_i
      min, sec = value.divmod 60
      result = Kernel::format('%02d', sec)
      if min != 0
        hrs, min = min.divmod 60
        result = Kernel::format('%02d', min) + ':' + result
        if hrs != 0
          days, hrs = hrs.divmod 24
          result = Kernel::format('%02d', hrs) + ':' + result
          if days != 0
            result = days.to_s + 'd ' + result
          end
        end
      end
      result
    else
      Kernel::format fmt, value
    end
  end

  # @group Initialization DSL

  # @return [void]
  def column name, **opts
    name = name.to_sym
    raise ArgumentError, "Column '#{ name }' already defined", caller_locations if @cols.has_key?(name)
    opts = opts.transform_keys(&:to_sym)
    opts[:name] = name
    @cols[name] = opts
    @columns << name
    @id_column = name if opts[:id]
    if opts[:sort]
      @sort_by = name
      @sort_order = opts[:sort]
    end
  end

  # @return [void]
  def delimiter value
    value = value.to_s
    @columns << value
  end

  # @return [void]
  def sort_by name = nil, order: :asc, &block
    raise ArgumentError, 'Argument name OR block must be specified', caller_locations if name.nil? != block_given?
    if name
      @sort_by = name.to_sym
    else
      @sort_by = block
    end
    @sort_order = order || :asc
  end

  # @return [void]
  def summary prefix, title
    @summary = true
    @summary_prefix = prefix
    @summary_title = title
  end

  # @endgroup

end
