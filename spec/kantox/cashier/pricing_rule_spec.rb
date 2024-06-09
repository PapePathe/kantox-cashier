# frozen_string_literal: true

RSpec.describe Kantox::Cashier::PricingRule do
  let(:products) do
    {
      GR1: {name: "Gree Tea", price: 3.11},
      SR1: {name: "Strawberries", price: 5.00},
      CF1: {name: "Coffe", price: 11.23}
    }
  end

  describe ".initialize" do
    it "stores ref to products" do
      rules = described_class.new products

      expect(rules.products).to eq(products)
      expect(rules.rules).to eq({})
    end
  end

  describe "#add_rule" do
    it "raises error if product code not found" do
      pricing = described_class.new products
      proc = proc { |items_count, unit_price| unit_price }

      expect { pricing.add_rule :XR1, proc }.to(
        raise_error(Kantox::Cashier::ProductNotFound)
      )
    end

    it "stores the rule proc " do
      pricing = described_class.new products
      proc = proc { |items_count, unit_price| unit_price }
      pricing.add_rule :GR1, proc

      expect(pricing.rules[:GR1]).to eq(proc)
    end
  end

  describe "#apply" do
    it "when product does not exist" do
    end

    it "when rule is a percentage discount on more than 3 products" do
      pricing = described_class.new products
      pricing.add_rule :SR1, Kantox::Cashier::PricePercentDiscountRule

      [
        {code: :GR1, count: 1, expected_price: 3.11},
        {code: :CF1, count: 0, expected_price: 0},
        {code: :CF1, count: 1, expected_price: 11.23},
        {code: :CF1, count: 2, expected_price: 22.46},
        {code: :CF1, count: 3, expected_price: 33.69},
        {code: :CF1, count: 4, expected_price: 44.92}
      ].each do |test_data|
        price = pricing.apply(test_data[:code], test_data[:count])
        expect(price).to eq(test_data[:expected_price])
      end
    end

    it "when rule is a price discount on more than 3 products" do
      pricing = described_class.new products
      pricing.add_rule :SR1, Kantox::Cashier::PriceDiscountRule

      [
        {code: :GR1, count: 1, expected_price: 3.11},
        {code: :SR1, count: 0, expected_price: 0},
        {code: :SR1, count: 1, expected_price: 5.0},
        {code: :SR1, count: 2, expected_price: 10.0},
        {code: :SR1, count: 3, expected_price: 13.5},
        {code: :SR1, count: 4, expected_price: 18.0}
      ].each do |test_data|
        price = pricing.apply(test_data[:code], test_data[:count])
        expect(price).to eq(test_data[:expected_price])
      end
    end

    it "when rule is one bought, one offered" do
      pricing = described_class.new products
      pricing.add_rule :GR1, Kantox::Cashier::OneBoughtOneOfferedRule

      [
        {code: :SR1, count: 1, expected_price: 5.0},
        {code: :GR1, count: -1, expected_price: 0},
        {code: :GR1, count: 0, expected_price: 0},
        {code: :GR1, count: 1, expected_price: 3.11},
        {code: :GR1, count: 2, expected_price: 3.11},
        {code: :GR1, count: 3, expected_price: 6.22},
        {code: :GR1, count: 4, expected_price: 6.22},
        {code: :GR1, count: 5, expected_price: 9.33}
      ].each do |test_data|
        price = pricing.apply(test_data[:code], test_data[:count])
        expect(price).to eq(test_data[:expected_price])
      end
    end
  end
end
