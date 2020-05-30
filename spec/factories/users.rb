require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.free_email }
    password { FFaker::Internet.password }
    receipt_number { 1 }
    apply_type { rand(0..7) }
    additional_type { rand(0..2) }
    grade_type { rand(1..2) }
    is_daejeon { rand_boolean }
    name { FFaker::NameKR.name }
    sex { rand(0..1) }
    birth_date { FFaker::Time.between('2005-01-01 00:00', '2005-12-31 23:59') }
    parent_name { FFaker::NameKR.name }
    parent_tel { cellphone }
    applicant_tel { cellphone }
    address { FFaker::AddressKR.road_addess }
    post_code { FFaker::AddressKR.postal_code }
    user_photo { '/home/ubuntu/image.jpg' }
    home_tel { telephone }
    self_introduction { FFaker::Tweet.tweet }
    study_plan { FFaker::Tweet.body }
    created_at { Time.zone.now }
  end
end