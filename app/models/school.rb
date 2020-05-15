class School < ApplicationRecord
  self.primary_key = :school_code

  has_many :graduated_applications
  has_many :ungraduated_applications
end
