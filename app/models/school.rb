class School < ApplicationRecord
  self.primary_key = :school_code

  has_many :graduated_applications, foreign_key: :school_code
  has_many :ungraduated_applications, foreign_key: :school_code
end
