# frozen_string_literal: true

module NITFr
  # Shared module for building search patterns from queries
  #
  # Provides consistent pattern building across Document and Paragraph
  # search methods, with proper escaping and case sensitivity handling.
  module SearchPattern
    private

    # Build a regex pattern from query
    #
    # @param query [String, Regexp] the search query
    # @param case_sensitive [Boolean] whether search is case-sensitive
    # @return [Regexp] compiled pattern
    def build_search_pattern(query, case_sensitive)
      if query.is_a?(Regexp)
        if case_sensitive
          query
        else
          # Preserve original flags while adding case insensitivity
          Regexp.new(query.source, query.options | Regexp::IGNORECASE)
        end
      else
        Regexp.new(Regexp.escape(query.to_s), case_sensitive ? nil : Regexp::IGNORECASE)
      end
    end
  end
end
