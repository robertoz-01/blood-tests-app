require "rails_helper"

RSpec.describe BloodChecksController, type: :controller do
  render_views

  let(:user) { FactoryBot.create(:user) }

  describe "GET #index" do
    context "when not logged in" do
      it "redirects" do
        # When
        get :index

        # Then
        expect(response).to have_http_status(:redirect)
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

  describe "GET #edit" do
    context "when not logged in" do
      let(:blood_check) { FactoryBot.create(:blood_check, user: user) }

      it "redirects" do
        # When
        get :edit, params: { id: blood_check.identifier }

        # Then
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the blood check does NOT belong to the logged-in user" do
      let(:other_user_blood_check) { FactoryBot.create(:blood_check, user: another_user) }
      let(:another_user) { FactoryBot.create(:user) }

      it "does NOT allow to see it" do
        # When - Then
        sign_in user

        expect do
          get :edit, params: { id: other_user_blood_check.identifier }
        end.to raise_error(ActiveRecord::RecordNotFound)
        # TODO: it should be handled in a more graceful way (eg. show a message to the user)
      end
    end

    context "when the blood check exists and belongs to the logged-in user" do
      let(:blood_check) do
        FactoryBot.create(:blood_check, user: user, notes: "Some important notes")
      end
      let(:check_entry) { FactoryBot.create(:check_entry, blood_check: blood_check) }

      it "shows the blood check edit form" do
        # When
        sign_in user
        get :edit, params: { id: blood_check.identifier }

        # Then
        expect(html_body.at_css('h3').text).to match(/Your blood test/)
        expect(html_body.at_css('input#blood_check_notes')['value']).to eq("Some important notes")
        expect(html_body).to have_selector("form table")
      end
    end
  end
end
