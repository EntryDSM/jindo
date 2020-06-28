require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :calculated_score do
    volunteer_score { 15 }
    attendance_score { 15 }
    conversion_score { 150 }
    final_score { 180 }
    created_at { DateTime.new(2020) }
    modified_at { DateTime.new(2020) }
  end
end
