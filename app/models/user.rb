class User < ApplicationRecord
  self.primary_key = :email

  enum apply_type: %w[MEISTER SOCIAL_ONE_PARENT SOCIAL_FROM_NORTH
                      SOCIAL_MULTICULTURAL SOCIAL_BASIC_LIVING
                      SOCIAL_LOWEST_INCOME SOCIAL_TEEN_HOUSEHOLDER]
  enum additional_type: %w[NATIONAL_MERIT PRIVILEGED_ADMISSION NOT_APPLICABLE]
  enum grade_type: %w[GED UNGRADUATED GRADUATED]
  enum sex: %w[MALE FEMALE]

  has_one :ged_application
  has_one :graduated_application
  has_one :ungraduated_application
  has_one :status
  has_one :calculated_score
end
