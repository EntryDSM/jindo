class AuthenticationsController < ApplicationController
  before_action :jwt_required, only: :login
  before_action :refresh_token_required, only: :refresh

  def login

  end

  def refresh

  end
end
