# frozen_string_literal: true

module NITFr
  # Represents a parsed NITF document
  #
  # The Document class is the main entry point for working with NITF content.
  # It provides access to all parts of the NITF structure including head and body.
  #
  # @note This parser does not process external entities (DTD references) for security.
  #   REXML by default does not expand external entities, which protects against XXE attacks.
  class Document
    attr_reader :xml_doc, :head, :body

    # Create a new Document from an NITF XML string
    #
    # @param xml [String] the NITF XML content
    # @raise [ParseError] if the XML is malformed
    # @raise [InvalidDocumentError] if the document is not valid NITF
    def initialize(xml)
      @xml_doc = parse_xml(xml)
      validate_nitf!
      parse_content
    end

    # Get the document's title from the head section
    #
    # @return [String, nil] the document title
    def title
      head&.title
    end

    # Get the main headline text
    #
    # @return [String, nil] the primary headline
    def headline
      body&.headline&.primary
    end

    # Get all headline levels
    #
    # @return [Headline, nil] the headline object with all levels
    def headlines
      body&.headline
    end

    # Get the byline information
    #
    # @return [Byline, nil] the byline object
    def byline
      body&.byline
    end

    # Get all paragraphs from the body content
    #
    # @return [Array<Paragraph>] array of paragraph objects
    def paragraphs
      body&.paragraphs || []
    end

    # Get the full text content of the article
    #
    # @return [String] concatenated paragraph text
    def text
      @text ||= paragraphs.map(&:text).join("\n\n")
    end

    # Get all media objects (images, etc.) from the document
    #
    # @return [Array<Media>] array of media objects
    def media
      body&.media || []
    end

    # Get document metadata from docdata
    #
    # @return [Docdata, nil] the docdata object
    def docdata
      head&.docdata
    end

    # Get the document ID
    #
    # @return [String, nil] the document ID
    def doc_id
      docdata&.doc_id
    end

    # Get the issue date
    #
    # @return [Date, nil] the issue date
    def issue_date
      docdata&.issue_date
    end

    # Get the NITF version from the root element
    #
    # @return [String, nil] the NITF version
    def version
      nitf_root.attributes["version"]
    end

    # Get the change date from the root element
    #
    # @return [String, nil] the change date
    def change_date
      nitf_root.attributes["change.date"]
    end

    # Get the change time from the root element
    #
    # @return [String, nil] the change time
    def change_time
      nitf_root.attributes["change.time"]
    end

    # Check if this is a valid NITF document
    #
    # @return [Boolean] true if valid NITF
    def valid?
      !nitf_root.nil?
    end

    # Return raw XML string
    #
    # @return [String] the original XML
    def to_xml
      @xml_doc.to_s
    end

    # Convert document to a Hash representation
    #
    # @return [Hash] the document as a hash
    def to_h
      {
        version: version,
        change_date: change_date,
        change_time: change_time,
        title: title,
        doc_id: doc_id,
        issue_date: issue_date&.to_s,
        head: head&.to_h,
        body: body&.to_h
      }.compact
    end

    # Convert document to JSON string
    #
    # @param args [Array] arguments passed to JSON.generate
    # @return [String] JSON representation of the document
    def to_json(*args)
      require "json"
      to_h.to_json(*args)
    end

    private

    # Parse XML string into REXML document
    #
    # REXML does not expand external entities by default, which protects against:
    # - XXE (XML External Entity) attacks
    # - Billion Laughs (entity expansion) attacks
    #
    # Security settings are configured at module load time in lib/nitfr.rb
    #
    # @param xml [String] the XML content
    # @return [REXML::Document] the parsed document
    def parse_xml(xml)
      REXML::Document.new(xml)
    rescue REXML::ParseException => e
      raise ParseError, "Failed to parse XML: #{e.message}"
    end

    def validate_nitf!
      return if nitf_root

      raise InvalidDocumentError, "Document does not appear to be valid NITF (missing <nitf> root element)"
    end

    def nitf_root
      @nitf_root ||= begin
        # Use direct root access for better performance when nitf is the root element
        root = @xml_doc.root
        return root if root&.name == "nitf"

        # Fall back to XPath search for nested nitf elements
        REXML::XPath.first(@xml_doc, "//nitf")
      end
    end

    def parse_content
      head_node = REXML::XPath.first(nitf_root, "head")
      body_node = REXML::XPath.first(nitf_root, "body")

      @head = Head.new(head_node) if head_node
      @body = Body.new(body_node) if body_node
    end
  end
end
