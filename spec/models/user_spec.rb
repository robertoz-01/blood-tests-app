require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#email_address" do
    it "is normalized when assigned" do
      # Given
      user = User.new(email_address: " Roberto@test.org")

      # When-Then
      expect(user.email_address).to eq("roberto@test.org")
    end
  end
end
