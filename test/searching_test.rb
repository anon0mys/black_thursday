require './test/test_helper'
require './lib/searching.rb'

# Tests for searching module
class SearchingTest < Minitest::Test
  include Searching

  def add_elements(data)
    data
  end

  def test_from_csv
    files = ['./data/sample_data/items.csv',
             './data/sample_data/merchants.csv',
             './data/sample_data/invoices.csv',
             './data/sample_data/transactions.csv']

    files.each do |file_path|
      expected = from_csv(file_path)

      assert_instance_of CSV, expected
    end
  end

  def test_find_by_id
    @all = stub(find: mock('object'))

    assert_instance_of Mocha::Mock, find_by_id('id')
  end

  def test_find_by_name
    @all = stub(find: mock('object'))

    assert_instance_of Mocha::Mock, find_by_id('name')
  end

  def test_find_all_by_merchant_id
    @all = stub(find_all: mock('object'))

    assert_instance_of Mocha::Mock, find_all_by_merchant_id('id')
  end
end
