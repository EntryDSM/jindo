require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :admin do
    email { FFaker::Internet.free_email }
    password { BCrypt::Password.create FFaker::Internet.password }
    name { FFaker::NameKR.name }
  end
end
