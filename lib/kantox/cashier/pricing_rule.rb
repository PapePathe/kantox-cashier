module Kantox
  module Cashier
    class PricingRule
      attr_accessor :rules
      attr_accessor :products

      def initialize(products)
        @rules = {}
        @products = products
      end

      def add_rule product_code, product_pricing_proc
        raise ProductNotFound unless products[product_code]

        rules[product_code] = product_pricing_proc
      end

      def apply(product_code, items_count)
        rule = rules[product_code]
        product = products[product_code]

        return rule.call(items_count, product[:price]) if rule

        DefaultRule.call(items_count, product[:price])
      end
    end
  end
end
