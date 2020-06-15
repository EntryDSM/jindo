require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Authentications', type: :request do
  before(:all) do
    set_database
  end

  describe 'POST#login' do
    it '> return access, refresh tokens' do
      request('post', '/auth', { email: @admin.email,
                                 password: @admin.password }, false)

      resp = JSON.parse(response.body)

      @jwt_base.refresh_token_required(resp['refresh_token'])
      payload = @jwt_base.jwt_required(resp['access_token'])

      expect(payload).to equal('email': @admin.email)
    end

    it '> invalid params' do
      request('post', '/auth', false, false)

      expect(response.status).to equal(400)
    end

    it '> invalid email/password' do
      request('post', '/auth', { email: 'invalid@email.com',
                                 password: 'invalid' }, false)

      expect(response.status).to equal(401)
    end
  end

  describe 'PUT#refresh' do
    it '> return access token' do
      request('put', '/auth', false,
              @jwt_base.create_refresh_token(email: @admin.email))

      resp = JSON.parse(response.body)
      payload = @jwt_base.jwt_required(resp['access_token'])

      expect(payload).to equal('email': @admin.email)
    end

    it '> unauthorized token' do
      request('post', '/auth', false, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('post', '/auth', false, true)

      expect(response.status).to equal(403)
    end
  end
end
