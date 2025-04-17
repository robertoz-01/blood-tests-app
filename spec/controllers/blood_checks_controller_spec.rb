require "rails_helper"

RSpec.describe BloodChecksController, type: :controller do
  render_views

  describe "GET #index" do
    let(:user) { FactoryBot.create(:user) }

    context "when not logged in" do
      it "redirects" do
        get :index
        expect(response).to redirect_to("/session/new")
      end
    end

    it "shows the blood checks of the logged in user" do
      # Given
      sign_in user
      FactoryBot.create(:blood_check, user: user, check_date: Date.new(2023, 1, 1))
      FactoryBot.create(:blood_check,
                        user: FactoryBot.create(:user, user_name: "Someone else"),
                        check_date: Date.new(2023, 5, 20))

      # When
      get :index

      # Then
      expect(response).to be_successful
      expect(response.body).to match(/Your blood tests/)
      expect(response.body).to match(/2023-01-01/)
      expect(response.body).not_to match(/2023-05-20/)
    end
  end
end
