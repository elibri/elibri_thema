require "test_helper"

class ElibriThemaTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ElibriThema::VERSION
  end

  def test_generating_flat_list
    list = ElibriThema.flat_categories

    assert_equal({code: "A", name: "Sztuka", remarks: "", parent_code: nil}, list[0])
    assert_equal({code: "AB", name: "Sztuka – zagadnienia ogólne", remarks: "", parent_code: "A"}, list[1])
  end

  def test_generating_nested_list
    nested_list = ElibriThema.nested_categories
    assert_equal 26, nested_list.size

    assert_equal "A", nested_list[0][:code]
    assert_equal 8, nested_list[0][:children].size
    assert_equal ["AB", "AF", "AG", "AJ", "AK", "AM", "AT", "AV"], nested_list[0][:children].map { |c| c[:code] }
    assert_equal "AB", nested_list[0][:children][0][:code]
    assert_equal ["ABA", "ABC", "ABK", "ABQ"], nested_list[0][:children][0][:children].map { |c| c[:code] }
  end
end
