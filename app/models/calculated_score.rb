class CalculatedScore < ApplicationRecord
  self.primary_key = :user_email

  belongs_to :user, foreign_key: :user_email
end
