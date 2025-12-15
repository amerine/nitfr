# frozen_string_literal: true

module NITFr
  # Shared module for extracting text from REXML elements
  #
  # REXML's built-in text method only returns direct text content,
  # not text from nested elements. This module provides a method
  # to recursively extract all text content.
  module TextExtractor
    # Extract all text content from an element and its descendants
    #
    # @param element [REXML::Element] the element to extract text from
    # @return [String] the concatenated text content
    def extract_all_text(element)
      result = +""
      element.each_child do |child|
        if child.is_a?(REXML::Text)
          result << child.value
        elsif child.is_a?(REXML::Element)
          result << extract_all_text(child)
        end
      end
      result
    end
  end
end
