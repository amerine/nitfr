# frozen_string_literal: true

module NITFr
  # Represents the body section of an NITF document
  #
  # The body contains the main content of the news article including
  # headline, byline, and the actual article text in body.content.
  class Body
    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Get the headline object
    #
    # @return [Headline, nil] the headline with all levels
    def headline
      @headline ||= begin
        headline_node = body_head && xpath_first(body_head, "headline")
        Headline.new(headline_node) if headline_node
      end
    end

    # Get the byline object
    #
    # @return [Byline, nil] the byline information
    def byline
      @byline ||= begin
        byline_node = body_head && xpath_first(body_head, "byline")
        Byline.new(byline_node) if byline_node
      end
    end

    # Get the dateline text
    #
    # @return [String, nil] the dateline
    def dateline
      @dateline ||= (body_head && xpath_first(body_head, "dateline"))&.text&.strip
    end

    # Get the abstract/summary
    #
    # @return [String, nil] the abstract text
    def abstract
      @abstract ||= (body_head && xpath_first(body_head, "abstract"))&.text&.strip
    end

    # Get distributor information
    #
    # @return [String, nil] the distributor
    def distributor
      @distributor ||= (body_head && xpath_first(body_head, "distributor"))&.text&.strip
    end

    # Get series information
    #
    # @return [Hash, nil] series metadata
    def series
      @series ||= parse_series
    end

    # Get all paragraphs from body.content
    #
    # @return [Array<Paragraph>] array of paragraph objects
    def paragraphs
      @paragraphs ||= begin
        return [] unless body_content

        xpath_match(body_content, ".//p").map { |p| Paragraph.new(p) }
      end
    end

    # Get all media objects from body.content
    #
    # @return [Array<Media>] array of media objects
    def media
      @media ||= begin
        return [] unless body_content

        xpath_match(body_content, ".//media").map { |m| Media.new(m) }
      end
    end

    # Get all block quotes
    #
    # @return [Array<String>] array of block quote texts
    def block_quotes
      @block_quotes ||= begin
        return [] unless body_content

        xpath_match(body_content, ".//bq/block").map { |b| b.text&.strip }.compact
      end
    end

    # Get all lists from the content
    #
    # @return [Array<Hash>] array of list structures
    def lists
      @lists ||= parse_lists
    end

    # Get all tables from the content
    #
    # @return [Array<REXML::Element>] raw table nodes
    def tables
      @tables ||= begin
        return [] unless body_content

        xpath_match(body_content, ".//table")
      end
    end

    # Get the body.end content (tagline, bibliography)
    #
    # @return [Hash] body end content
    def body_end_content
      @body_end_content ||= parse_body_end
    end

    # Get the tagline
    #
    # @return [String, nil] the tagline text
    def tagline
      body_end_content[:tagline]
    end

    # Get notes from body.end
    #
    # @return [Array<String>] array of notes
    def notes
      body_end_content[:notes] || []
    end

    # Convert body to a Hash representation
    #
    # @return [Hash] the body as a hash
    def to_h
      {
        headline: headline&.to_h,
        byline: byline&.to_h,
        dateline: dateline,
        abstract: abstract,
        distributor: distributor,
        series: series,
        paragraphs: paragraphs.map(&:to_h),
        media: media.empty? ? nil : media.map(&:to_h),
        block_quotes: block_quotes.empty? ? nil : block_quotes,
        lists: lists.empty? ? nil : lists,
        tagline: tagline,
        notes: notes.empty? ? nil : notes
      }.compact
    end

    private

    def xpath_first(context, path)
      REXML::XPath.first(context, path)
    end

    def xpath_match(context, path)
      REXML::XPath.match(context, path)
    end

    def body_head
      @body_head ||= xpath_first(node, "body.head")
    end

    def body_content
      @body_content ||= xpath_first(node, "body.content")
    end

    def body_end
      @body_end ||= xpath_first(node, "body.end")
    end

    def parse_series
      return nil unless body_head

      series_node = xpath_first(body_head, "series")
      return nil unless series_node

      {
        name: series_node.attributes["series.name"],
        part: series_node.attributes["series.part"],
        totalpart: series_node.attributes["series.totalpart"]
      }.compact
    end

    def parse_lists
      return [] unless body_content

      xpath_match(body_content, ".//ul | .//ol | .//dl").map do |list|
        {
          type: list.name,
          items: xpath_match(list, ".//li | .//dt | .//dd").map { |item| item.text&.strip }.compact
        }
      end
    end

    def parse_body_end
      return {} unless body_end

      {
        tagline: xpath_first(body_end, "tagline")&.text&.strip,
        notes: xpath_match(body_end, ".//note").map { |n| n.text&.strip }.compact,
        bibliography: xpath_match(body_end, ".//biblio").map { |b| b.text&.strip }.compact
      }.compact
    end
  end
end
