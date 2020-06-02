require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :graduated_application do
    student_number { '30535' }
    school_tel { telephone }
    volunteer_time { rand(100) }
    full_cut_count { 0 }
    period_cut_count { 0 }
    late_count { 0 }
    early_leave_count { 0 }
    korean { 'A' }
    social { 'A' }
    history { 'A' }
    math { 'A' }
    science { 'A' }
    tech_and_home { 'A' }
    english { 'A' }
    created_at { Time.zone.now }
    modified_at { Time.zone.now }
  end
end
