require 'rails_helper'

RSpec.describe ExtractorService do
  describe ".entries_from_pdf" do
    let(:pdf_file_stream) { StringIO.new("fake-pdf-content") }
    let(:response_body) do
      <<~JSON
        [
          {"name":"GLOBULI BIANCHI","value":4.23,"unit":"x10^3/µl","reference_lower":4.0,"reference_upper":9.5},
          {"name":"GLOBULI ROSSI","value":6.03,"unit":"x10^6/µl","reference_lower":4.7,"reference_upper":5.82}
        ]
      JSON
    end

    context 'when API call is successful' do
      it 'returns extracted entries from the PDF' do
        # Given
        expect(HTTParty).to receive(:post).
          with("http://localhost:8000/blood-test-pdf", body: { "file" => pdf_file_stream }, multipart: true).
          and_return(double(body: response_body))

        # When
        result = ExtractorService.entries_from_pdf(pdf_file_stream)

        # Then
        expect(result).to eq([
                               { "name" => "GLOBULI BIANCHI",
                                 "value" => 4.23,
                                 "unit" => "x10^3/µl",
                                 "reference_lower" => 4.0,
                                 "reference_upper" => 9.5 },
                               { "name" => "GLOBULI ROSSI",
                                 "value" => 6.03,
                                 "unit" => "x10^6/µl",
                                 "reference_lower" => 4.7,
                                 "reference_upper" => 5.82 }
                             ])
      end
    end

    # TODO, handle and test also the case of unsuccessful response
  end
end
