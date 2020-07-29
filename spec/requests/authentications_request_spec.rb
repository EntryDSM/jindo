require 'rails_helper'
require_relative 'request_helper'

RSpec.describe 'Authentications', type: :request do
  before(:all) do
    set_database
    @url_auth = URL_PREFIX + '/auth'
  end

  describe 'POST#login' do
    it '> return access, refresh tokens' do
      request('post', @url_auth, { email: @admin.email,
                                   password: 'q1w2e3r4' }, false)

      resp = JSON.parse(response.body)

      JWT_BASE.refresh_token_required(resp['refresh_token'])
      payload = JWT_BASE.jwt_required(resp['access_token'])

      expect(payload['email']).to eql(@admin.email)
    end

    it '> invalid email/password' do
      request('post', @url_auth, { email: 'invalid@email.com',
                                   password: 'invalid' }, false)

      expect(response.status).to equal(401)
    end
  end

  describe 'PUT#refresh' do
    it '> return access token' do
      request('put',
              @url_auth,
              { dummy: '' },
              JWT_BASE.create_refresh_token(email: @admin.email))

      resp = JSON.parse(response.body)
      payload = JWT_BASE.jwt_required(resp['access_token'])

      expect(payload['email']).to eql(@admin.email)
    end

    it '> unauthorized token' do
      request('put', @url_auth, { dummy: '' }, false)

      expect(response.status).to eql(403)
    end

    it '> invalid type of token' do
      request('put', @url_auth, false, true)

      expect(response.status).to equal(403)
    end
  end
end
