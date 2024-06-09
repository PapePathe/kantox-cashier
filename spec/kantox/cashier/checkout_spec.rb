# frozen_string_literal: true

RSpec.describe Kantox::Cashier::Checkout do
  let(:products) do
    {
      GR1: {name: "Gree Tea", price: 3.11},
      SR1: {name: "Strawberries", price: 5.00},
      CF1: {name: "Coffe", price: 11.23}
    }
  end

  describe ".initialize" do
    it "keeps a reference to pricing rules" do
      pricing = Kantox::Cashier::PricingRule.new products
      pricing.add_rule :GR1, Kantox::Cashier::OneBoughtOneOfferedRule
      checkout = Kantox::Cashier::Checkout.new(pricing)

      expect(checkout.pricing_rules).to eq(pricing)
    end
  end

  describe "#scan" do
    it "can scan mutiple products and keep them in a basket" do
      pricing = Kantox::Cashier::PricingRule.new products
      pricing.add_rule :GR1, Kantox::Cashier::OneBoughtOneOfferedRule
      checkout = Kantox::Cashier::Checkout.new(pricing)

      checkout.scan(:GR1)
      expect(checkout.basket).to eq({GR1: 1})

      checkout.scan(:GR1)
      expect(checkout.basket).to eq({GR1: 2})

      checkout.scan(:CF1)
      expect(checkout.basket).to eq({GR1: 2, CF1: 1})
    end
  end

  describe "#total" do
    let(:pricing) { Kantox::Cashier::PricingRule.new products }
    before do
      pricing.add_rule :CF1, Kantox::Cashier::PricePercentDiscountRule
      pricing.add_rule :SR1, Kantox::Cashier::PriceDiscountRule
      pricing.add_rule :GR1, Kantox::Cashier::OneBoughtOneOfferedRule
    end

    it "drops price by 2/3 if customer buys 3 of more Coffee" do
      checkout = Kantox::Cashier::Checkout.new(pricing)
      3.times { checkout.scan(:CF1) }

      expect(checkout.total).to eq(22.46)
    end

    it "drops price to 4.50 if customer buys 3 of more Strawberries" do
      checkout = Kantox::Cashier::Checkout.new(pricing)
      3.times { checkout.scan(:SR1) }

      expect(checkout.total).to eq(13.5)
    end

    it "offers a free green tea if customer bought one" do
      checkout = Kantox::Cashier::Checkout.new(pricing)
      2.times { checkout.scan(:GR1) }

      expect(checkout.total).to eq(3.11)
    end

    it "When Basket=GR1,GR1" do
      checkout = Kantox::Cashier::Checkout.new(pricing)
      [:GR1, :GR1].each { |p| checkout.scan(p) }

      expect(checkout.total).to eq(3.11)
    end

    it "When Basket=GR1,SR1,GR1,GR1,CF1" do
      checkout = Kantox::Cashier::Checkout.new(pricing)
      [:GR1, :SR1, :GR1, :GR1, :CF1].each { |p| checkout.scan(p) }

      expect(checkout.total).to eq(22.45)
    end

    it "When Basket=SR1,SR1,GR1,SR1" do
      checkout = Kantox::Cashier::Checkout.new(pricing)
      [:SR1, :SR1, :GR1, :SR1].each { |p| checkout.scan(p) }

      expect(checkout.total).to eq(16.61)
    end

    it "When Basket=GR1,CF1,SR1,CF1,CF1" do
      checkout = Kantox::Cashier::Checkout.new(pricing)
      [:GR1, :CF1, :SR1, :CF1, :CF1].each { |p| checkout.scan(p) }

      expect(checkout.total).to eq(30.57)
    end
  end
end
