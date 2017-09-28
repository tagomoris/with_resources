require 'test/unit'
require 'with_resources/toplevel'

require_relative 'resource'

using WithResources::TopLevel

class WithResourcesToplevelTest < ::Test::Unit::TestCase
  setup do
    @r = Record.new
  end

  test 'pid' do
    assert_equal(0, @r.value)
    with(->(){ a = Resource.new("a", @r) }) do |a|
      assert_equal(1, @r.value)
      assert_equal("a", a.label)
    end
    assert_equal(0, @r.value)
    assert_equal([["a", :close]], @r.called_list)
  end
end
