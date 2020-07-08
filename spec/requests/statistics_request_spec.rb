require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Statistics', type: :request do
  before(:all) do
    set_database
    @url_statistics = URL_PREFIX + '/statistics'
  end

  describe 'GET#index' do
    it '> return statistics information when area is nationwide' do
      request('get', @url_statistics, { area: 'nationwide' }, true)

      expected = {
        meister_applicant: {
          applicant_count: 1,
          competition_rate: 0.06,
          '-70': 0,
          '71-80': 0,
          '81-90': 0,
          '91-100': 0,
          '101-110': 0,
          '111-120': 0,
          '121-130': 0,
          '131-140': 0,
          '141-150': 1
        },
        common_applicant: {
          applicant_count: 0,
          competition_rate: 0.0,
          '-70': 0,
          '71-80': 0,
          '81-90': 0,
          '91-100': 0,
          '101-110': 0,
          '111-120': 0,
          '121-130': 0,
          '131-140': 0,
          '141-150': 0
        },
        social_applicant: {
          applicant_count: 0,
          competition_rate: 0.0,
          '-70': 0,
          '71-80': 0,
          '81-90': 0,
          '91-100': 0,
          '101-110': 0,
          '111-120': 0,
          '121-130': 0,
          '131-140': 0,
          '141-150': 0
        },
        total_applicant_count: 1,
        total_competition_rate: 0.03
      }

      expect(expected)
        .to(eql(JSON.parse(response.body, symbolize_names: true)))
    end

    it '> return statistics information when area is daejeon' do
      request('get', @url_statistics, { area: 'daejeon' }, true)

      expected = {
        meister_applicant: {
          applicant_count: 0,
          competition_rate: 0.0,
          '-70': 0,
          '71-80': 0,
          '81-90': 0,
          '91-100': 0,
          '101-110': 0,
          '111-120': 0,
          '121-130': 0,
          '131-140': 0,
          '141-150': 0
        },
        common_applicant: {
          applicant_count: 0,
          competition_rate: 0.0,
          '-70': 0,
          '71-80': 0,
          '81-90': 0,
          '91-100': 0,
          '101-110': 0,
          '111-120': 0,
          '121-130': 0,
          '131-140': 0,
          '141-150': 0
        },
        social_applicant: {
          applicant_count: 0,
          competition_rate: 0.0,
          '-70': 0,
          '71-80': 0,
          '81-90': 0,
          '91-100': 0,
          '101-110': 0,
          '111-120': 0,
          '121-130': 0,
          '131-140': 0,
          '141-150': 0
        },
        total_applicant_count: 0,
        total_competition_rate: 0.0
      }

      expect(expected).to(eql(JSON.parse(response.body, symbolize_names: true)))
    end

    it '> return statistics information when area is all' do
      request('get', @url_statistics, { area: 'all' }, true)

      expected = {
        nationwide: {
          meister_applicant: {
            applicant_count: 1,
            competition_rate: 0.06,
            '-70': 0,
            '71-80': 0,
            '81-90': 0,
            '91-100': 0,
            '101-110': 0,
            '111-120': 0,
            '121-130': 0,
            '131-140': 0,
            '141-150': 1
          },
          common_applicant: {
            applicant_count: 0,
            competition_rate: 0.0,
            '-70': 0,
            '71-80': 0,
            '81-90': 0,
            '91-100': 0,
            '101-110': 0,
            '111-120': 0,
            '121-130': 0,
            '131-140': 0,
            '141-150': 0
          },
          social_applicant: {
            applicant_count: 0,
            competition_rate: 0.0,
            '-70': 0,
            '71-80': 0,
            '81-90': 0,
            '91-100': 0,
            '101-110': 0,
            '111-120': 0,
            '121-130': 0,
            '131-140': 0,
            '141-150': 0
          },
          total_applicant_count: 1,
          total_competition_rate: 0.03
        },

        daejeon: {
          meister_applicant: {
            applicant_count: 0,
            competition_rate: 0.0,
            '-70': 0,
            '71-80': 0,
            '81-90': 0,
            '91-100': 0,
            '101-110': 0,
            '111-120': 0,
            '121-130': 0,
            '131-140': 0,
            '141-150': 0
          },
          common_applicant: {
            applicant_count: 0,
            competition_rate: 0.0,
            '-70': 0,
            '71-80': 0,
            '81-90': 0,
            '91-100': 0,
            '101-110': 0,
            '111-120': 0,
            '121-130': 0,
            '131-140': 0,
            '141-150': 0
          },
          social_applicant: {
            applicant_count: 0,
            competition_rate: 0.0,
            '-70': 0,
            '71-80': 0,
            '81-90': 0,
            '91-100': 0,
            '101-110': 0,
            '111-120': 0,
            '121-130': 0,
            '131-140': 0,
            '141-150': 0
          },
          total_applicant_count: 0,
          total_competition_rate: 0.0
        },
        "total_applicant_count": 1,
        "total_competition_rate": 0.01
      }

      expect(expected)
        .to(eql(JSON.parse(response.body, symbolize_names: true)))
    end

    it '> unauthorized token' do
      request('get', @url_statistics, { email: @admin.email }, false)

      expect(response.status).to equal(401)
    end

    it '> invalid type of token' do
      request('get',
              @url_statistics,
              { email: @user.email },
              JWT_BASE.create_refresh_token(email: @admin.email))

      expect(response.status).to equal(403)
    end
  end
end
