module Kantox
  module Cashier
    class Checkout
      attr_reader :pricing_rules
      attr_reader :basket

      def initialize(pricing_rules)
        @pricing_rules = pricing_rules
        @basket = {}
      end

      def scan(product_code)
        if basket.has_key?(product_code)
          basket[product_code] = basket[product_code] + 1
          return
        end

        basket[product_code] = 1
      end

      def total
        total = 0

        basket.each do |product_code, items_count|
          total += pricing_rules.apply(product_code, items_count)
        end

        total
      end
    end
  end
end
