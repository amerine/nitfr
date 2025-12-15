# frozen_string_literal: true

module NITFr
  # Represents headline information from an NITF document
  #
  # NITF supports multiple headline levels (hl1, hl2) as well as
  # headline (alternate headline) elements.
  class Headline
    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Get the primary headline (hl1)
    #
    # @return [String, nil] the main headline text
    def primary
      @primary ||= xpath_first("hl1")&.text&.strip
    end
    alias hl1 primary

    # Get the secondary headline (hl2)
    #
    # @return [String, nil] the secondary headline text
    def secondary
      @secondary ||= xpath_first("hl2")&.text&.strip
    end
    alias hl2 secondary

    # Get all headline levels as an array
    #
    # @return [Array<String>] array of headline texts in order
    def all
      @all ||= [primary, secondary].compact
    end

    # Get the full headline text (all levels joined)
    #
    # @return [String] combined headline text
    def to_s
      all.join(" - ")
    end

    # Check if headline exists
    #
    # @return [Boolean] true if any headline text exists
    def present?
      !primary.nil? || !secondary.nil?
    end

    # Convert headline to a Hash representation
    #
    # @return [Hash] the headline as a hash
    def to_h
      {
        primary: primary,
        secondary: secondary
      }.compact
    end

    private

    def xpath_first(path)
      REXML::XPath.first(node, path)
    end
  end
end
