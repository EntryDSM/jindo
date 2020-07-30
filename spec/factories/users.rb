FactoryBot.define do
  factory :user do
    email { 'wjd030811@dsm.hs.kr' }
    password { 'q1w2e3r4' }
    receipt_code { 1 }
    apply_type { 'MEISTER' }
    additional_type { 'NOT_APPLICABLE' }
    grade_type { 'UNGRADUATED' }
    is_daejeon { 0 }
    name { '정우영' }
    sex { 'MALE' }
    birth_date { '2005-01-01 00:00' }
    parent_name { '엄마' }
    parent_tel { '010-0000-0000' }
    applicant_tel { '010-0000-0000' }
    address { '광주광역시' }
    detail_address { '"상세주소"' }
    post_code { '12345' }
    user_photo { '/home/ubuntu/image.jpg' }
    self_introduction { '"자기소개"' }
    study_plan { '"학습 계획"' }
    created_at { DateTime.new(2020) }
    modified_at { DateTime.new(2020) }
  end
end