require_relative "../with_resources"

module WithResources::TopLevel
  refine Kernel do
    def with(alloc, &block)
      WithResources.with(alloc, &block)
    end
  end
end
