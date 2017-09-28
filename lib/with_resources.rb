require "with_resources/version"

module WithResources
  module ErrorExt
    def suppressed
      @suppressed ||= []
    end
  end

  def self.with(allocation, release_method: :close, &block)
    var_names = []
    vars = {}

    allocation_block_path = nil
    allocation_block_lineno = nil

    trace = TracePoint.new(:line, :b_return) do |tp|
      if tp.event == :line && !tp.path.end_with?("lib/with_resources.rb") && allocation_block_path.nil?
        allocation_block_path = tp.path
        allocation_block_lineno = tp.lineno
      end
      if tp.event == :line && tp.path == allocation_block_path && tp.lineno >= allocation_block_lineno
        tp_binding = tp.binding
        tp_variables = tp_binding.local_variables
        if var_names.all?{|resource_var| tp_variables.include?(resource_var) }
          # hit! this block is resource allocation block
          tp_variables.each do |name|
            unless var_names.include?(name)
              var_names << name
            end
          end
        end
      end
      if tp.event == :b_return && tp.path == allocation_block_path && tp.lineno >= allocation_block_lineno
        tp_binding = tp.binding
        var_names.each do |name|
          vars[name] = tp_binding.local_variable_get(name)
        end
      end
    end

    error = nil
    return_value = nil
    begin
      trace.enable do
        allocation.call
      end
      return_value = block.call(*vars.values)
    rescue => e
      error = e
      error.extend(ErrorExt)
    ensure
      vars.values.reverse.each do |v|
        if v.respond_to?(release_method)
          begin
            v.send(release_method)
          rescue => e
            if error
              error.suppressed << e
            else
              error = e
              error.extend(ErrorExt)
            end
          end
        end
      end
    end
    raise error if error
    return_value
  end
end
