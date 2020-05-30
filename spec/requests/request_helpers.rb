def request(method, url, params = false, headers = false)
  parameters = {}

  if params
    parameters[:params] = params
  end

  if headers == true
    parameters[:headers] = { Authorization: "Bearer #{@token}" }
  elsif params
    parameters[:headers] = { Authorization: "Bearer #{headers}" }
  end

  send(method, url, parameters)
end

def set_database
  @jwt_base = JWTBase.new(ENV['SECRET_KEY_BASE'], 1.days, 2.weeks)
  @token = @jwt_base.create_access_token(email: create(:admin).email)
  @user = create(:user)
  @grade_type = @user.grade_type.downcase + '_application'
  create(:status, user_email: @user.email)
  argument = if @grade_type == 'ged_application'
               { user_email: @user.email }
             else
               { school_code: create(:school).school_code, user_email: @user.email }
             end

  create(@grade_type.to_s, argument)
  create(:calculated_score, user_email: @user.email)
end
