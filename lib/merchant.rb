# Merchant class
class Merchant
  attr_reader :id,
              :name,
              :parent

  def initialize(data, parent)
    @id     = data[:id].to_i
    @name   = data[:name]
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
