# frozen_string_literal: true

module Helpers
  module Authentication
    def sign_in(user)
      session = user.sessions.create
      cookies.signed[:session_id] = session.id
    end

    def html_body
      @html_body ||= Nokogiri::HTML(response.body)
    end
  end
end
