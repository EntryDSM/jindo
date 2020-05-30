require 'rails_helper'
require 'jwt_base'
require_relative 'request_helpers'

RSpec.describe 'Applicants', type: :request do
  before(:all) do
    set_database
  end

  describe 'GET#show' do
    it '> return application information' do
      request('get', '/applicants', { email: @user.email }, true)

      valid_response = { applicant_information: {
        status: {
          is_paid: @user.status.is_paid,
          is_arrived: @user.status.is_printed_application_arrived,
          is_final_submit: @user.status.is_final_submit
        },

        privacy: {
          user_photo: @user.user_photo,
          name: @user.name,
          birth_date: @user.birth_date,
          grade_type: @user.grade_type,
          apply_type: @user.apply_type,
          applicant_tel: @user.applicant_tel,
          parent_tel: @user.parent_tel,
          home_tel: @user.home_tel,
          email: @user.email
        },

        evaluation: {
          conversion_score: @user.calculated_score.conversion_score,
          self_introduction: @user.self_introduction,
          study_plan: @user.study_plan
        }
      } }

      unless @user.grade_type == 'GED'
        @user = @user.send(@grade_type)
        privacy = valid_response[:applicant_information][:privacy]
        evaluation = valid_response[:applicant_information][:evaluation]

        privacy[:school_name] = @user.school.school_full_name
        privacy[:school_address] = @user.school.school_address
        privacy[:school_tel] = @user.school_tel
        evaluation[:volunteer_time] = @user.volunteer_time
        evaluation[:full_absent_count] = @user.full_cut_count
        evaluation[:early_leave_count] = @user.early_leave_count
        evaluation[:late_count] = @user.late_count
        evaluation[:period_absent_count] = @user.period_cut_count

        valid_response[:applicant_information][:privacy] = privacy
        valid_response[:applicant_information][:evaluation] = evaluation
      end

      expect(response.body).to equal(valid_response)
    end

    it '> invalid params' do
      request('get', '/applicants', false, true)

      expect(response.status).to equal(400)
    end

    it '> unauthorized token' do
      request('get', '/applicants', { email: @user.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              '/applicants',
              true,
              @jwt_base.create_refresh_token(email: @user.email))

      expect(response.status).to equal(403)
    end

    it '> invalid email' do
      request('get',
              '/applicants',
              { email: 'hello_world@korea.korea' },
              true)

      expect(response.status).to equal(404)
    end
  end

  describe 'GET#index' do
    it '> return application detail information' do
      index = rand(1..10)
      request('get', "/applicants/#{index}", false, true)

      valid_response = { applicants: [] }

      (index * 12).times do
        user = create(:user)
        create(:status, user_email: user.email)
      end

      User.order(created_at: :desc)
          .offset((index - 1) * 12).limit(12).each do |user|
        application_information = {
          examination_number: user.status.exam_code,
          name: user.name,
          is_daejeon: user.is_daejeon,
          apply_type: user.apply_type,
          is_arrived: user.status.is_printed_application_arrived,
          is_paid: user.status.is_paid,
          is_final_submit: user.status.is_final_submit
        }

        valid_response[:applicants] << application_information
      end

      expect(response.body).to equal(valid_response)
    end

    it '> unauthorized token' do
      request('get', '/applicants/1')

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              '/applicants/1',
              false,
              @jwt_base.create_refresh_token(email: @user.email))

      expect(response.status).to equal(403)
    end
  end

  describe 'PATCH#update' do
    it '> successfully updated ' do
      is_arrived = @user.status.is_printed_application_arrived
      is_paid = @user.status.is_paid
      is_final_submit = @user.status.is_final_submit

      request('patch', '/applicants',
              { email: @user.email,
                is_arrived: !is_arrived }, true)
      expect(!is_arrived).to equal(@user.status.is_printed_application_arrived)

      request('patch', '/applicants',
              { email: @user.email,
                is_arrived: !is_paid }, true)
      expect(!is_paid).to equal(@user.status.is_paid)

      request('patch', '/applicants',
              { email: @user.email,
                is_arrived: !is_final_submit }, true)
      expect(!is_final_submit).to equal(@user.status.is_final_submit)
    end

    it '> invalid params' do
      request('patch', '/applicants', false, true)

      expect(response.status).to equal(400)
    end

    it '> unauthorized token' do
      request('patch', '/applicants', { email: @user.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('patch',
              '/applicants',
              true,
              @jwt_base.create_refresh_token(email: @user.email))

      expect(response.status).to equal(403)
    end

    it '> invalid email' do
      request('patch',
              '/applicants',
              { email: 'hello_world@korea.korea' },
              true)

      expect(response.status).to equal(404)
    end
  end
end
