# frozen_string_literal: true

module DeepMerge

  def deep_merge other
    base = if self.respond_to?(:deep_dup)
      self.deep_dup
    elsif self.respond_to?(:dup)
      self.dup
    else
      self
    end
    if base.respond_to?(:deep_merge!)
      base.deep_merge! other
    elsif base.respond_to?(:merge)
      base.merge other
    elsif base.respond_to?(:merge!)
      base.merge! other
    else
      raise NoMethodError, "No merge methods in receiver (#{ base.class })", caller_locations
    end
  end

  private

  def visited_data
    Thread::current[:deep_merge_visited_data] ||= { data: {}, level: 0 }
  end

  def reset_visited_data!
    Thread::current[:deep_merge_visited_data] = nil
  end

  protected

  def visited_wrap
    raise ArgumentError, 'Block is required', caller_locations unless block_given?
    data = visited_data
    data[:level] += 1
    yield data[:data]
  ensure
    data[:level] -= 1
    if data[:level] == 0
      reset_visited_data!
    end
  end

end

class Hash

  include DeepMerge

  def deep_dup
    visited_wrap do |visited|
      result = {}
      if self.default_proc != nil
        result.default_proc = self.default_proc
      elsif self.default != nil
        result.default = self.default
      end
      self.each do |key, value|
        id = value.object_id
        result[key] = if visited.has_key?(id)
          visited[id]
        elsif value.respond_to?(:deep_dup)
          visited[id] = value.deep_dup
        elsif value.respond_to?(:dup)
          visited[id] = value.dup
        else
          visited[id] = value
        end
      end
      result
    end
  end

  def deep_merge! other
    visited_wrap do |visited|
      id = self.object_id
      return self if visited.has_key?(id)
      visited[id] = self
      source = if other.is_a?(Hash)
        other
      elsif other.respond_to?(:to_hash)
        other.to_hash
      else
        raise ArgumentError, "Unsupported type of source: (#{ other.class })", caller_locations
      end
      source.each do |key, value|
        if self.has_key?(key)
          old = self[key]
          if old.respond_to?(:can_merge?) && old.can_merge?(value)
            old.deep_merge! value
          else
            self[key] = value
          end
        else
          self[key] = value
        end
      end
      self
    end
  end

  def can_merge? other
    other.is_a?(Hash) || other.respond_to?(:to_hash)
  end

end

class Array

  include DeepMerge

  def deep_dup
    visited_wrap do |visited|
      result = []
      self.each do |item|
        id = item.object_id
        value = if visited.has_key?(id)
          visited[id]
        elsif item.respond_to?(:deep_dup)
          visited[id] = item.deep_dup
        elsif item.respond_to?(:dup)
          visited[id] = item.dup
        else
          visited[id] = item
        end
        result << value
      end
      result
    end
  end

  def deep_merge! other
    visited_wrap do |visited|
      id = self.object_id
      return self if visited.has_key?(id)
      visited[id] = self
      source = if other.is_a?(Array)
        other
      elsif other.respond_to(:to_ary)
        other.to_ary
      else
        raise ArgumentError, "Unsupported type of source: (#{ other.class })", caller_locations
      end
      source.each do |item|
        idx = self.index item
        if idx
          if self[idx].respond_to?(:can_merge?) && self[idx].can_merge?(item)
            self[idx].deep_merge! item
          else
            self[idx] = item
          end
        else
          self << item
        end
      end
      self
    end
  end

  def can_merge? other
    other.is_a?(Array) || other.respond_to?(:to_ary)
  end

end
