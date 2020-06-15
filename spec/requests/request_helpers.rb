require 'jwt_base'

def request(method, url, params = false, headers = false)
  parameters = {}

  parameters[:params] = params if params

  if headers == true
    parameters[:headers] = { Authorization: "Bearer #{@token}" }
  elsif params
    parameters[:headers] = { Authorization: "Bearer #{headers}" }
  end

  send(method, url, parameters)
end

def set_database
  @jwt_base = JWTBase.new(ENV['SECRET_KEY_BASE'], 1.days, 2.weeks)
  @admin = create(:admin)
  @token = @jwt_base.create_access_token(email: @admin.email)
  @user = create(:user)
  @grade_type = @user.grade_type.downcase + '_application'
  create(:status, user_email: @user.email)
  argument = if @grade_type == 'ged_application'
               { user_email: @user.email }
             else
               { school_code: create(:school).school_code, user_email: @user.email }
             end

  create(@grade_type.to_sym, argument)
  create(:calculated_score, user_email: @user.email)
end
