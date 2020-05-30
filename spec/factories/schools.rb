require_relative 'factory_bot_helpers'

FactoryBot.define do
  factory :school do
    school_code { rand(10_000..99_999).to_s }
    school_name { '수완하나중' }
    school_full_name { '수완하나중학교' }
    school_address { '광주광역시 광산구 수완로 105번길 47' }
  end
end
