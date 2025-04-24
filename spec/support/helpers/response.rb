module Helpers
  module Response
    def html_body
      @html_body ||= Nokogiri::HTML(response.body)
    end

    def json_body
      @json_body ||= JSON.parse(response.body)
    end
  end
end
