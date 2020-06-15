require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Statistics', type: :request do
  before(:all) do
    set_database
  end

  describe 'GET#index' do
    it '> return statistics information when area is nationwide' do
      request('get', '/statistics', { area: 'nationwide' }, true)

      expect(User.statistics(false)).to equal(JSON.parse(response.body))
    end

    it '> return statistics information when area is daejeon' do
      request('get', '/statistics', { area: 'daejeon' }, true)

      expect(User.statistics(true)).to equal(JSON.parse(response.body))
    end

    it '> return statistics information when area is all' do
      request('get', '/statistics', { area: 'all' }, true)

      total_applicant_count = User.count

      all_valid_response = {
        nationwide: User.statistics(false),
        daejeon: User.statistics(true),
        total_applicant_count: total_applicant_count,
        total_competition_rate: (total_applicant_count.to_r / 80).round(2).to_f
      }

      expect(all_valid_response).to equal(JSON.parse(response.body))
    end

    it '> invalid params' do
      request('get', '/statistics', false, true)

      expect(response.status).to equal(400)
    end

    it '> unauthorized token' do
      request('get', '/statistics', { email: @admin.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              '/statistics',
              { email: @user.email },
              @jwt_base.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end

    it '> invalid email' do
      request('get',
              '/statistics',
              { email: 'hello_world@korea.korea' },
              true)

      expect(response.status).to equal(404)
    end
  end
end
