require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :status do
    is_paid { rand_boolean }
    is_printed_application_arrived { rand_boolean }
    is_passed_first_apply { rand_boolean }
    is_passed_interview { rand_boolean }
    is_final_submit { rand_boolean }
    submitted_at { Time.zone.now }
    exam_code { '123456' }
  end
end