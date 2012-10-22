module Unidata
  class SelectList
    include Enumerable

    def initialize(uniselect_list, should_cache=false)
      @uniselect_list = uniselect_list
      @should_cache = should_cache
      @cache = []
      @exhausted = false
    end

    def each &block
      return [] if @exhausted && !@should_cache
      if @exhausted
        @cache.each &block
      else
        iterate &block
      end
    end

    private

    def iterate
      until (id = @uniselect_list.next.to_s).empty? do
        @cache << id if @should_cache
        yield id
      end
      @exhausted = true
    end
  end
end
