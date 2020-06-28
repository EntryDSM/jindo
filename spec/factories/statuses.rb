require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :status do
    is_paid { true }
    is_printed_application_arrived { true }
    is_passed_first_apply { true }
    is_passed_interview { true }
    is_final_submit { true }
    submitted_at { DateTime.new(2020) }
    exam_code { '123456' }
  end
end