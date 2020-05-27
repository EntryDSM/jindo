class Admin < ApplicationRecord
  validates_uniqueness_of :email, presence: true, case_sensitive: true
  validates :password, presence: true

  include BCrypt

  self.primary_key = :email

  def password_decryption
    Password.new(password)
  end

  def password_encryption=(new_password)
    self.password = Password.create(new_password)
  end

  def self.create!(**kwargs)
    instance = super kwargs
    instance.password = Password.create(instance.password)
    instance.save

    instance
  end
end
