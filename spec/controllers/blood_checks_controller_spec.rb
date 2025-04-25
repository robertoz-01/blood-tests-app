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
      expect(html_body.at_css('h3').text).to match(/Your blood tests/)
      expect(response.body).to match(/2023-01-01/)
      expect(response.body).not_to match(/2023-05-20/)
    end
  end

  describe "GET #new" do
    context "when not logged in" do
      it "redirects" do
        # When
        get :new

        # Then
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when user is logged in" do
      it "shows the blood check creation form" do
        # When
        sign_in user
        get :new

        # Then
        expect(response).to be_successful
        expect(html_body.at_css('h3').text).to match(/New blood test/)
        expect(html_body).to have_selector('input#blood_check_notes')
        expect(html_body).to have_selector("form table")
      end
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
        expect(response).to be_successful
        expect(html_body.at_css('h3').text).to match(/Your blood test/)
        expect(html_body.at_css('input#blood_check_notes')['value']).to eq("Some important notes")
        expect(html_body).to have_selector("form table")
      end
    end
  end

  describe "POST #create" do
    context "when not logged in" do
      it "redirects" do
        # When
        post :create

        # Then
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when logged in" do
      before { sign_in user }

      context "with valid parameters" do
        let(:valid_params) do
          {
            blood_check: {
              check_date: "2024-01-15",
              notes: "Regular checkup"
            },
            entries: [
              { name: "Hemoglobin", value: 14.5, unit: "g/dL", reference_lower: 13.0, reference_upper: 17.0 }
            ]
          }
        end

        it "returns the created objects as json" do
          # When
          post :create, params: valid_params

          # Then
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)

          expect(json_response["blood_check"]).to include(
                                                    {
                                                      "notes" => "Regular checkup",
                                                      "check_date" => "2024-01-15",
                                                      "identifier" => be_present
                                                    }
                                                  )
          expect(json_response["entries"]).to include(
                                                {
                                                  "identifier" => be_present,
                                                  "name" => "Hemoglobin",
                                                  "value" => 14.5,
                                                  "unit" => "g/dL",
                                                  "reference_lower" => 13.0,
                                                  "reference_upper" => 17.0
                                                }
                                              )
        end

        it "creates a new blood check with its entries" do
          # When
          post :create, params: valid_params

          # Then
          json_response = JSON.parse(response.body)
          check_identifier = json_response["blood_check"]["identifier"]
          created_check = BloodCheck.find_by(identifier: check_identifier)

          expect(created_check.attributes).to include({
                                                        "identifier" => check_identifier,
                                                        "notes" => "Regular checkup",
                                                        "check_date" => Date.new(2024, 1, 15)
                                                      })
          expect(created_check.user.id).to eq(user.id)
          expect(created_check.check_entries.count).to eq(1)
          created_entry = created_check.check_entries.first
          expect(created_entry.attributes).to include({
                                                        "identifier" => be_present,
                                                        "value" => 14.5
                                                      })
          created_analysis = created_entry.analysis
          expect(created_analysis.attributes).to include({
                                                           "default_name" => "Hemoglobin",
                                                           "unit" => "g/dL",
                                                           "reference_lower" => 13.0,
                                                           "reference_upper" => 17.0
                                                         })
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            blood_check: {
              notes: "Missing required check_date"
            }
          }
        end

        it "returns unprocessable entity status" do
          # When
          post :create, params: invalid_params

          # Then
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key("errors")
        end
      end
    end
  end

  describe "POST #load_from_pdf" do
    before do
      allow(ExtractorService).to receive(:entries_from_pdf)
    end

    context "when not logged in" do
      it "redirects" do
        # When
        post :load_from_pdf, params: { pdf_file: "ignored-param" }

        # Then
        expect(ExtractorService).not_to have_received(:entries_from_pdf)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when logged in" do
      before { sign_in user }

      it "loads the blood check entries through the ExtractorService service" do
        # Given
        file_param = Rack::Test::UploadedFile.new(
          StringIO.new("fake-pdf-content"), "application/pdf", original_filename: "check.pdf"
        )
        service_response = [
          { "name" => "GLOBULI BIANCHI",
            "value" => 4.23,
            "unit" => "x10^3/µl",
            "reference_lower" => 4.0,
            "reference_upper" => 9.5 }
        ]

        expect(ExtractorService).to receive(:entries_from_pdf).and_return(service_response)

        # When
        post :load_from_pdf, params: { pdf_file: file_param }

        # Then
        expect(json_body).to eq(
                               { "user_entries" => service_response }
                             )
      end
    end
  end

  describe "GET #compare" do
    let(:blood_check1) { FactoryBot.create(:blood_check, user: user) }
    let(:blood_check2) { FactoryBot.create(:blood_check, user: user) }
    let(:analysis) { FactoryBot.create(:analysis) }
    let(:check_entry1) { FactoryBot.create(:check_entry, blood_check: blood_check1, analysis: analysis) }
    let(:check_entry2) { FactoryBot.create(:check_entry, blood_check: blood_check2, analysis: analysis) }
    let(:identifiers_param) { "#{blood_check1.identifier},#{blood_check2.identifier}" }

    context "when not logged in" do
      it "redirects" do
        # When
        get :compare, params: { identifiers: identifiers_param }

        # Then
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when logged in" do
      before { sign_in user }

      it "shows the comparison of the specified blood checks" do
        # When
        get :compare, params: { identifiers: identifiers_param }

        # Then
        expect(response).to be_successful
        expect(html_body.at_css('h3').text).to match(/Blood tests comparison/)
        expect(html_body).to have_selector("table#blood-checks-table")
      end
    end

    context "when a blood check does not belong to the logged-in user" do
      before { sign_in user }

      it "does not allow to compare blood checks from other users" do
        # Given
        other_user = FactoryBot.create(:user)
        other_user_blood_check = FactoryBot.create(:blood_check, user: other_user)
        identifiers = "#{identifiers_param},#{other_user_blood_check.identifier}"

        # When - Then
        expect do
          get :compare, params: { identifiers: identifiers }
        end.to raise_error(ActiveRecord::RecordNotFound)
        # TODO: it should be handled in a more graceful way (eg. show a message to the user)
      end
    end
  end
end
