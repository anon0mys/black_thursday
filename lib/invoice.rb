# Class for storing invoice information
class Invoice
  attr_reader :id,
              :customer_id,
              :merchant_id,
              :status,
              :created_at,
              :updated_at,
              :parent

  def initialize(data, parent)
    @id          = data[:id].to_i
    @customer_id = data[:customer_id].to_i
    @merchant_id = data[:merchant_id].to_i
    @status      = data[:status].to_sym
    @created_at  = Time.parse(data[:created_at])
    @updated_at  = Time.parse(data[:updated_at])
    @parent      = parent
  end

  def merchant
    @merchants ||= @parent.merchant(@merchant_id)
  end

  def customer
    @customers ||= @parent.customer(@customer_id)
  end

  def items
    @items ||= @parent.items(@id)
  end

  def transactions
    @transactions ||= @parent.transactions(@id)
  end

  def invoice_items
    @invoice_items ||= @parent.invoice_items(@id)
  end

  def is_paid_in_full?
    success = transactions.find { |trans| trans.result == 'success' }
    !success.nil?
  end

  def total
    return 0 unless is_paid_in_full?
    invoice_items.reduce(0) do |sum, item|
      sum += (item.unit_price * item.quantity)
      sum
    end
  end
end
