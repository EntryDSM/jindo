def cellphone
  number = FFaker::PhoneNumberKR.mobile_phone_number
  number[3] = '-'
  number[8] = '-'
  number
end

def telephone
  number = FFaker::PhoneNumberKR.home_work_phone_number
  number.each_char.with_index do |value, index|
    number[index] = '-' if value == ' '
  end
end

def rand_boolean
  [true, false].sample
end