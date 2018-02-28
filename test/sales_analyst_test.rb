require './test/test_helper'
require './lib/sales_engine'
require './lib/sales_analyst'

class SalesAnalystTest < Minitest::Test
  def setup
    repositories = {
      items: './data/sample_data/items.csv',
      merchants: './data/sample_data/merchants.csv',
      invoices: './data/sample_data/invoices.csv',
      transactions: './data/sample_data/transactions.csv',
      customers: './data/sample_data/customers.csv',
      invoice_items: './data/sample_data/invoice_items.csv'
    }
    sales_eng = SalesEngine.new(repositories)
    @sa       = SalesAnalyst.new(sales_eng)
  end

  def test_sales_analyst_class_exists
    assert_instance_of SalesAnalyst, @sa
  end

  def test_average_items_per_merchant
    assert_equal 2.5, @sa.average_items_per_merchant
  end

  def test_average_items_per_merchant_standard_deviation
    actual = @sa.average_items_per_merchant_standard_deviation
    assert_equal 2.65, actual
  end

  def test_merchants_with_high_item_count
    actual = @sa.merchants_with_high_item_count.first.name
    assert_equal 'MiniatureBikez', actual
  end

  def test_average_item_price_for_merchant
    actual = @sa.average_item_price_for_merchant(123_341_05)
    assert_equal 0.1166e2, actual
  end

  def test_average_average_price_per_merchant
    actual = @sa.average_average_price_per_merchant
    assert_equal 60.66, actual
  end

  def test_golden_items
    golden_items = @sa.golden_items
    assert_equal 'Some stuff', golden_items.first.name
  end

  def test_best_item_for_merchant
    best_item = @sa.best_item_for_merchant(123_341_05)
    assert_equal 'Garbage', best_item.name
  end

  def test_invoice_item_builder
    invoices = @sa.se.find_merchant_invoices(123_341_05)
    actual = @sa.invoice_item_builder(invoices)

    assert_instance_of InvoiceItem, actual[0]
  end

  def test_revenue_totals
    invoice_item_one = stub(unit_price: 5, quantity: 2)
    invoice_item_two = stub(unit_price: 2, quantity: 2)
    invoice_items = [invoice_item_one, invoice_item_two]
    expected = { invoice_item_one => 10,
                 invoice_item_two => 4 }

    assert_equal expected, @sa.revenue_totals(invoice_items)
  end

  def test_most_sold_item
    most_sold_item = @sa.most_sold_item_for_merchant(123_341_05)
    assert_equal 'Garbage', most_sold_item[0].name
  end

  def test_quantities_sold
    invoice_item_one = stub(unit_price: 5, quantity: 2)
    invoice_item_two = stub(unit_price: 2, quantity: 2)
    invoice_items = [invoice_item_one, invoice_item_two]
    expected = { invoice_item_one => 2,
                 invoice_item_two => 2 }

    assert_equal expected, @sa.quantities_sold(invoice_items)
  end

  def test_merchants_with_one_item
    merchants = @sa.merchants_with_only_one_item

    assert_equal 123_341_12, merchants.first.id
    assert_equal 1, merchants.length
  end
end
