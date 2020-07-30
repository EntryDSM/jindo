FactoryBot.define do
  factory :ged_application do
    ged_average_score { 600 }
    created_at { DateTime.new(2020) }
    modified_at { DateTime.new(2020) }
    ged_pass_date { DateTime.new(2020) }
  end
end
