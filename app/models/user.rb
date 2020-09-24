class User < ApplicationRecord
  self.primary_key = :receipt_code

  enum apply_type: { COMMON: 'COMMON', MEISTER: 'MEISTER',
                     SOCIAL_ONE_PARENT: 'SOCIAL_ONE_PARENT',
                     SOCIAL_FROM_NORTH: 'SOCIAL_FROM_NORTH',
                     SOCIAL_MULTICULTURAL: 'SOCIAL_MULTICULTURAL',
                     SOCIAL_BASIC_LIVING: 'SOCIAL_BASIC_LIVING',
                     SOCIAL_LOWEST_INCOME: 'SOCIAL_LOWEST_INCOME',
                     SOCIAL_TEEN_HOUSEHOLDER: 'SOCIAL_TEEN_HOUSEHOLDER' }
  enum additional_type: { NATIONAL_MERIT: 'NATIONAL_MERIT',
                          PRIVILEGED_ADMISSION: 'PRIVILEGED_ADMISSION',
                          NOT_APPLICABLE: 'NOT_APPLICABLE' }
  enum grade_type: { GED: 'GED', UNGRADUATED: 'UNGRADUATED', GRADUATED: 'GRADUATED' }
  enum sex: { MALE: 'MALE', FEMALE: 'FEMALE' }

  has_one :ged_application, foreign_key: :user_receipt_code
  has_one :graduated_application, foreign_key: :user_receipt_code
  has_one :ungraduated_application, foreign_key: :user_receipt_code
  has_one :status, foreign_key: :user_receipt_code
  has_one :calculated_score, foreign_key: :user_receipt_code

  FILTERS = %i[email receipt_code school_name applicant_tel name].freeze
  USER_PER_PAGE = 12

  MEISTER_PASSER_COUNT = 18
  SOCIAL_PASSER_COUNT = 2
  COMMON_PASSER_COUNT = 20
  TOTAL_PASSER_COUNT = 40

  def self.statistics(is_daejeon)
    meister_applicant_count = User.joins(:status)
                                  .where(apply_type: 'MEISTER', is_daejeon: is_daejeon)
                                  .where('is_final_submit = ?', true)
                                  .count
    common_applicant_count = User.joins(:status)
                                 .where(apply_type: 'COMMON', is_daejeon: is_daejeon)
                                 .where('is_final_submit = ?', true)
                                 .count
    social_applicant_count = User.joins(:status)
                                 .where.not(apply_type: %w[MEISTER COMMON])
                                 .where(is_daejeon: is_daejeon)
                                 .where('is_final_submit = ?', true)
                                 .count

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

  def self.score_distribution(key, value, is_daejeon)
    (70..150).step(10).each do |i|
      conversion_score_query = if i > 70
                                 "conversion_score BETWEEN #{i - 9} AND #{i}"
                               else
                                 'conversion_score <= 70'
                               end

      applicant_count = if key != :social_applicant
                          User.joins(%i[calculated_score status])
                              .where('is_final_submit = ?', true)
                              .where(conversion_score_query)
                              .where(apply_type: key[0..-11].upcase,
                                     is_daejeon: is_daejeon)
                              .count
                        else
                          User.joins(%i[calculated_score status])
                              .where('is_final_submit = ?', true)
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

  def self.applicants_information(index, presence_filter = nil, filter_value = nil, **filters)
    searched_result = search(presence_filter, filter_value)
    filtered_result = filter(searched_result, **filters)

    {
      max_index: filtered_result.count / USER_PER_PAGE + 1,
      user_per_page: USER_PER_PAGE,
      applicants_information: filtered_result[(index - 1) * USER_PER_PAGE,
                                              index * USER_PER_PAGE - 1]
    }
  end

  def self.search(presence_filter, filter_value)
    case presence_filter
    when 0
      where('email LIKE ?', "%#{filter_value}%")
    when 1
      status = Status.where('receipt_code LIKE ?', "%#{filter_value}%")
      status.map(&:user)
    when 2
      schools = School.where('school_full_name LIKE ?', "%#{filter_value}%")

      receipt_codes = schools.flat_map(&:graduated_application_ids) +
                      schools.flat_map(&:ungraduated_application_ids)

      GraduatedApplication.where('user_receipt_code IN (?)', receipt_codes).map(&:user) +
        UngraduatedApplication.where('user_receipt_code IN (?)', receipt_codes).map(&:user)
    when 3
      where('applicant_tel LIKE ?', "%#{filter_value}%")
    when 4
      where('name LIKE ?', "%#{filter_value}%")
    else
      all
    end.sort_by(&:created_at).map(&:applicants_information)
  end

  def self.filter(searched_result, **filters)
    searched_result.map do |result|
      unless filters[:is_daejeon].nil?
        next unless result[:is_daejeon] == filters[:is_daejeon]
      end
      unless filters[:is_nationwide].nil?
        next unless result[:is_daejeon] == !filters[:is_nationwide]
      end
      unless filters[:is_arrived].nil?
        next unless result[:is_arrived] == filters[:is_arrived]
      end
      unless filters[:is_paid].nil?
        next unless result[:is_paid] == filters[:is_paid]
      end
      unless filters[:is_common].nil?
        next unless filters[:is_common] == (result[:apply_type] == 'COMMON')
      end
      unless filters[:is_meister].nil?
        next unless filters[:is_meister] == (result[:apply_type] == 'MEISTER')
      end
      unless filters[:is_social].nil?
        next unless filters[:is_social] == !['COMMON', 'MEISTER', nil].include?(result[:apply_type])
      end

      result
    end.compact
  end

  def applicants_information
    if status
      return {
        receipt_code: receipt_code,
        name: name,
        email: email,
        is_daejeon: is_daejeon,
        apply_type: apply_type,
        is_arrived: status.is_printed_application_arrived,
        is_paid: status.is_paid,
        is_final_submit: status.is_final_submit
      }
    end

    nil
  end

  def applicant_information
    response = { applicant_information: {
      status: {
        is_paid: status.is_paid,
        is_arrived: status.is_printed_application_arrived,
        is_final_submit: status.is_final_submit
      },

      privacy: {
        user_photo: signed_user_photo_url,
        name: name,
        birth_date: birth_date.strftime('%Y-%m-%d'),
        grade_type: grade_type,
        apply_type: apply_type,
        address: address,
        detail_address: detail_address,
        applicant_tel: applicant_tel,
        parent_tel: parent_tel,
        email: email
      },

      evaluation: {
        conversion_score: calculated_score.conversion_score.to_f,
        self_introduction: self_introduction,
        study_plan: study_plan
      }
    } }

    if grade_type == 'GED'
      response[:evaluation][:ged_average_score] = flexible_grade_type.ged_average_score
      return response
    end

    privacy = response[:applicant_information][:privacy]
    evaluation = response[:applicant_information][:evaluation]

    privacy[:school_name] = flexible_grade_type.school.school_name
    privacy[:school_tel] = flexible_grade_type.school_tel
    evaluation[:volunteer_time] = flexible_grade_type.volunteer_time
    evaluation[:full_absent_count] = flexible_grade_type.full_cut_count
    evaluation[:early_leave_count] = flexible_grade_type.early_leave_count
    evaluation[:late_count] = flexible_grade_type.late_count
    evaluation[:period_absent_count] = flexible_grade_type.period_cut_count

    response
  end

  def signed_user_photo_url
    ApplicationRecord.cloudfront_signed_url("https://#{ENV['IMAGE_BUCKET']}",
                                            user_photo,
                                            (Time.now.utc + 900).to_i,
                                            ENV['POLICY_FILE_PATH'])
  end

  def applicant_contact
    contacts = { applicant_contact: {
      email: email,
      applicant_tel: applicant_tel,
      parent_tel: parent_tel,
      home_tel: home_tel
    } }

    return contacts if grade_type == 'GED' || grade_type.nil?

    contacts[:school_tel] = flexible_grade_type.school_tel
    contacts
  end

  def flexible_grade_type
    send(grade_type.downcase + '_application')
  end
end
