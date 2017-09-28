require_relative "../with_resources"

module Kernel
  def with(alloc, &block)
    WithResources.with(alloc, &block)
  end
end
