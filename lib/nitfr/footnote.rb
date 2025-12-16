# frozen_string_literal: true

module NITFr
  # Represents a footnote from an NITF document
  #
  # Footnotes can appear in body.content or body.end and contain
  # a label (reference marker) and value (the footnote text).
  class Footnote
    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Get the footnote ID
    #
    # @return [String, nil] the footnote ID attribute
    def id
      node.attributes["id"]
    end

    # Get the footnote label (reference marker)
    #
    # @return [String, nil] the label text (e.g., "1", "*", "a")
    def label
      @label ||= xpath_text("fn-label")
    end

    # Get the footnote value (content)
    #
    # @return [String, nil] the footnote text content
    def value
      @value ||= xpath_text("fn-value")
    end
    alias text value
    alias content value

    # Check if footnote has content
    #
    # @return [Boolean] true if footnote has a value
    def present?
      !value.nil? && !value.empty?
    end

    # Convert footnote to a Hash representation
    #
    # @return [Hash] the footnote as a hash
    def to_h
      {
        id: id,
        label: label,
        value: value
      }.compact
    end

    private

    def xpath_text(path)
      element = REXML::XPath.first(node, path)
      element&.text&.strip
    end
  end
end
