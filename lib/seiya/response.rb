module Seiya
  class Response
    def initialize(resp)
      @resp = resp
    end

    def url
      @resp.header.request_uri.to_s
    end

    def header
      @resp.header
    end

    def headers
      @resp.headers
    end

    def body
      @resp.body
    end

    def doc
      begin
        return @doc unless @doc.nil?
        @doc = Nokogiri::HTML body
        @has_doc = true
      rescue
        @has_doc = false
      end
    end

    def json
      begin
        return @json unless @json.nil?
        @json = JSON.parse body
        @has_json = true
      rescue
        @has_json = false
      end
    end

    def has_doc?
      doc
      !!@has_doc
    end

    def has_json?
      json
      !!@has_json
    end
  end
end