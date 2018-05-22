require 'test/unit'
require 'with_resources'

require_relative 'resource'

class WithResourcesTest < ::Test::Unit::TestCase
  setup do
    @r = Record.new
  end

  test 'allocate/release a resource without errors' do
    assert_equal(0, @r.value)
    WithResources.with(->(){ a = Resource.new("a", @r) }) do |a|
      assert_equal(1, @r.value)
      assert_equal("a", a.label)
    end
    assert_equal(0, @r.value)
    assert_equal([["a", :close]], @r.called_list)
  end

  test 'allocate/release resources without errors' do
    assert_equal(0, @r.value)
    WithResources.with(->(){ a = Resource.new("a", @r); b = Resource.new("b", @r) }) do |a, b|
      assert_equal(2, @r.value)
      assert_equal("a", a.label)
      assert_equal("b", b.label)
    end
    assert_equal(0, @r.value)
    assert_equal([["b", :close], ["a", :close]], @r.called_list)
  end

  test 'allocate/release resources without errors, with release method' do
    assert_equal(0, @r.value)
    WithResources.with(->(){ a = Resource.new("a", @r); b = Resource.new("b", @r) }, release_method: :release) do |a, b|
      assert_equal(2, @r.value)
      assert_equal("a", a.label)
      assert_equal("b", b.label)
    end
    assert_equal(0, @r.value)
    assert_equal([["b", :release], ["a", :release]], @r.called_list)
  end

  test 'allocate/release a resource with error in client block' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){ a = Resource.new("a", @r) }) do |a|
        assert_equal(1, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("yay", e.message)

    assert_equal(0, @r.value)
    assert_equal([["a", :close]], @r.called_list)
  end

  test 'allocate/release resources with error in client block' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){
          a = Resource.new("a", @r)
          b = Resource.new("b", @r)
      }) do |a, b|
        assert_equal(2, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("yay", e.message)

    assert_equal(0, @r.value)
    assert_equal([["b", :close], ["a", :close]], @r.called_list)
  end

  test 'allocate/release a resource with error in client block, with error in closing resource' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){ a = Resource.new("a", @r, raise_error: :close) }) do |a|
        assert_equal(1, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("yay", e.message)

    assert_equal(1, @r.value)
    assert_equal([], @r.called_list)
  end

  test 'allocate/release resources with error in client block, with error in closing a resource' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){
          a = Resource.new("a", @r)
          b = Resource.new("b", @r, raise_error: :close)
      }) do |a, b|
        assert_equal(2, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("yay", e.message)

    assert_equal(1, @r.value)
    assert_equal([["a", :close]], @r.called_list)
  end

  test 'allocate/release resources with error in client block, with error in closing resources' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){
          a = Resource.new("a", @r, raise_error: :close)
          b = Resource.new("b", @r, raise_error: :close)
      }) do |a, b|
        assert_equal(2, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("yay", e.message)

    assert_equal(2, @r.value)
    assert_equal([], @r.called_list)
  end

  test 'allocate/release a resources with error in allocating a resource' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){ a = Resource.new("a", @r, raise_error: :new) }) do |a|
        assert_equal(2, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("Resource.new", e.message)

    assert_equal(0, @r.value)
    assert_equal([], @r.called_list)
  end

  test 'allocate/release resources with error in allocating a resource' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){
          a = Resource.new("a", @r)
          b = Resource.new("b", @r, raise_error: :new)
      }) do |a, b|
        assert_equal(2, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("Resource.new", e.message)

    assert_equal(0, @r.value)
    assert_equal([["a", :close]], @r.called_list)
  end

  test 'allocate/release resources with error in allocating a resource and in releasing another' do
    assert_equal(0, @r.value)
    error = nil
    begin
      WithResources.with(->(){
          a = Resource.new("a", @r, raise_error: :close)
          b = Resource.new("b", @r, raise_error: :new)
      }) do |a, b|
        assert_equal(2, @r.value)
        raise "yay"
      end
    rescue => e
      error = e
    end

    assert_kind_of(RuntimeError, e)
    assert_equal("Resource.new", e.message)

    assert_equal(1, @r.value)
    assert_equal([], @r.called_list)
  end
end
