# frozen_string_literal: true

module NITFr
  # Represents byline information from an NITF document
  #
  # Bylines can contain the author name, their title/role,
  # and additional location information.
  class Byline
    include TextExtractor

    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Get the full byline text
    #
    # @return [String, nil] the complete byline text
    def text
      @text ||= extract_all_text(node).strip
    end
    alias to_s text

    # Get the person/author name from byttl element
    #
    # @return [String, nil] the author name
    def person
      @person ||= xpath_first("person")&.text&.strip
    end

    # Get the byline title/role
    #
    # @return [String, nil] the title or role
    def title
      @title ||= xpath_first("byttl")&.text&.strip
    end

    # Get the location if specified
    #
    # @return [String, nil] the location
    def location
      @location ||= xpath_first("location")&.text&.strip
    end

    # Get organization/affiliation
    #
    # @return [String, nil] the organization name
    def org
      @org ||= xpath_first("org")&.text&.strip
    end

    # Check if byline has content
    #
    # @return [Boolean] true if byline has text
    def present?
      !text.empty?
    end

    # Convert byline to a Hash representation
    #
    # @return [Hash] the byline as a hash
    def to_h
      {
        text: text,
        person: person,
        title: title,
        location: location,
        org: org
      }.compact
    end

    private

    def xpath_first(path)
      REXML::XPath.first(node, path)
    end
  end
end
