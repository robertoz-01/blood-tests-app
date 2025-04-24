require "rails_helper"

RSpec.describe HomeController, type: :controller do
  render_views

  describe "GET #index" do
    it "shows the home page" do
      # When
      get :index

      # Then
      expect(response).to be_successful
      expect(html_body.at_css('h3').text).to match(/What is this?/)
    end
  end
end