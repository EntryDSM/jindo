require 'net/http'

class Admin < ApplicationRecord
  validates_uniqueness_of :email, presence: true, case_sensitive: true
  validates :password, presence: true

  include BCrypt
  include Net

  self.primary_key = :email

  CONVERT_ADDRESS_API = 'https://apis.openapi.sk.com/tmap/geo/convertAddress'.freeze
  ROUTE_ADDRESS_API = 'https://apis.openapi.sk.com/tmap/routes'.freeze

  def password_decryption
    Password.new(password)
  end

  def password_encryption=(new_password)
    update!(password: Password.create(new_password))
  end

  def self.create!(**kwargs)
    instance = super kwargs
    instance.password = Password.create(instance.password)
    instance.save

    instance
  end

  def self.create_exam_code
    classifications = [[User.where(apply_type: 'COMMON', is_daejeon: true),
                        User.where(apply_type: 'COMMON', is_daejeon: false)],
                       [User.where(apply_type: 'MEISTER', is_daejeon: true),
                        User.where(apply_type: 'MEISTER', is_daejeon: false)],
                       [User.where.not(apply_type: %w[COMMON MEISTER]).where(is_daejeon: true),
                        User.where.not(apply_type: %w[COMMON MEISTER]).where(is_daejeon: false)]]

    classifications.each_with_index do |applies, apply_index|
      applies.each_with_index do |area, area_index|
        distance = area.each_with_object({}) do |user, distance_information|
          convert_request = JSON.parse(request("#{CONVERT_ADDRESS_API}?version=2&searchTypCd=NtoO&"\
                                    "reqAdd=#{user.address}&appKey=#{ENV['TMAP_APP_KEY']}"))
          x = convert_request['ConvertAdd']['oldLon']
          y = convert_request['ConvertAdd']['oldLat']

          route_request = JSON.parse(request("#{ROUTE_ADDRESS_API}?version=2&totalValue=2&"\
                                                 "appKey=#{ENV['TMAP_APP_KEY']}",
                                             { startX: x, startY: y, endX: 127.36332440, endY: 36.39181879 }))
          distance_information[user.receipt_code] = route_request['features'][0]['properties']['totalDistance']
        end

        users_sorted_by_distance = distance.sort_by { |_, v| v }.map { |v| v[0] }
        users_sorted_by_distance.inject(1) do |reciept_code, count|
          User.find_by_receipt_code(reciept_code)
              .status
              .update!(exam_code: ((apply_index + 1) * 10_000 +
                                   (area_index + 1) * 1_000 +
                                    count).to_s)
          count + 1
        end
      end
    end
  end

  def self.request(url, body = nil)
    url = URI(URI.escape(url))

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = if body
                HTTP::Post.new(url)
              else
                HTTP::Get.new(url)
              end
    request['Content-Type'] = 'application/json'
    request.body = JSON(body)

    https.request(request).read_body
  end
end