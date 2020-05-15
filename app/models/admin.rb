class Admin < ApplicationRecord
  self.primary_key = :email

  alias_attribute :password_digest, :password
end
