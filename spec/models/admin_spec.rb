require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe '> create Admin instance' do
    it '> Admin instance created by valid data is valid.' do
      admin = build(:admin)
      expect(admin).to be_valid
    end
  end

  describe '> user model validation' do
    it '> not encoded password is not valid.' do
      admin = build(:admin)
      admin.password_decryption
    end

    it '> duplicate email is not valid.' do
      create(:admin, email: 'tester@example.com')
      invalid_admin = build(:admin, email: 'tester@example.com')
      expect(invalid_admin).to_not be_valid
    end

    it '> blank password is not valid.' do
      invalid_password = build(:admin, password: nil)
      expect(invalid_password).to_not be_valid
    end
  end
end
