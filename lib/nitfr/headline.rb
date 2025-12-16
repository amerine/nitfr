# frozen_string_literal: true

module NITFr
  # Represents headline information from an NITF document
  #
  # NITF supports multiple headline levels (hl1 through hl5) as well as
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

    # Get the tertiary headline (hl3)
    #
    # @return [String, nil] the tertiary headline text
    def tertiary
      @tertiary ||= xpath_first("hl3")&.text&.strip
    end
    alias hl3 tertiary

    # Get the quaternary headline (hl4)
    #
    # @return [String, nil] the quaternary headline text
    def quaternary
      @quaternary ||= xpath_first("hl4")&.text&.strip
    end
    alias hl4 quaternary

    # Get the quinary headline (hl5)
    #
    # @return [String, nil] the quinary headline text
    def quinary
      @quinary ||= xpath_first("hl5")&.text&.strip
    end
    alias hl5 quinary

    # Get all headline levels as an array
    #
    # @return [Array<String>] array of headline texts in order
    def all
      @all ||= [primary, secondary, tertiary, quaternary, quinary].compact
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
      all.any?
    end

    # Convert headline to a Hash representation
    #
    # @return [Hash] the headline as a hash
    def to_h
      {
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        quaternary: quaternary,
        quinary: quinary
      }.compact
    end

    private

    def xpath_first(path)
      REXML::XPath.first(node, path)
    end
  end
end
