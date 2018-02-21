require './test/test_helper'
require './lib/invoice_repository'
require './lib/sales_engine'
require './lib/searching'

class InvoiceRepositoryTest < Minitest::Test
  def setup
    file_name   = './data/sample_data/invoices.csv'
		@invoice_repo = InvoiceRepository.new(file_name)
  end

	def test_it_exists
		assert_instance_of InvoiceRepository, @invoice_repo
	end

	def	test_it_finds_invoice_id
		assert_instance_of Array, @invoice_repo.all
		assert_nil @invoice_repo.find_by_id(10)
		assert_instance_of Invoice, @invoice_repo.find_by_id(4)
  end

  def test_it_can_find_all_by_customer_id
    assert_equal [], @invoice_repo.find_all_by_customer_id('20')
    assert_instance_of Array, @invoice_repo.find_all_by_customer_id('1')
    binding.pry
    assert_equal '12334753', @invoice_repo.find_all_by_customer_id('1')[1]
  end
end