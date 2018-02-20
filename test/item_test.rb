require './test/test_helper'
require './test/fixtures/mock_item_repo'
require './lib/item'

# Tests Item class
class ItemTest < Minitest::Test
  def setup
    mock_repo = MockItemRepo.new
    @item = Item.new({ id: 5,
                       name: 'Pencil',
                       description: 'You can use it to write things',
                       unit_price: BigDecimal.new(10.99, 4),
                       merchant_id: 6,
                       created_at: Time.now,
                       updated_at: Time.now }, mock_repo)
  end

  def test_item_class_exists
    assert_instance_of Item, @item
  end

  def test_item_attributes
    expected = 'You can use it to write things'
    # expected2 = Date.today.strftime('%Y-%m-%d %H:%M:%S')

    assert_equal 5, @item.id
    assert_equal 'Pencil', @item.name
    assert_equal expected, @item.description
    assert_equal 0.1099e2, @item.unit_price
    assert_equal 6, @item.merchant_id
    # assert_equal expected2, @item.created_at
    # assert_equal expected2, @item.updated_at
  end

  def test_item_can_have_different_attributes
    item = Item.new({ id: 1,
                      name: 'Wine',
                      description: 'It gets you drunk',
                      unit_price: BigDecimal.new(79.59, 4),
                      merchant_id: 343_414,
                      created_at: Time.now,
                      updated_at: Time.now }, 'parent')

    assert_equal 1, item.id
    assert_equal 'Wine', item.name
    assert_equal 'It gets you drunk', item.description
    assert_equal 343_414, item.merchant_id
    assert_equal 0.7959e2, item.unit_price
  end

  def test_unit_price_to_dollars
    assert_equal 10.99, @item.unit_price_to_dollars
  end

  def test_it_asks_parent_for_merchant
    assert_instance_of MockMerchant, @item.merchant
  end
end
