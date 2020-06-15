require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Applicants', type: :request do
  before(:all) do
    set_database
  end

  describe 'GET#show' do
    it '> return application information' do
      request('get', '/applicant', { email: @user.email }, true)

      expect(@user.applicant_information).to equal(JSON.parse(response.body))
    end

    it '> invalid params' do
      request('get', '/applicant', false, true)

      expect(response.status).to equal(400)
    end

    it '> unauthorized token' do
      request('get', '/applicant', { email: @user.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              '/applicant',
              true,
              @jwt_base.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end

    it '> invalid email' do
      request('get',
              '/applicant',
              { email: 'hello_world@korea.korea' },
              true)

      expect(response.status).to equal(404)
    end
  end

  describe 'GET#index' do
    it '> return application detail information' do
      @index = rand(1..10)
      request('get', '/applicants', { index: @index }, true)

      (@index * 12).times do
        user = create(:user)
        create(:status, user_email: user.email)
      end

      expect(User.applicants_information(@index)).to equal(JSON.parse(response.body))
    end

    it '> unauthorized token' do
      request('get', '/applicants', { index: @index })

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              '/applicants',
              { index: @index },
              @jwt_base.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end
  end

  describe 'PATCH#update' do
    it '> successfully updated ' do
      is_arrived = @user.status.is_printed_application_arrived
      is_paid = @user.status.is_paid
      is_final_submit = @user.status.is_final_submit

      request('patch', '/applicant',
              { email: @user.email,
                is_arrived: !is_arrived }, true)
      expect(!is_arrived).to equal(@user.status.is_printed_application_arrived)

      request('patch', '/applicant',
              { email: @user.email,
                is_paid: !is_paid }, true)
      expect(!is_paid).to equal(@user.status.is_paid)

      request('patch', '/applicant',
              { email: @user.email,
                is_final_submit: !is_final_submit }, true)
      expect(!is_final_submit).to equal(@user.status.is_final_submit)
    end

    it '> invalid params' do
      request('patch', '/applicant', false, true)

      expect(response.status).to equal(400)
    end

    it '> unauthorized token' do
      request('patch', '/applicant', { email: @user.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('patch',
              '/applicant',
              { email: @user.email },
              @jwt_base.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end

    it '> invalid email' do
      request('patch',
              '/applicant',
              { email: 'hello_world@korea.korea' },
              true)

      expect(response.status).to equal(404)
    end
  end
end
