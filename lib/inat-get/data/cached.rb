# frozen_string_literals: true

require_relative '../core'

# @api private
class INatGet::Cached

  class << self

    def caches
      common_all = (Thread::current[:common_cache] ||= {})
      common_cls = (common_all[self] ||= {})
      modified_all = (Thread::current[:modified_cache] ||= {})
      modified_cls = (modified_all[self] ||= {})
      [ common_cls, modified_cls ]
    end

    def get *cache_key, **opts
      if cache_key.size == 1
        cache_key = cache_key.first
      end
      cached(cache_key) || load(cache_key) || (opts[:fetch] && fetch(cache_key)) || new(cache_key)
    end

    def [] *cache_key
      get cache_key, fetch: true
    end

    def cached(cache_key)
      common_cache, modified_cache = caches
      value = modified_cache[cache_key]
      return value if value
      ref = common_cache[cache_key]
      if ref.weakref_alive?
        ref.__getobj__
      else
        common_cache.delete cache_key
        nil
      end
    end

    def load *cache_keys
      raise NotImplementedError, "Abstract method, it must be implemented by subclasses"
    end

    def fetch *cache_keys
      raise NotImplementedError, "Abstract method, it must be implemented by subclasses"
    end

    protected :caches, :cached, :load, :fetch

    protected :new

  end

  attr_reader :cache_key

  def initialize cache_key
    @cache_key = cache_key
    caching
  end

  def modified?
    !!@modified
  end

  def caching
    common_cache, modified_cache = self.class.caches
    if modified?
      modified_cache[@cache_key] = self
    else
      modified_cache.delete @cache_key
    end
    common_cache[@cache_key] = WeakRef::new(self)
  end

  def uncaching
    common_cache, modified_cache = self.class.caches
    common_cache.delete @cache_key
    modified_cache.delete @cache_key
  end

  protected :caching, :uncaching

end
