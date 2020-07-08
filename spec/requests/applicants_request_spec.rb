require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Applicants', type: :request do
  before(:all) do
    set_database
    @url_applicant = URL_PREFIX + '/applicant'
    @url_applicants = URL_PREFIX + '/applicants'
  end

  describe 'GET#show' do
    it '> return application information' do
      request('get', @url_applicant, { email: @user.email }, true)

      expected = {
        applicant_information: {
          status: {
            is_paid: true,
            is_arrived: true,
            is_final_submit: true
          },
          privacy: {
            user_photo: '/home/ubuntu/image.jpg',
            name: '정우영',
            birth_date: '2005-01-01',
            grade_type: 'UNGRADUATED',
            apply_type: 'MEISTER',
            address: '"주소"',
            detail_address: '"상세주소"',
            applicant_tel: '010-0000-0000',
            parent_tel: '010-0000-0000',
            home_tel: '070-0000-0000',
            email: 'wjd030811@dsm.hs.kr',
            school_name: '수완하나중학교',
            school_tel: '010-0000-0000'
          },
          evaluation: {
            conversion_score: 150,
            self_introduction: '"자기소개"',
            study_plan: '"학습 계획"',
            volunteer_time: 50,
            full_absent_count: 0,
            early_leave_count: 0,
            late_count: 0,
            period_absent_count: 0
          }
        }
      }

      expect(expected).to eql(JSON.parse(response.body, symbolize_names: true))
    end

    it '> unauthorized token' do
      request('get', @url_applicant, { email: @user.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              @url_applicant,
              true,
              JWT_BASE.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end

    it '> invalid email' do
      request('get',
              @url_applicant,
              { email: 'hello_world@korea.korea' },
              true)

      expect(response.status).to equal(404)
    end
  end

  describe 'GET#index' do
    it '> return application detail information' do
      request('get', @url_applicants, { index: 1 }, true)

      expected = {
        applicants_information: [{
          examination_number: '123456',
          name: '정우영',
          is_daejeon: false,
          apply_type: 'MEISTER',
          is_arrived: true,
          is_paid: true,
          is_final_submit: true
        }]
      }

      expect(expected).to(eql(JSON.parse(response.body, symbolize_names: true)))
    end

    it '> unauthorized token' do
      request('get', @url_applicants, { index: 1 })

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              @url_applicants,
              { index: 1 },
              JWT_BASE.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end
  end

  describe 'PATCH#update' do
    it '> is_arrived successfully updated ' do
      is_arrived = @user.status.is_printed_application_arrived

      request('patch', @url_applicant,
              { email: @user.email,
                is_arrived: !is_arrived }, true)

      expect(!is_arrived).to equal(User.find_by_email(@user.email)
                                       .status
                                       .is_printed_application_arrived)
    end

    it '> is_paid successfully updated' do
      is_paid = @user.status.is_paid

      request('patch', @url_applicant,
              { email: @user.email,
                is_paid: !is_paid }, true)

      expect(!is_paid).to equal(User.find_by_email(@user.email)
                                    .status
                                    .is_paid)
    end

    it '> is_final_submit successfully updated' do
      is_final_submit = @user.status.is_final_submit

      request('patch', @url_applicant,
              { email: @user.email,
                is_final_submit: !is_final_submit }, true)

      expect(!is_final_submit).to equal(User.find_by_email(@user.email)
                                            .status
                                            .is_final_submit)
    end

    it '> unauthorized token' do
      request('patch', @url_applicant, { email: @user.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('patch',
              @url_applicant,
              { email: @user.email },
              JWT_BASE.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end

    it '> invalid email' do
      request('patch',
              @url_applicant,
              { email: 'hello_world@korea.korea' },
              true)

      expect(response.status).to equal(404)
    end
  end
end
