class GraduatedApplication < ApplicationRecord
  self.primary_key = :user_receipt_code

  belongs_to :user, foreign_key: :user_receipt_code
  belongs_to :school, foreign_key: :school_code
end
