# frozen_string_literal: true

require "httparty"

class ExtractorService
  HOST = ENV.fetch("EXTRACTOR_SERVICE_HOST", "http://localhost:8000")

  def self.entries_from_pdf(file_stream)
    request_body = {
      "file" => file_stream
    }

    response = HTTParty.post(
      "#{HOST}/blood-test-pdf",
      body: request_body,
      multipart: true
    )

    JSON.parse(response.body)
  end
end
