require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :ged_application do
    ged_average_score { 600 }
    created_at { Time.zone.now }
    modified_at { Time.zone.now }
  end
end
