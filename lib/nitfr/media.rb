# frozen_string_literal: true

module NITFr
  # Represents a media element from an NITF document
  #
  # Media elements can represent images, audio, video, or other
  # multimedia content embedded in the article.
  class Media
    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Get the media type (image, audio, video, etc.)
    #
    # @return [String, nil] the media type
    def type
      node.attributes["media-type"]
    end

    # Check if this is an image
    #
    # @return [Boolean] true if media type is image
    def image?
      type == "image"
    end

    # Check if this is audio
    #
    # @return [Boolean] true if media type is audio
    def audio?
      type == "audio"
    end

    # Check if this is video
    #
    # @return [Boolean] true if media type is video
    def video?
      type == "video"
    end

    # Get the caption text
    #
    # @return [String, nil] the caption
    def caption
      @caption ||= xpath_first("media-caption")&.text&.strip
    end

    # Get the producer/credit information
    #
    # @return [String, nil] the producer/credit
    def producer
      @producer ||= xpath_first("media-producer")&.text&.strip
    end
    alias credit producer

    # Get all media references (different formats/sizes)
    #
    # @return [Array<Hash>] array of reference info
    def references
      @references ||= xpath_match("media-reference").map do |ref|
        {
          source: ref.attributes["source"],
          mime_type: ref.attributes["mime-type"],
          coding: ref.attributes["coding"],
          width: ref.attributes["width"]&.to_i,
          height: ref.attributes["height"]&.to_i,
          alternate_text: ref.attributes["alternate-text"],
          name: ref.attributes["name"]
        }.compact
      end
    end

    # Get the primary/first reference
    #
    # @return [Hash, nil] the first reference
    def primary_reference
      references.first
    end

    # Get the source URL of the primary reference
    #
    # @return [String, nil] the source URL
    def source
      primary_reference&.dig(:source)
    end
    alias src source
    alias url source

    # Get the mime type of the primary reference
    #
    # @return [String, nil] the mime type
    def mime_type
      primary_reference&.dig(:mime_type)
    end

    # Get the alternate text
    #
    # @return [String, nil] the alt text
    def alt_text
      primary_reference&.dig(:alternate_text)
    end

    # Get the width
    #
    # @return [Integer, nil] width in pixels
    def width
      primary_reference&.dig(:width)
    end

    # Get the height
    #
    # @return [Integer, nil] height in pixels
    def height
      primary_reference&.dig(:height)
    end

    # Get media metadata
    #
    # @return [Hash] additional metadata attributes
    def metadata
      @metadata ||= {
        id: node.attributes["id"],
        class: node.attributes["class"]
      }.compact
    end

    # Convert media to a Hash representation
    #
    # @return [Hash] the media as a hash
    def to_h
      {
        type: type,
        source: source,
        mime_type: mime_type,
        width: width,
        height: height,
        alt_text: alt_text,
        caption: caption,
        credit: credit,
        metadata: metadata.empty? ? nil : metadata,
        references: references.size > 1 ? references : nil
      }.compact
    end

    private

    def xpath_first(path)
      REXML::XPath.first(node, path)
    end

    def xpath_match(path)
      REXML::XPath.match(node, path)
    end
  end
end
