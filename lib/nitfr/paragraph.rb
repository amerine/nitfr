# frozen_string_literal: true

module NITFr
  # Represents a paragraph from an NITF document body
  #
  # Paragraphs can contain inline elements like emphasis,
  # links, and other markup.
  #
  # Entity extraction (people, organizations, locations, emphasis) uses
  # lazy batch extraction - a single DOM traversal populates all entity
  # arrays on first access to any entity method.
  class Paragraph
    include TextExtractor
    include SearchPattern

    attr_reader :node

    def initialize(node)
      @node = node
      @entities_extracted = false
    end

    # Get the plain text content of the paragraph
    #
    # @return [String] the paragraph text with inline elements stripped
    def text
      @text ||= extract_all_text(node).strip
    end
    alias to_s text

    # Get the paragraph ID if present
    #
    # @return [String, nil] the paragraph ID
    def id
      node.attributes["id"]
    end

    # Get the paragraph's lede attribute (indicates lead paragraph)
    #
    # @return [String, nil] the lede value
    def lede
      node.attributes["lede"]
    end

    # Check if this is a lead paragraph
    #
    # @return [Boolean] true if marked as lead
    def lead?
      lede == "true" || lede == "yes"
    end

    # Get any emphasized text within the paragraph (em tags)
    #
    # @return [Array<String>] array of emphasized text
    def emphasis
      extract_entities unless @entities_extracted
      @emphasis
    end

    # Get any strong/bold text within the paragraph (strong tags)
    #
    # @return [Array<String>] array of strong text
    def strong
      extract_entities unless @entities_extracted
      @strong
    end

    # Get any links within the paragraph
    #
    # @return [Array<Hash>] array of link info hashes
    def links
      extract_entities unless @entities_extracted
      @links
    end

    # Get any person references in the paragraph
    #
    # @return [Array<String>] array of person names
    def people
      extract_entities unless @entities_extracted
      @people
    end

    # Get any organization references in the paragraph
    #
    # @return [Array<String>] array of organization names
    def organizations
      extract_entities unless @entities_extracted
      @organizations
    end

    # Get any location references in the paragraph
    #
    # @return [Array<String>] array of location names
    def locations
      extract_entities unless @entities_extracted
      @locations
    end

    # Get the raw HTML/XML content of the paragraph
    #
    # @return [String] the inner XML
    def inner_html
      node.children.map(&:to_s).join
    end

    # Check if paragraph has content
    #
    # @return [Boolean] true if paragraph has text
    def present?
      !text.empty?
    end

    # Get word count for the paragraph
    #
    # @return [Integer] approximate word count
    def word_count
      return 0 if text.empty?

      text.split(/\s+/).size
    end

    # =========================================================================
    # Search Helper Methods
    # =========================================================================

    # Check if paragraph contains the given text
    #
    # @param query [String, Regexp] the search query
    # @param case_sensitive [Boolean] whether search is case-sensitive (default: false)
    # @return [Boolean] true if text is found
    def contains?(query, case_sensitive: false)
      pattern = build_search_pattern(query, case_sensitive)
      text.match?(pattern)
    end

    # Check if paragraph mentions a specific person
    #
    # @param name [String] the person name to search for
    # @param exact [Boolean] if true, requires exact match (default: false)
    # @return [Boolean] true if person is mentioned
    def mentions_person?(name, exact: false)
      entity_match?(people, name, exact)
    end

    # Check if paragraph mentions a specific organization
    #
    # @param name [String] the organization name to search for
    # @param exact [Boolean] if true, requires exact match (default: false)
    # @return [Boolean] true if organization is mentioned
    def mentions_org?(name, exact: false)
      entity_match?(organizations, name, exact)
    end

    # Check if paragraph mentions a specific location
    #
    # @param name [String] the location name to search for
    # @param exact [Boolean] if true, requires exact match (default: false)
    # @return [Boolean] true if location is mentioned
    def mentions_location?(name, exact: false)
      entity_match?(locations, name, exact)
    end

    # Check if paragraph mentions any of the given entities
    #
    # @param person [String, nil] person name to check
    # @param org [String, nil] organization name to check
    # @param location [String, nil] location name to check
    # @return [Boolean] true if any specified entity is mentioned
    def mentions?(person: nil, org: nil, location: nil)
      return false if person.nil? && org.nil? && location.nil?

      (person && mentions_person?(person)) ||
        (org && mentions_org?(org)) ||
        (location && mentions_location?(location))
    end

    # Check if paragraph has any links
    #
    # @return [Boolean] true if paragraph contains links
    def has_links?
      links.any?
    end

    # Check if paragraph has any emphasis
    #
    # @return [Boolean] true if paragraph contains emphasized text
    def has_emphasis?
      emphasis.any?
    end

    # Check if paragraph has any strong/bold text
    #
    # @return [Boolean] true if paragraph contains strong text
    def has_strong?
      strong.any?
    end

    # Check if paragraph mentions any entities
    #
    # @return [Boolean] true if paragraph contains any person, org, or location references
    def has_entities?
      people.any? || organizations.any? || locations.any?
    end

    # Convert paragraph to a Hash representation
    #
    # @return [Hash] the paragraph as a hash
    def to_h
      {
        id: id,
        text: text,
        lead: lead? || nil,
        word_count: word_count,
        people: people.empty? ? nil : people,
        organizations: organizations.empty? ? nil : organizations,
        locations: locations.empty? ? nil : locations,
        emphasis: emphasis.empty? ? nil : emphasis,
        strong: strong.empty? ? nil : strong,
        links: links.empty? ? nil : links
      }.compact
    end

    private

    # Extract all entities in a single DOM traversal
    #
    # This is more efficient than running separate XPath queries
    # for each entity type when multiple entity methods are called.
    def extract_entities
      @people = []
      @organizations = []
      @locations = []
      @emphasis = []
      @strong = []
      @links = []

      traverse_for_entities(node)

      @entities_extracted = true
    end

    # Recursively traverse elements and extract entities
    #
    # @param element [REXML::Element] the element to traverse
    def traverse_for_entities(element)
      element.each_element do |child|
        case child.name
        when "person"
          text = child.text&.strip
          @people << text if text && !text.empty?
        when "org"
          text = child.text&.strip
          @organizations << text if text && !text.empty?
        when "location"
          text = child.text&.strip
          @locations << text if text && !text.empty?
        when "em"
          text = child.text&.strip
          @emphasis << text if text && !text.empty?
        when "strong"
          text = child.text&.strip
          @strong << text if text && !text.empty?
        when "a"
          @links << {
            text: child.text&.strip,
            href: child.attributes["href"]
          }
        end

        # Continue traversing for nested entities
        traverse_for_entities(child)
      end
    end

    # Check if any entity matches the given name
    #
    # @param entities [Array<String>] array of entity names
    # @param name [String] name to search for
    # @param exact [Boolean] require exact match
    # @return [Boolean] true if match found
    def entity_match?(entities, name, exact)
      if exact
        entities.any? { |e| e == name }
      else
        pattern = /#{Regexp.escape(name)}/i
        entities.any? { |e| e.match?(pattern) }
      end
    end
  end
end
