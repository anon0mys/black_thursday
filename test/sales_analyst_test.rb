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

  def test_it_finds_invoices_for_each_merchant
    assert_equal [2.0, 1.0, 0.0, 1.0], @sa.invoices_for_each_merchant
  end

  def test_average_invoices_per_merchant
    actual = @sa.average_invoices_per_merchant
    assert_equal 1.0, actual
  end

  def test_average_invoices_per_merchant_standard_deviation
    actual = @sa.average_invoices_per_merchant_standard_deviation
    assert_equal 0.82, actual
  end

  def test_top_merchants_by_invoice_count
    merch_one = stub(invoices: [1, 2])
    merch_two = stub(invoices: [1])
    merch_three = stub(invoices: [1, 2, 3, 4, 5, 6, 7, 8, 9])
    merch_arr = [merch_one, merch_two, merch_three]
    sa = stub(top_merchants_by_invoice_count:
              stub(se:
                   stub(merchants:
                        stub(all: merch_arr))))
    actual = sa.top_merchants_by_invoice_count

    assert merch_three == actual
  end

  def test_bottom_merchants_by_invoice_count
    actual = @sa.top_merchants_by_invoice_count
    assert_equal [1, 2, 3], actual
  end

  def test_top_days_by_invoice_count
    actual = @sa.top_days_by_invoice_count
    assert_equal ['Saturday'], actual
  end

  def test_it_returns_invoice_status_percentages
    actual = @sa.invoice_status(:pending)
    assert_equal 50, actual
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

  def test_merchants_sell_one_item_in_first_month
    month = 'February'
    merchants = @sa.merchants_with_only_one_item_registered_in_month(month)

    assert_equal 123_341_12, merchants.first.id
    assert_equal 1, merchants.length
  end

  def test_revenue_by_merchant
    assert_equal 59.95, @sa.revenue_by_merchant(123_341_05)
  end

  def test_top_revenue_earners
    top_earners = @sa.top_revenue_earners

    assert_instance_of Merchant, top_earners[0]
    assert_equal 123_341_05, top_earners[0].id
  end

  def test_total_revenue_by_date
    date = Time.parse('2009-02-07')
    assert_equal BigDecimal.new(348_73) / 100, @sa.total_revenue_by_date(date)
  end

  def test_merchants_ranked_by_revenue
    merchants = @sa.merchants_ranked_by_revenue

    assert_instance_of Merchant, merchants.first
    assert_equal 4, merchants.length
  end

  def test_merchants_with_pending_invoices
    merchants = @sa.merchants_with_pending_invoices
    assert_equal 3, merchants.length
    assert_instance_of Merchant, merchants.first
  end

  def test_pending_invoices?
    invoice_one = stub(is_paid_in_full?: true)
    invoice_two = stub(is_paid_in_full?: false)
    invoices = [invoice_one, invoice_two]

    assert @sa.pending_invoices?(invoices)
    refute @sa.pending_invoices?([invoice_one])
  end
end
