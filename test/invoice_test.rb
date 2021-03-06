require './test/test_helper'
require './lib/invoice'

# Tests the invoice class
class InvoiceTest < Minitest::Test
  def setup
    @invoice_repo = stub(
      merchant: mock('merchant'),
      customer: mock('customer'),
      items: [mock('item'), mock('item')],
      transactions: [mock('trans'), mock('trans')],
      invoice_items: [mock('inv_item'), mock('inv_item')]
    )
    @invoice = Invoice.new({
                             id: 6,
                             customer_id: 7,
                             merchant_id: 8,
                             status: 'pending',
                             created_at: '1969-07-20 20:17:40 - 0600',
                             updated_at: '1969-07-20 20:17:40 - 0600'
                           }, @invoice_repo)
  end

  def test_it_exists
    assert_instance_of Invoice, @invoice
  end

  def test_it_has_attributes
    assert_equal 6, @invoice.id
    assert_equal 7, @invoice.customer_id
    assert_equal 8, @invoice.merchant_id
    assert_equal :pending, @invoice.status
    assert_equal '1969-07-20 20:17:40 -0600', @invoice.created_at.to_s
    assert_equal '1969-07-20 20:17:40 -0600', @invoice.updated_at.to_s
  end

  def test_data_types_of_attributes
    assert_instance_of Integer, @invoice.id
    assert_instance_of Integer, @invoice.customer_id
    assert_instance_of Integer, @invoice.merchant_id
    assert_instance_of Symbol, @invoice.status
    assert_instance_of Time, @invoice.created_at
    assert_instance_of Time, @invoice.updated_at
  end

  def test_it_asks_parent_for_merchant
    merchant = @invoice_repo.merchant

    assert_equal merchant, @invoice.merchant
  end

  def test_it_asks_parent_for_customer
    assert_instance_of Mocha::Mock, @invoice.customer
  end

  def test_it_asks_parent_for_items
    assert_instance_of Mocha::Mock, @invoice.items[0]
  end

  def test_it_asks_parent_for_transactions
    assert_instance_of Mocha::Mock, @invoice.transactions[0]
  end

  def test_it_asks_parent_for_invoice_items
    invoice_items = @invoice_repo.invoice_items[0]

    assert_equal invoice_items, @invoice.invoice_items[0]
  end

  def test_is_paid_in_full?
    invoice_repo = stub(
      transactions: [stub(result: 'fail'),
                     stub(result: 'success')]
    )
    invoice = Invoice.new({
                            id: 6,
                            customer_id: 7,
                            merchant_id: 8,
                            status: 'pending',
                            created_at: '1969-07-20 20:17:40 - 0600',
                            updated_at: '1969-07-20 20:17:40 - 0600'
                          }, invoice_repo)

    assert invoice.is_paid_in_full?
  end

  def test_is_paid_in_full_false_when_no_success
    invoice_repo = stub(
      transactions: [stub(result: 'fail'),
                     stub(result: 'fail')]
    )
    invoice = Invoice.new({
                            id: 6,
                            customer_id: 7,
                            merchant_id: 8,
                            status: 'pending',
                            created_at: '1969-07-20 20:17:40 - 0600',
                            updated_at: '1969-07-20 20:17:40 - 0600'
                          }, invoice_repo)

    refute invoice.is_paid_in_full?
  end

  def test_invoice_total
    invoice_repo = stub(
      invoice_items: [stub(unit_price: BigDecimal.new(1299) / 100,
                           quantity: 2),
                      stub(unit_price: BigDecimal.new(1899) / 100,
                           quantity: 2)],
      transactions: [stub(result: 'success')]
    )
    invoice = Invoice.new({
                            id: 6,
                            customer_id: 7,
                            merchant_id: 8,
                            status: 'pending',
                            created_at: '1969-07-20 20:17:40 - 0600',
                            updated_at: '1969-07-20 20:17:40 - 0600'
                          }, invoice_repo)
    expected = BigDecimal.new(6396) / 100

    assert_equal expected, invoice.total
  end
end
