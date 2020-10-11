require 'net/http'

class Admin < ApplicationRecord
  include BCrypt
  include Net

  validates_uniqueness_of :email, presence: true, case_sensitive: true
  validates :password, presence: true

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

  def has_role?(*roles_to_check)
    roles_to_check.map!(&:to_s)
    roles = role.split(',')
    roles_to_check.each { |role| return false unless roles.include?(role) }

    true
  end

  def self.create_exam_code
    submit_users = Status.where(is_passed_first_apply: true).map(&:user)

    distance = submit_users.each_with_object({}) do |user, distance_information|
      convert_request = JSON.parse(request("#{CONVERT_ADDRESS_API}?version=2&searchTypCd=NtoO&"\
                                                   "reqAdd=#{user.address}&appKey=#{ENV['TMAP_APP_KEY']}"))
      x = convert_request['ConvertAdd']['oldLon']
      y = convert_request['ConvertAdd']['oldLat']

      route_request = JSON.parse(request("#{ROUTE_ADDRESS_API}?version=2&totalValue=2&"\
                                                 "appKey=#{ENV['TMAP_APP_KEY']}",
                                         { startX: x, startY: y, endX: 127.36332440, endY: 36.39181879 }))
      distance_information[user.receipt_code] = route_request['features'][0]['properties']['totalDistance']
    end

    receipt_codes_sorted_by_distance = distance.sort_by { |_, v| v }
                                               .map { |v| v[0] }
                                               .reverse

    counts = [[1, 1], [1, 1], [1, 1]]

    receipt_codes_sorted_by_distance.each do |reciept_code|
      user = User.find_by_receipt_code(reciept_code)

      apply_type_code = if user.apply_type == 'COMMON'
                          1
                        elsif user.apply_type == 'MEISTER'
                          2
                        else
                          3
                        end

      region_code = if user.is_daejeon
                      1
                    else
                      2
                    end

      user.status.update!(exam_code: apply_type_code * 10_000 +
                                     region_code * 1_000 +
                                     counts[apply_type_code - 1][region_code - 1])

      counts[apply_type_code - 1][region_code - 1] += 1
    end
  end

  def self.request(url, body = nil)
    url = URI(URI.escape(url))

    https = HTTP.new(url.host, url.port)
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