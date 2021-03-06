require 'jwt_base'

JWT_BASE = JWTBase.new(ENV['SECRET_KEY_BASE'], 1.days, 2.weeks).freeze
URL_PREFIX = '/v5/admin'.freeze

def request(method, url, params = false, headers = false)
  parameters = {}

  parameters[:params] = params if params

  if headers == true
    parameters[:headers] = { Authorization: "Bearer #{@token}" }
  elsif headers
    parameters[:headers] = { Authorization: "Bearer #{headers}" }
  end

  send(method, url, parameters)
end

def set_database
  @admin = create(:admin)
  @token = JWT_BASE.create_access_token(identity: @admin.email)
  @user = create(:user)

  create(:status, user_receipt_code: @user.receipt_code)
  create(:ungraduated_application,
         school_code: create(:school).school_code,
         user_receipt_code: @user.receipt_code)
  create(:calculated_score, user_receipt_code: @user.receipt_code)
end
