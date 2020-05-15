class GraduatedApplication < ApplicationRecord
  self.primary_key = :user_email

  belongs_to :user, foreign_key: :user_email
  belongs_to :school, foreign_key: :school_code
end
