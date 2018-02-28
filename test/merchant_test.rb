require './test/test_helper'
require './lib/merchant'

# Tests merchant class
class MerchantTest < Minitest::Test
  def setup
    mock_repo = stub(
      items: [mock, mock],
      invoices: [mock, mock],
      customers: [mock, mock]
    )
    @merchant = Merchant.new({
                               id: 5,
                               name: 'Turing School',
                               created_at: '2009-02-07',
                               updated_at: '2009-02-07'
                             }, mock_repo)
  end

  def test_merchant_class_exists
    assert_instance_of Merchant, @merchant
  end

  def test_attributes
    expected = Time.parse('2009-02-07')
    assert_equal 5, @merchant.id
    assert_equal 'Turing School', @merchant.name
    assert_equal expected, @merchant.created_at
    assert_equal expected, @merchant.updated_at
  end

  def test_other_attributes
    mock_repo = stub(name: 'Merchant Repo')
    merchant  = Merchant.new({
                               id: 1,
                               name: 'Haliburton',
                               created_at: '2009-02-07',
                               updated_at: '2009-02-07'
                             }, mock_repo)

    assert_equal 1, merchant.id
    assert_equal 'Haliburton', merchant.name
    assert_equal 'Merchant Repo', merchant.parent.name
  end

  def test_it_asks_parent_for_items
    assert_equal 2, @merchant.items.length
    @merchant.items.each do |item|
      assert_instance_of Mocha::Mock, item
    end
  end

  def test_it_asks_parent_for_invoices
    assert_equal 2, @merchant.invoices.length
    @merchant.invoices.each do |invoice|
      assert_instance_of Mocha::Mock, invoice
    end
  end

  def test_it_asks_parent_for_customers
    assert_equal 2, @merchant.invoices.length
    @merchant.invoices.each do |invoice|
      assert_instance_of Mocha::Mock, invoice
    end
  end
end
