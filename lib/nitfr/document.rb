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
    include SearchPattern

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

    # Get the total word count of the document
    #
    # @return [Integer] total word count across all paragraphs
    def word_count
      @word_count ||= paragraphs.sum(&:word_count)
    end

    # Get the estimated reading time
    #
    # @param words_per_minute [Integer] reading speed (default: 200)
    # @return [String] human-readable reading time (e.g., "3 min read")
    def reading_time(words_per_minute: 200)
      minutes = (word_count / words_per_minute.to_f).ceil
      if minutes < 1
        "Less than 1 min read"
      elsif minutes == 1
        "1 min read"
      else
        "#{minutes} min read"
      end
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

    # =========================================================================
    # Search Methods
    # =========================================================================

    # Search the full document text for a query string or pattern
    #
    # @param query [String, Regexp] the search query (string or regex)
    # @param case_sensitive [Boolean] whether search is case-sensitive (default: false)
    # @return [Array<Hash>] array of match results with context
    def search(query, case_sensitive: false)
      pattern = build_search_pattern(query, case_sensitive)
      results = []

      paragraphs.each_with_index do |para, index|
        para.text.scan(pattern) do
          match = Regexp.last_match
          results << {
            paragraph_index: index,
            paragraph: para,
            match: match[0],
            position: match.begin(0)
          }
        end
      end

      results
    end

    # Check if document contains the given text
    #
    # @param query [String, Regexp] the search query
    # @param case_sensitive [Boolean] whether search is case-sensitive (default: false)
    # @return [Boolean] true if text is found
    def contains?(query, case_sensitive: false)
      pattern = build_search_pattern(query, case_sensitive)
      text.match?(pattern)
    end

    # Find paragraphs containing the given text
    #
    # @param query [String, Regexp] the search query
    # @param case_sensitive [Boolean] whether search is case-sensitive (default: false)
    # @return [Array<Paragraph>] matching paragraphs
    def paragraphs_containing(query, case_sensitive: false)
      pattern = build_search_pattern(query, case_sensitive)
      paragraphs.select { |p| p.text.match?(pattern) }
    end

    # Find paragraphs mentioning specific entities
    #
    # @param person [String, nil] person name to search for
    # @param org [String, nil] organization name to search for
    # @param location [String, nil] location name to search for
    # @param match_all [Boolean] if true, paragraph must contain ALL specified entities (default: false)
    # @return [Array<Paragraph>] matching paragraphs
    def paragraphs_mentioning(person: nil, org: nil, location: nil, match_all: false)
      return paragraphs if person.nil? && org.nil? && location.nil?

      paragraphs.select do |para|
        matches = []
        matches << para.mentions_person?(person) if person
        matches << para.mentions_org?(org) if org
        matches << para.mentions_location?(location) if location

        match_all ? matches.all? : matches.any?
      end
    end

    # Find paragraphs using a custom block
    #
    # @yield [Paragraph] block to evaluate each paragraph
    # @return [Array<Paragraph>] paragraphs where block returns true
    # @example Find long paragraphs
    #   doc.paragraphs_where { |p| p.word_count > 50 }
    # @example Find lead paragraphs with links
    #   doc.paragraphs_where { |p| p.lead? && p.links.any? }
    def paragraphs_where(&block)
      return paragraphs unless block_given?

      paragraphs.select(&block)
    end

    # Find the first paragraph matching criteria
    #
    # @yield [Paragraph] block to evaluate each paragraph
    # @return [Paragraph, nil] first matching paragraph or nil
    def find_paragraph(&block)
      return nil unless block_given?

      paragraphs.find(&block)
    end

    # Find media by type
    #
    # @param type [String, Symbol, nil] media type ('image', 'video', 'audio')
    # @return [Array<Media>] matching media objects
    def find_media(type: nil)
      return media if type.nil?

      type_str = type.to_s
      media.select { |m| m.type == type_str }
    end

    # Get all images from the document
    #
    # @return [Array<Media>] image media objects
    def images
      media.select(&:image?)
    end

    # Get all videos from the document
    #
    # @return [Array<Media>] video media objects
    def videos
      media.select(&:video?)
    end

    # Get all audio from the document
    #
    # @return [Array<Media>] audio media objects
    def audio
      media.select(&:audio?)
    end

    # Get all unique people mentioned in the document
    #
    # @return [Array<String>] unique person names from paragraphs and docdata
    def all_people
      all_entities[:people]
    end

    # Get all unique organizations mentioned in the document
    #
    # @return [Array<String>] unique organization names from paragraphs and docdata
    def all_organizations
      all_entities[:organizations]
    end

    # Get all unique locations mentioned in the document
    #
    # @return [Array<String>] unique location names from paragraphs and docdata
    def all_locations
      all_entities[:locations]
    end

    # Get all unique entities (people, organizations, locations) mentioned
    #
    # Uses single-pass aggregation for efficiency when multiple entity
    # methods are called.
    #
    # @return [Hash] hash with :people, :organizations, :locations arrays
    def all_entities
      @all_entities ||= aggregate_entities
    end

    # Count occurrences of a term in the document
    #
    # @param query [String, Regexp] the search query
    # @param case_sensitive [Boolean] whether search is case-sensitive (default: false)
    # @return [Integer] number of occurrences
    def count_occurrences(query, case_sensitive: false)
      pattern = build_search_pattern(query, case_sensitive)
      text.scan(pattern).size
    end

    # Get excerpt around first match of query
    #
    # @param query [String, Regexp] the search query
    # @param context_chars [Integer] characters of context on each side (default: 50)
    # @param case_sensitive [Boolean] whether search is case-sensitive (default: false)
    # @return [String, nil] excerpt with surrounding context and ellipses, or nil if not found
    def excerpt(query, context_chars: 50, case_sensitive: false)
      pattern = build_search_pattern(query, case_sensitive)
      match = text.match(pattern)
      return nil unless match

      start_pos = [match.begin(0) - context_chars, 0].max
      end_pos = [match.end(0) + context_chars, text.length].min

      prefix = start_pos > 0 ? "..." : ""
      suffix = end_pos < text.length ? "..." : ""

      excerpt_text = text[start_pos...end_pos]
      "#{prefix}#{excerpt_text}#{suffix}"
    end

    private

    # Aggregate all entities in a single pass through paragraphs
    #
    # @return [Hash] hash with :people, :organizations, :locations arrays
    def aggregate_entities
      result = { people: [], organizations: [], locations: [] }

      paragraphs.each do |para|
        result[:people].concat(para.people)
        result[:organizations].concat(para.organizations)
        result[:locations].concat(para.locations)
      end

      # Add docdata entities if available
      if docdata
        result[:people].concat(docdata.people || [])
        result[:organizations].concat(docdata.organizations || [])
        result[:locations].concat(docdata.locations || [])
      end

      # Remove duplicates
      result.transform_values!(&:uniq)
      result
    end

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
