FactoryBot.define do
  factory :graduated_application do
    student_number { '30535' }
    school_tel { '010-0000-0000' }
    volunteer_time { '50' }
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
    created_at { DateTime.new(2020) }
    modified_at { DateTime.new(2020) }
  end
end
