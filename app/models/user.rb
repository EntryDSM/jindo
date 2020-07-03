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

  FILTERS = %i[email exam_code school_name applicant_tel name].freeze
  USER_PER_PAGE = 12

  MEISTER_PASSER_COUNT = 18
  SOCIAL_PASSER_COUNT = 2
  COMMON_PASSER_COUNT = 20
  TOTAL_PASSER_COUNT = 40


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

    response = {
      meister_applicant: {
        applicant_count: meister_applicant_count,
        competition_rate: (meister_applicant_count.to_r /
                           MEISTER_PASSER_COUNT).round(2).to_f
      },

      common_applicant: {
        applicant_count: common_applicant_count,
        competition_rate: (common_applicant_count.to_r /
                           COMMON_PASSER_COUNT).round(2).to_f
      },

      social_applicant: {
        applicant_count: social_applicant_count,
        competition_rate: (social_applicant_count.to_r /
                           SOCIAL_PASSER_COUNT).round(2).to_f
      },

      total_applicant_count: total_applicant_count,
      total_competition_rate: (total_applicant_count.to_r /
                               TOTAL_PASSER_COUNT).round(2).to_f
    }

    response.each do |k, v|
      score_distribution(k, v, is_daejeon) if v.class == Hash
    end

    response
  end

  def applicant_information
    response = { applicant_information: {
      status: {
        is_paid: status.is_paid,
        is_arrived: status.is_printed_application_arrived,
        is_final_submit: status.is_final_submit
      },

      privacy: {
        user_photo: user_photo,
        name: name,
        birth_date: birth_date.strftime('%Y-%m-%d'),
        grade_type: grade_type,
        apply_type: apply_type,
        address: address,
        detail_address: detail_address,
        applicant_tel: applicant_tel,
        parent_tel: parent_tel,
        home_tel: home_tel,
        email: email
      },

      evaluation: {
        conversion_score: calculated_score.conversion_score,
        self_introduction: self_introduction,
        study_plan: study_plan
      }
    } }

    return response if grade_type == 'GED'

    applicant_type = send(grade_type.downcase + '_application')
    privacy = response[:applicant_information][:privacy]
    evaluation = response[:applicant_information][:evaluation]

    privacy[:school_name] = applicant_type.school.school_full_name
    privacy[:school_tel] = applicant_type.school_tel
    evaluation[:volunteer_time] = applicant_type.volunteer_time
    evaluation[:full_absent_count] = applicant_type.full_cut_count
    evaluation[:early_leave_count] = applicant_type.early_leave_count
    evaluation[:late_count] = applicant_type.late_count
    evaluation[:period_absent_count] = applicant_type.period_cut_count

    response[:applicant_information][:privacy] = privacy
    response[:applicant_information][:evaluation] = evaluation

    response
  end

  def applicants_information
    return nil if nil?

    {
      examination_number: status.exam_code,
      name: name,
      is_daejeon: is_daejeon,
      apply_type: apply_type,
      is_arrived: status.is_printed_application_arrived,
      is_paid: status.is_paid,
      is_final_submit: status.is_final_submit
    }
  end

  def self.applicants_information(index, presence_filter = nil, filter_value = nil)
    return [] if index < 1

    case presence_filter
    when 0
      User.where('email LIKE ?', "%#{filter_value}%")
          .order(created_at: :desc)
          .offset((index - 1) * USER_PER_PAGE)
          .limit(USER_PER_PAGE)
          .map(&:applicants_information)
          .compact
    when 1
      status = Status.find_by_exam_code(filter_value)
      return [] if status.nil?

      [status.user.applicants_information]
    when 2
      graduated_email = School.find_by_school_full_name(filter_value)
                              .graduated_application_ids
      ungraduated_email = School.find_by_school_full_name(filter_value)
                                .ungraduated_application_ids

      graduated_user = GraduatedApplication.where('user_email IN (?)', graduated_email)
      ungraduated_user = UngraduatedApplication.where('user_email IN (?)', ungraduated_email)

      users = graduated_user.map { |app| app.user.applicants_information }.compact +
              ungraduated_user.map { |app| app.user.applicants_information }.compact

      users[(index - 1) * USER_PER_PAGE, index * USER_PER_PAGE - 1]
    when 3
      user = User.find_by_applicant_tel(filter_value)
      return [] if user.nil?

      [user.applicants_information]
    when 4
      User.where('name LIKE ?', "%#{filter_value}%")
          .order(created_at: :desc)
          .offset((index - 1) * USER_PER_PAGE)
          .limit(USER_PER_PAGE)
          .map(&:applicants_information)
          .compact
    else
      User.order(created_at: :desc)
          .offset((index - 1) * USER_PER_PAGE)
          .limit(USER_PER_PAGE)
          .map(&:applicants_information)
          .compact
    end
  end
end
