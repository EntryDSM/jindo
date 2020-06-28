require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :ged_application do
    ged_average_score { 600 }
    created_at { DateTime.new(2020) }
    modified_at { DateTime.new(2020) }
  end
end
