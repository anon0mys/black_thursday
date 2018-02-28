require 'bigdecimal'
require 'time'

# Merchant class
class Merchant
  attr_reader :id,
              :name,
              :created_at,
              :updated_at,
              :parent

  def initialize(data, parent)
    @id     = data[:id].to_i
    @name   = data[:name]
    @created_at = Time.parse(data[:created_at])
    @updated_at = Time.parse(data[:updated_at])
    @parent = parent
  end

  def items
    @items ||= @parent.items(@id)
  end

  def invoices
    @invoices ||= @parent.invoices(@id)
  end

  def customers
    @customers ||= @parent.customers(@id)
  end
end
