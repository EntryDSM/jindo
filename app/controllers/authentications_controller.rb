class AuthenticationsController < ApplicationController
  before_action :refresh_token_required, only: :refresh

  def login
    params.require(%i[email password])

    admin = Admin.find_by_email(params[:email])

    return render status: :unauthorized unless admin
    return render status: :unauthorized unless admin.password_decryption == params[:password]

    render json: { access_token: @@jwt_base.create_access_token(email: admin.email),
                   refresh_token: @@jwt_base.create_refresh_token(email: admin.email) },
           status: :ok
  end

  def refresh
    render json: { access_token: @@jwt_base.create_access_token(email: @payload['email']) },
           status: :ok
  end
end
