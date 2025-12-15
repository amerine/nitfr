# frozen_string_literal: true

module NITFr
  # Represents the head section of an NITF document
  #
  # The head contains metadata about the document including title,
  # document data, publication information, and revision history.
  class Head
    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Get the document title
    #
    # @return [String, nil] the title text
    def title
      @title ||= xpath_first("title")&.text&.strip
    end

    # Get document metadata
    #
    # @return [Docdata, nil] the docdata object
    def docdata
      @docdata ||= begin
        docdata_node = xpath_first("docdata")
        Docdata.new(docdata_node) if docdata_node
      end
    end

    # Get publication data
    #
    # @return [Hash] publication metadata
    def pubdata
      @pubdata ||= parse_pubdata
    end

    # Get revision history
    #
    # @return [Array<Hash>] array of revision entries
    def revision_history
      @revision_history ||= parse_revision_history
    end

    # Get metadata keywords
    #
    # @return [Array<String>] array of keywords
    def keywords
      @keywords ||= xpath_match("meta[@name='keywords']").map { |n| n.attributes["content"] }.compact
    end

    # Get all meta tags as a hash
    #
    # @return [Hash<String, String>] meta name => content pairs
    def meta
      @meta ||= xpath_match("meta").each_with_object({}) do |n, hash|
        name = n.attributes["name"]
        hash[name] = n.attributes["content"] if name
      end
    end

    private

    def xpath_first(path)
      REXML::XPath.first(node, path)
    end

    def xpath_match(path)
      REXML::XPath.match(node, path)
    end

    def parse_pubdata
      pubdata_node = xpath_first("pubdata")
      return {} unless pubdata_node

      {
        type: pubdata_node.attributes["type"],
        date_publication: pubdata_node.attributes["date.publication"],
        name: pubdata_node.attributes["name"],
        issn: pubdata_node.attributes["issn"],
        volume: pubdata_node.attributes["volume"],
        number: pubdata_node.attributes["number"],
        edition: pubdata_node.attributes["edition.name"],
        position_section: pubdata_node.attributes["position.section"],
        position_sequence: pubdata_node.attributes["position.sequence"]
      }.compact
    end

    def parse_revision_history
      xpath_match("revision-history").map do |rev|
        {
          comment: rev.attributes["comment"],
          name: rev.attributes["name"],
          function: rev.attributes["function"],
          norm: rev.attributes["norm"]
        }.compact
      end
    end
  end
end
