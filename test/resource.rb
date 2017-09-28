class Record
  def initialize
    @cnt = 0
    @called_list = []
  end

  def value
    @cnt
  end

  def called_list
    @called_list
  end

  def called(label, method_name)
    @called_list << [label, method_name]
  end

  def incr
    @cnt += 1
  end

  def decr
    @cnt -= 1
  end
end

class Resource
  def initialize(label, record, raise_error: nil)
    @raise_error = raise_error
    if @raise_error == :new
      raise "Resource.new"
    end
    @label = label
    @record = record
    @record.incr
  end

  def label
    @label
  end

  def value
    @record.value
  end

  def close
    if @raise_error == :close
      raise "Resource#close"
    end
    @record.decr
    @record.called(@label, :close)
  end

  def release
    @record.decr
    @record.called(@label, :release)
  end
end
