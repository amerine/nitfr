# frozen_string_literal: true

require "rexml/document"
require "rexml/xpath"

# Configure REXML security settings at load time
# This protects against XML entity expansion attacks (Billion Laughs)
if defined?(REXML::Security)
  REXML::Security.entity_expansion_limit = 100
  REXML::Security.entity_expansion_text_limit = 10_000
end

require_relative "nitfr/version"
require_relative "nitfr/errors"
require_relative "nitfr/text_extractor"
require_relative "nitfr/document"
require_relative "nitfr/head"
require_relative "nitfr/body"
require_relative "nitfr/headline"
require_relative "nitfr/byline"
require_relative "nitfr/paragraph"
require_relative "nitfr/media"
require_relative "nitfr/docdata"

module NITFr
  class << self
    # Parse an NITF XML string and return a Document
    #
    # @param xml [String] the NITF XML content
    # @return [Document] the parsed document
    # @raise [ParseError] if the XML is invalid or not NITF
    def parse(xml)
      Document.new(xml)
    end

    # Parse an NITF XML file and return a Document
    #
    # @param path [String] path to the NITF XML file
    # @param encoding [String] the file encoding (default: UTF-8)
    # @return [Document] the parsed document
    # @raise [ParseError] if the file cannot be read or XML is invalid
    # @raise [Errno::ENOENT] if the file does not exist
    def parse_file(path, encoding: "UTF-8")
      xml = File.read(path, encoding: encoding)
      parse(xml)
    end
  end
end
