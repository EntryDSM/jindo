require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :calculated_score do
    volunteer_score { 15 }
    attendance_score { 15 }
    conversion_score { 150 }
    final_score { 180 }
    created_at { Time.zone.now }
    modified_at { Time.zone.now }
  end
end
