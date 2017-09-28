require "benchmark"

require "with_resources/toplevel"
using WithResources::TopLevel

n = 100_000

class Resource
  def close
    # do nothing
  end
end

Benchmark.bm do |x|
  x.report("begin") do
    for i in 1..n
      begin
        a = Resource.new
        begin
          b = Resource.new
        ensure
          b.close
        end
      ensure
        a.close
      end
    end
  end

  x.report("with") do
    for i in 1..n
      with(->(){ a = Resource.new; b = Resource.new }) do |a, b|
        # nothing
      end
    end
  end
end
