class User < ApplicationRecord
  self.primary_key = :email

  enum apply_type: %w[COMMON MEISTER SOCIAL_ONE_PARENT SOCIAL_FROM_NORTH
                      SOCIAL_MULTICULTURAL SOCIAL_BASIC_LIVING
                      SOCIAL_LOWEST_INCOME SOCIAL_TEEN_HOUSEHOLDER]
  enum additional_type: %w[NATIONAL_MERIT PRIVILEGED_ADMISSION NOT_APPLICABLE]
  enum grade_type: %w[GED UNGRADUATED GRADUATED]
  enum sex: %w[MALE FEMALE]

  has_one :ged_application, foreign_key: :user_email
  has_one :graduated_application, foreign_key: :user_email
  has_one :ungraduated_application, foreign_key: :user_email
  has_one :status, foreign_key: :user_email
  has_one :calculated_score, foreign_key: :user_email

  def self.score_distribution(key, value, is_daejeon)
    (70..150).step(10).each do |i|
      conversion_score_query = if i > 70
                                 "conversion_score BETWEEN #{i - 9} AND #{i}"
                               else
                                 'conversion_score <= 70'
                               end

      applicant_count = if key != :social_applicant
                          User.joins(:calculated_score)
                              .where(conversion_score_query)
                              .where(apply_type: key[0..-11].upcase,
                                     is_daejeon: is_daejeon).count
                        else
                          User.joins(:calculated_score)
                              .where.not(apply_type: %w[COMMON MEISTER])
                              .where(conversion_score_query)
                              .where(is_daejeon: is_daejeon).count
                        end

      if i > 70
        value[:"#{i - 9}-#{i}"] = applicant_count
      else
        value[:'-70'] = applicant_count
      end
    end
  end

  def self.statistics(is_daejeon)
    meister_applicant_count = User.where(apply_type: 'MEISTER', is_daejeon: is_daejeon).count
    common_applicant_count = User.where(apply_type: 'COMMON', is_daejeon: is_daejeon).count
    social_applicant_count = User.where.not(apply_type: %w[MEISTER COMMON])
                                 .where(is_daejeon: is_daejeon).count

    total_applicant_count = meister_applicant_count +
                            common_applicant_count +
                            social_applicant_count

    meister_passer_count = if is_daejeon
                             12
                           else
                             16
                           end

    common_passer_count = if is_daejeon
                            18
                          else
                            30
                          end

    total_passer_count = if is_daejeon
                           32
                         else
                           48
                         end

    response = {
      meister_applicant: {
        applicant_count: meister_applicant_count,
        competition_rate: (meister_applicant_count.to_r /
                           meister_passer_count).round(2).to_f
      },

      common_applicant: {
        applicant_count: common_applicant_count,
        competition_rate: (common_applicant_count.to_r /
                           common_passer_count).round(2).to_f
      },

      social_applicant: {
        applicant_count: social_applicant_count,
        competition_rate: (social_applicant_count.to_r / 2).round(2).to_f
      },

      total_applicant_count: total_applicant_count,
      total_competition_rate: (total_applicant_count.to_r /
                               total_passer_count).round(2).to_f
    }

    response.each do |k, v|
      score_distribution(k, v, is_daejeon) if v.class == Hash
    end

    response
  end
end
