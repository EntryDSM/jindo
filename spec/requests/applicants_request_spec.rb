require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Applicants', type: :request do
  before(:all) do
    set_database
  end

  describe 'GET#show' do
    it '> return application information' do
      request('get', '/applicant', { email: @user.email }, true)

      expect(@user.applicant_information).to eql(JSON.parse(response.body, symbolize_names: true))
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
      @index = 1
      request('get', '/applicants', { index: @index }, true)

      expect(applicants_information: User.applicants_information(@index))
        .to(eql(JSON.parse(response.body, symbolize_names: true)))
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
    it '> is_arrived successfully updated ' do
      is_arrived = @user.status.is_printed_application_arrived

      request('patch', '/applicant',
              { email: @user.email,
                is_arrived: !is_arrived }, true)

      expect(!is_arrived).to equal(User.find_by_email(@user.email)
                                       .status
                                       .is_printed_application_arrived)
    end

    it '> is_paid successfully updated' do
      is_paid = @user.status.is_paid

      request('patch', '/applicant',
              { email: @user.email,
                is_paid: !is_paid }, true)

      expect(!is_paid).to equal(User.find_by_email(@user.email)
                                    .status
                                    .is_paid)
    end

    it '> is_final_submit successfully updated' do
      is_final_submit = @user.status.is_final_submit

      request('patch', '/applicant',
              { email: @user.email,
                is_final_submit: !is_final_submit }, true)

      expect(!is_final_submit).to equal(User.find_by_email(@user.email)
                                            .status
                                            .is_final_submit)
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
