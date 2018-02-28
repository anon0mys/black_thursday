require_relative 'analytics_module'

# Business metadata calculator
class SalesAnalyst
  include Analytics
  attr_reader :se

  def initialize(sales_eng)
    @se = sales_eng
  end

  def average_items_per_merchant
    average(items_for_each_merchant)
  end

  def items_for_each_merchant
    @merchant_item_lengths ||= @se.merchants.all.map do |merchant|
      merchant.items.length.to_f
    end
  end

  def average_items_per_merchant_standard_deviation
    item_counts = items_for_each_merchant
    standard_deviation(item_counts, average(item_counts))
  end

  def merchants_with_high_item_count
    average = average_items_per_merchant
    st_dev = average_items_per_merchant_standard_deviation
    one_sigma = average + st_dev
    @se.merchants.all.find_all do |merchant|
      merchant.items.length > one_sigma
    end
  end

  def average_item_price_for_merchant(merchant_id)
    merchant = @se.merchants.find_by_id(merchant_id)
    item_prices = merchant.items.map(&:unit_price)
    average(item_prices)
  end

  def total_avg_price
    @se.merchants.all.map do |merchant|
      average_item_price_for_merchant(merchant.id)
    end.reduce(:+)
  end

  def average_average_price_per_merchant
    (total_avg_price / @se.merchants.all.length).round(2)
  end

  def all_item_prices
    @item_prices ||= @se.items.all.map(&:unit_price)
  end

  def golden_items
    average = average(all_item_prices)
    st_dev = standard_deviation(all_item_prices, average)
    two_sigma = average + (2 * st_dev)
    @se.items.all.find_all do |item|
      item.unit_price > two_sigma
    end
  end

  def best_item_for_merchant(merchant_id)
    invoices = @se.find_merchant_invoices(merchant_id)
    invoice_items = invoice_item_builder(invoices)
    totals = revenue_totals(invoice_items)
    max = totals.max_by { |_item, total| total }
    @se.items.find_by_id(max[0].item_id)
  end

  def invoice_item_builder(invoices)
    invoices.each_with_object([]) do |invoice, results|
      results << invoice.invoice_items if invoice.is_paid_in_full?
      results
    end.flatten
  end

  def revenue_totals(invoice_items)
    invoice_items.each_with_object({}) do |invoice_item, results|
      results[invoice_item] = invoice_item.unit_price * invoice_item.quantity
      results
    end
  end

  def quantities_sold(invoice_items)
    invoice_items.each_with_object({}) do |invoice_item, results|
      results[invoice_item] = invoice_item.quantity
      results
    end
  end

  def most_sold_item_for_merchant(merchant_id)
    invoices = @se.find_merchant_invoices(merchant_id)
    invoice_items = invoice_item_builder(invoices)
    quantities = quantities_sold(invoice_items)
    max_count = quantities.values.max
    results = quantities.find_all { |_item, total| total == max_count }
    results.to_h.keys.map do |result|
      @se.items.find_by_id(result.item_id)
    end
  end

  def merchants_with_only_one_item
    @one_item ||= @se.merchants.all.find_all do |merchant|
      merchant.items.length == 1
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants = merchants_with_only_one_item
    merchants.find_all do |merchant|
      merchant.created_at.strftime('%B') == month
    end
  end

  def revenue_by_merchant(merchant_id)
    invoices = @se.find_merchant_invoices(merchant_id)
    invoice_items = invoice_item_builder(invoices)
    totals = revenue_totals(invoice_items).values
    totals.reduce(&:+)
  end

  def top_revenue_earners(length = 20)
    totals = @se.merchants.all.reduce({}) do |result, merchant|
      revenue = revenue_by_merchant(merchant.id)
      revenue = 0 if revenue.nil?
      result[merchant] = revenue
      result
    end
    totals.max_by(length) { |_merchant, revenue| revenue }.to_h.keys
  end

  def total_revenue_by_date(date)
    invoices = @se.invoices.all.find_all do |invoice|
      invoice.created_at == date
    end
    invoices.reduce(0) do |sum, invoice|
      sum += revenue_totals(invoice.invoice_items).values.reduce(:+)
      sum
    end
  end

  def merchants_ranked_by_revenue
    top_revenue_earners(@se.merchants.all.length)
  end

  def merchants_with_pending_invoices
    @se.merchants.all.reduce([]) do |pending, merchant|
      pending << merchant if pending_invoices?(merchant.invoices)
      pending
    end
  end

  def pending_invoices?(invoices)
    pending = invoices.reject do |invoice|
      invoice.is_paid_in_full?
    end
    !pending.empty?
  end
end
