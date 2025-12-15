# frozen_string_literal: true

require "date"

module NITFr
  # Represents the docdata section of an NITF document head
  #
  # Docdata contains document metadata including IDs, dates,
  # urgency, and other management information.
  class Docdata
    attr_reader :node

    def initialize(node)
      @node = node
    end

    # Get the document ID
    #
    # @return [String, nil] the doc-id value
    def doc_id
      @doc_id ||= xpath_first("doc-id")&.attributes&.[]("id-string")
    end

    # Get the issue date
    #
    # @return [Date, nil] the parsed issue date
    def issue_date
      @issue_date ||= parse_date("date.issue")
    end

    # Get the release date
    #
    # @return [Date, nil] the parsed release date
    def release_date
      @release_date ||= parse_date("date.release")
    end

    # Get the expiration date
    #
    # @return [Date, nil] the parsed expire date
    def expire_date
      @expire_date ||= parse_date("date.expire")
    end

    # Get urgency level (1-8, 1 being most urgent)
    #
    # @return [Integer, nil] the urgency value
    def urgency
      @urgency ||= xpath_first("urgency")&.attributes&.[]("ed-urg")&.to_i
    end

    # Get the document copyright information
    #
    # @return [Hash] copyright details
    def copyright
      @copyright ||= parse_copyright
    end

    # Get the copyright holder
    #
    # @return [String, nil] the copyright holder
    def copyright_holder
      copyright[:holder]
    end

    # Get the copyright year
    #
    # @return [String, nil] the copyright year
    def copyright_year
      copyright[:year]
    end

    # Get document scope information
    #
    # @return [String, nil] the doc-scope
    def doc_scope
      @doc_scope ||= xpath_first("doc-scope")&.attributes&.[]("scope")
    end

    # Get series information
    #
    # @return [Hash] series details
    def series
      @series ||= parse_series
    end

    # Get editorial status/management info
    #
    # @return [Hash] management status
    def management_status
      @management_status ||= parse_management_status
    end

    # Get the fixture identifier
    #
    # @return [String, nil] the fixture value
    def fixture
      @fixture ||= xpath_first("fixture")&.attributes&.[]("fix-id")
    end

    # Get all identified content (subjects, organizations, people, etc.)
    #
    # @return [Hash] categorized identified content
    def identified_content
      @identified_content ||= parse_identified_content
    end

    # Get subject codes/topics
    #
    # @return [Array<String>] array of subjects
    def subjects
      identified_content[:subjects] || []
    end

    # Get location codes
    #
    # @return [Array<String>] array of locations
    def locations
      identified_content[:locations] || []
    end

    # Get organization codes
    #
    # @return [Array<String>] array of organizations
    def organizations
      identified_content[:organizations] || []
    end

    # Get person codes
    #
    # @return [Array<String>] array of people
    def people
      identified_content[:people] || []
    end

    # Convert docdata to a Hash representation
    #
    # @return [Hash] the docdata as a hash
    def to_h
      {
        doc_id: doc_id,
        issue_date: issue_date&.to_s,
        release_date: release_date&.to_s,
        expire_date: expire_date&.to_s,
        urgency: urgency,
        copyright: copyright.empty? ? nil : copyright,
        doc_scope: doc_scope,
        fixture: fixture,
        series: series.empty? ? nil : series,
        management_status: management_status.empty? ? nil : management_status,
        subjects: subjects.empty? ? nil : subjects,
        locations: locations.empty? ? nil : locations,
        organizations: organizations.empty? ? nil : organizations,
        people: people.empty? ? nil : people
      }.compact
    end

    private

    def xpath_first(path)
      REXML::XPath.first(node, path)
    end

    def xpath_match(path)
      REXML::XPath.match(node, path)
    end

    def parse_date(element_name)
      date_node = xpath_first(element_name)
      return nil unless date_node

      norm = date_node.attributes["norm"]
      return nil unless norm

      Date.parse(norm)
    rescue Date::Error
      nil
    end

    def parse_copyright
      copyright_node = xpath_first("doc.copyright")
      return {} unless copyright_node

      {
        holder: copyright_node.attributes["holder"],
        year: copyright_node.attributes["year"]
      }.compact
    end

    def parse_series
      series_node = xpath_first("series")
      return {} unless series_node

      {
        name: series_node.attributes["series.name"],
        part: series_node.attributes["series.part"]&.to_i,
        total: series_node.attributes["series.totalpart"]&.to_i
      }.compact
    end

    def parse_management_status
      status_node = xpath_first("ed-msg")
      return {} unless status_node

      {
        info: status_node.attributes["info"],
        message_type: status_node.attributes["msg-type"]
      }.compact
    end

    def parse_identified_content
      id_node = xpath_first("identified-content")
      return {} unless id_node

      {
        subjects: REXML::XPath.match(id_node, "classifier[@type='subject']").map { |c| c.text&.strip }.compact,
        locations: REXML::XPath.match(id_node, "location").map { |l| l.text&.strip }.compact,
        organizations: REXML::XPath.match(id_node, "org").map { |o| o.text&.strip }.compact,
        people: REXML::XPath.match(id_node, "person").map { |p| p.text&.strip }.compact
      }
    end
  end
end
