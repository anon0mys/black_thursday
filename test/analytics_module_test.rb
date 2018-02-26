require './test/test_helper'
require 'bigdecimal'
require './lib/analytics_module'

# Tests for analytics module
class AnalyticsTest < Minitest::Test
  include Analytics

  def test_standard_deviation
    elements = [2, 3, 4, 3]
    average = 3
    expected = 0.82
    actual = standard_deviation(elements, average)

    assert_equal expected, actual
  end

  def test_square_differences
    elements = [2, 3, 4, 3]
    average = 3
    expected = 2
    actual = sum_square_differences(elements, average)

    assert_equal expected, actual
  end

  def test_average
    elements = [2.0, 3.0, 4.0, 3.0]
    expected = 3.00

    assert_equal expected, average(elements)
  end

  def test_average_takes_big_decimal
    elements = [BigDecimal.new(2), BigDecimal.new(4)]
    expected = BigDecimal.new(3).round(2)

    assert_equal expected, average(elements)
  end
end
