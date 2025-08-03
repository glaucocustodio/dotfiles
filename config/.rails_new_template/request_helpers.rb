REQUEST_HELPERS_CONTENT = <<-CODE
module RequestHelpers
  def json_parsed_body
    JSON.parse(response.body)
  end

  # HTML entities (like &#39; for a single quote) are encoded by default
  # in Rails because of security best practices,
  # specifically to prevent Cross-Site Scripting (XSS) attacks
  def decoded_response_body
    @_decoded_response_body ||= CGI.unescapeHTML(response.body)
  end

  def html_parsed_body
    @_html_parsed_body ||= Nokogiri.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
CODE
