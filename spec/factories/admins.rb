FactoryBot.define do
  factory :admin do
    email { 'admin@dsm.hs.kr' }
    password { BCrypt::Password.create('q1w2e3r4') }
    name { '어드민' }
  end
end
