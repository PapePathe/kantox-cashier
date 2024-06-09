# frozen_string_literal: true

RSpec.describe Kantox::Cashier do
  it "has a version number" do
    expect(Kantox::Cashier::VERSION).not_to be nil
  end

  it "raise error when items count or unit price is not a number" do
    expect { Kantox::Cashier::DefaultRule.call("44", 100) }.to(
      raise_error(Kantox::Cashier::InputIsNotANumber)
    )
    expect { Kantox::Cashier::DefaultRule.call(44, "100") }.to(
      raise_error(Kantox::Cashier::InputIsNotANumber)
    )

    expect { Kantox::Cashier::PricePercentDiscountRule.call("44", 100) }.to(
      raise_error(Kantox::Cashier::InputIsNotANumber)
    )
    expect { Kantox::Cashier::PricePercentDiscountRule.call(44, "100") }.to(
      raise_error(Kantox::Cashier::InputIsNotANumber)
    )

    expect { Kantox::Cashier::PriceDiscountRule.call("44", 100) }.to(
      raise_error(Kantox::Cashier::InputIsNotANumber)
    )
    expect { Kantox::Cashier::PriceDiscountRule.call(44, "100") }.to(
      raise_error(Kantox::Cashier::InputIsNotANumber)
    )
  end
end
