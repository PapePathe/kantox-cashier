# frozen_string_literal: true

require_relative "cashier/version"
require_relative "cashier/pricing_rule"
require_relative "cashier/checkout"

module Kantox
  module Cashier
    class Error < StandardError; end

    class InputIsNotANumber < Error; end

    class ProductNotFound < Error; end

    DefaultRule = proc do |items_count, unit_price|
      all_numbers = items_count.is_a?(Numeric) && unit_price.is_a?(Numeric)
      raise InputIsNotANumber unless all_numbers

      items_count * unit_price
    end

    PricePercentDiscountRule = proc do |items_count, unit_price|
      all_numbers = items_count.is_a?(Numeric) && unit_price.is_a?(Numeric)
      raise InputIsNotANumber unless all_numbers

      if items_count >= 3
        new_price = (unit_price * 2) / 3

        next items_count * new_price
      end

      items_count * unit_price
    end

    PriceDiscountRule = proc do |items_count, unit_price|
      all_numbers = items_count.is_a?(Numeric) && unit_price.is_a?(Numeric)
      raise InputIsNotANumber unless all_numbers

      if items_count >= 3
        next items_count * 4.50
      end

      items_count * unit_price
    end

    OneBoughtOneOfferedRule = proc do |items_count, unit_price|
      next 0 if items_count.zero?
      next unit_price if items_count == 1

      if items_count.even?
        next (items_count / 2) * unit_price
      end

      ((items_count / 2) * unit_price) + unit_price
    end
  end
end
