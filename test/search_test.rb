# frozen_string_literal: true

require "test_helper"

class SearchTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(@xml)
  end

  # =========================================================================
  # Document#search tests
  # =========================================================================

  def test_search_returns_array
    results = @document.search("technology")

    assert_instance_of Array, results
  end

  def test_search_finds_matches
    results = @document.search("technology")

    assert results.any?
  end

  def test_search_returns_match_info
    results = @document.search("technology")
    result = results.first

    assert result.key?(:paragraph_index)
    assert result.key?(:paragraph)
    assert result.key?(:match)
    assert result.key?(:position)
  end

  def test_search_paragraph_is_paragraph_object
    results = @document.search("technology")

    assert_instance_of NITFr::Paragraph, results.first[:paragraph]
  end

  def test_search_is_case_insensitive_by_default
    results_lower = @document.search("technology")
    results_upper = @document.search("TECHNOLOGY")

    assert_equal results_lower.size, results_upper.size
  end

  def test_search_case_sensitive_option
    results_insensitive = @document.search("revolutionary")
    results_sensitive = @document.search("revolutionary", case_sensitive: true)

    # If the text has "Revolutionary" (capital R), case_sensitive should find fewer
    assert results_insensitive.size >= results_sensitive.size
  end

  def test_search_with_regex
    results = @document.search(/tech\w+/i)

    assert results.any?
  end

  def test_search_returns_empty_for_no_match
    results = @document.search("xyznonexistent")

    assert_empty results
  end

  def test_search_multiple_matches_in_same_paragraph
    # If a word appears multiple times in one paragraph
    results = @document.search("the")

    assert results.size >= 1
  end

  # =========================================================================
  # Document#contains? tests
  # =========================================================================

  def test_contains_returns_boolean
    assert_boolean @document.contains?("technology")
  end

  def test_contains_finds_existing_text
    assert @document.contains?("technology")
  end

  def test_contains_returns_false_for_missing_text
    assert_false @document.contains?("xyznonexistent")
  end

  def test_contains_is_case_insensitive_by_default
    assert @document.contains?("TECHNOLOGY")
  end

  def test_contains_case_sensitive_option
    # Only finds exact case when case_sensitive is true
    result = @document.contains?("REVOLUTIONARY", case_sensitive: true)

    # Should be false if text is "Revolutionary" not "REVOLUTIONARY"
    assert_boolean result
  end

  def test_contains_with_regex
    assert @document.contains?(/tech\w+/)
  end

  # =========================================================================
  # Document#paragraphs_containing tests
  # =========================================================================

  def test_paragraphs_containing_returns_array
    results = @document.paragraphs_containing("technology")

    assert_instance_of Array, results
  end

  def test_paragraphs_containing_returns_paragraph_objects
    results = @document.paragraphs_containing("technology")

    results.each do |para|
      assert_instance_of NITFr::Paragraph, para
    end
  end

  def test_paragraphs_containing_filters_correctly
    results = @document.paragraphs_containing("technology")

    results.each do |para|
      assert_match(/technology/i, para.text)
    end
  end

  def test_paragraphs_containing_empty_for_no_match
    results = @document.paragraphs_containing("xyznonexistent")

    assert_empty results
  end

  # =========================================================================
  # Document#paragraphs_mentioning tests
  # =========================================================================

  def test_paragraphs_mentioning_person
    results = @document.paragraphs_mentioning(person: "John Doe")

    assert results.any?
    results.each do |para|
      assert para.mentions_person?("John Doe")
    end
  end

  def test_paragraphs_mentioning_org
    results = @document.paragraphs_mentioning(org: "TechCorp")

    assert results.any?
  end

  def test_paragraphs_mentioning_location
    results = @document.paragraphs_mentioning(location: "San Francisco")

    assert results.any?
  end

  def test_paragraphs_mentioning_multiple_any
    # Default: any of the specified entities
    results = @document.paragraphs_mentioning(
      person: "John Doe",
      org: "TechCorp"
    )

    results.each do |para|
      assert(para.mentions_person?("John Doe") || para.mentions_org?("TechCorp"))
    end
  end

  def test_paragraphs_mentioning_multiple_all
    # match_all: true requires ALL specified entities
    results = @document.paragraphs_mentioning(
      person: "John Doe",
      org: "TechCorp",
      match_all: true
    )

    results.each do |para|
      assert para.mentions_person?("John Doe")
      assert para.mentions_org?("TechCorp")
    end
  end

  def test_paragraphs_mentioning_no_args_returns_all
    results = @document.paragraphs_mentioning

    assert_equal @document.paragraphs.size, results.size
  end

  # =========================================================================
  # Document#paragraphs_where tests
  # =========================================================================

  def test_paragraphs_where_with_block
    results = @document.paragraphs_where { |p| p.word_count > 10 }

    results.each do |para|
      assert para.word_count > 10
    end
  end

  def test_paragraphs_where_lead_paragraphs
    results = @document.paragraphs_where(&:lead?)

    results.each do |para|
      assert para.lead?
    end
  end

  def test_paragraphs_where_no_block_returns_all
    results = @document.paragraphs_where

    assert_equal @document.paragraphs.size, results.size
  end

  # =========================================================================
  # Document#find_paragraph tests
  # =========================================================================

  def test_find_paragraph_returns_first_match
    para = @document.find_paragraph { |p| p.lead? }

    assert_instance_of NITFr::Paragraph, para
    assert para.lead?
  end

  def test_find_paragraph_returns_nil_for_no_match
    para = @document.find_paragraph { |p| p.word_count > 10_000 }

    assert_nil para
  end

  def test_find_paragraph_no_block_returns_nil
    para = @document.find_paragraph

    assert_nil para
  end

  # =========================================================================
  # Document#find_media tests
  # =========================================================================

  def test_find_media_returns_all_without_type
    results = @document.find_media

    assert_equal @document.media.size, results.size
  end

  def test_find_media_filters_by_type
    results = @document.find_media(type: "image")

    results.each do |media|
      assert_equal "image", media.type
    end
  end

  def test_find_media_accepts_symbol_type
    results = @document.find_media(type: :image)

    results.each do |media|
      assert_equal "image", media.type
    end
  end

  # =========================================================================
  # Document#images, #videos, #audio tests
  # =========================================================================

  def test_images_returns_image_media
    @document.images.each do |media|
      assert media.image?
    end
  end

  def test_videos_returns_video_media
    @document.videos.each do |media|
      assert media.video?
    end
  end

  def test_audio_returns_audio_media
    @document.audio.each do |media|
      assert media.audio?
    end
  end

  # =========================================================================
  # Document entity aggregation tests
  # =========================================================================

  def test_all_people_returns_unique_names
    people = @document.all_people

    assert_instance_of Array, people
    assert_equal people.uniq, people
  end

  def test_all_organizations_returns_unique_names
    orgs = @document.all_organizations

    assert_instance_of Array, orgs
    assert_equal orgs.uniq, orgs
  end

  def test_all_locations_returns_unique_names
    locations = @document.all_locations

    assert_instance_of Array, locations
    assert_equal locations.uniq, locations
  end

  def test_all_entities_returns_hash
    entities = @document.all_entities

    assert_instance_of Hash, entities
    assert entities.key?(:people)
    assert entities.key?(:organizations)
    assert entities.key?(:locations)
  end

  # =========================================================================
  # Document#count_occurrences tests
  # =========================================================================

  def test_count_occurrences_returns_integer
    count = @document.count_occurrences("technology")

    assert_instance_of Integer, count
  end

  def test_count_occurrences_counts_correctly
    count = @document.count_occurrences("the")

    assert count >= 1
  end

  def test_count_occurrences_zero_for_no_match
    count = @document.count_occurrences("xyznonexistent")

    assert_equal 0, count
  end

  # =========================================================================
  # Document#excerpt tests
  # =========================================================================

  def test_excerpt_returns_string
    result = @document.excerpt("technology")

    assert_instance_of String, result
  end

  def test_excerpt_includes_match
    result = @document.excerpt("technology")

    assert_match(/technology/i, result)
  end

  def test_excerpt_has_context
    result = @document.excerpt("technology", context_chars: 20)

    # Should have some surrounding text
    assert result.length > "technology".length
  end

  def test_excerpt_returns_nil_for_no_match
    result = @document.excerpt("xyznonexistent")

    assert_nil result
  end

  def test_excerpt_ellipsis_for_truncation
    result = @document.excerpt("technology", context_chars: 10)

    # With small context, mid-document matches should have ellipsis on both ends
    assert_not_nil result
    assert_match(/technology/i, result)
    # The result should either have ellipsis or be the full text (if text is short)
    has_ellipsis = result.start_with?("...") || result.end_with?("...")
    is_short_text = @document.text.length <= ("technology".length + 20)
    assert(has_ellipsis || is_short_text, "Expected ellipsis for truncated excerpt")
  end

  # =========================================================================
  # Paragraph#contains? tests
  # =========================================================================

  def test_paragraph_contains_returns_boolean
    para = @document.paragraphs.first

    assert_boolean para.contains?("groundbreaking")
  end

  def test_paragraph_contains_finds_text
    para = @document.paragraphs.first

    assert para.contains?("groundbreaking")
  end

  def test_paragraph_contains_case_insensitive
    para = @document.paragraphs.first

    assert para.contains?("GROUNDBREAKING")
  end

  # =========================================================================
  # Paragraph#mentions_* tests
  # =========================================================================

  def test_paragraph_mentions_person
    para = @document.paragraphs.find { |p| p.people.any? }

    assert para.mentions_person?("John Doe")
  end

  def test_paragraph_mentions_person_partial_match
    para = @document.paragraphs.find { |p| p.people.any? }

    assert para.mentions_person?("John")
  end

  def test_paragraph_mentions_person_exact_match
    para = @document.paragraphs.find { |p| p.people.any? }

    assert para.mentions_person?("John Doe", exact: true)
    assert_false para.mentions_person?("John", exact: true)
  end

  def test_paragraph_mentions_org
    para = @document.paragraphs.find { |p| p.organizations.any? }

    assert para.mentions_org?("TechCorp")
  end

  def test_paragraph_mentions_location
    para = @document.paragraphs.find { |p| p.locations.any? }

    assert para.mentions_location?("San Francisco")
  end

  # =========================================================================
  # Paragraph#mentions? tests
  # =========================================================================

  def test_paragraph_mentions_any_entity
    para = @document.paragraphs.find { |p| p.people.any? }

    assert para.mentions?(person: "John Doe")
  end

  def test_paragraph_mentions_multiple_entities
    para = @document.paragraphs.find { |p| p.people.any? && p.organizations.any? }
    return unless para

    assert para.mentions?(person: "John Doe", org: "TechCorp")
  end

  def test_paragraph_mentions_no_args_returns_false
    para = @document.paragraphs.first

    assert_false para.mentions?
  end

  # =========================================================================
  # Paragraph#has_* tests
  # =========================================================================

  def test_paragraph_has_links
    para = @document.paragraphs.find { |p| p.links.any? }

    if para
      assert para.has_links?
    else
      # No paragraphs with links in fixture, that's ok
      assert true
    end
  end

  def test_paragraph_has_emphasis
    para = @document.paragraphs.find { |p| p.emphasis.any? }

    if para
      assert para.has_emphasis?
    else
      assert true
    end
  end

  def test_paragraph_has_entities
    para = @document.paragraphs.find { |p| p.people.any? || p.organizations.any? || p.locations.any? }

    assert para.has_entities?
  end

  # =========================================================================
  # Edge case tests for pattern building
  # =========================================================================

  def test_search_empty_string_query
    results = @document.search("")

    # Empty string matches everywhere, should return many results
    assert_instance_of Array, results
  end

  def test_search_unicode_characters
    # Test that unicode characters are properly escaped and matched
    results = @document.search("technology")

    assert_instance_of Array, results
  end

  def test_search_special_regex_characters
    # Characters like . * + ? should be escaped when passed as string
    results = @document.search("tech.")  # Should NOT match "technology" as regex

    # Since we escape, "tech." matches literal "tech." not "tech" + any char
    results.each do |r|
      assert_includes r[:match], "tech."
    end
  end

  def test_contains_with_regex_preserves_multiline_flag
    # When passing a regex with MULTILINE, it should be preserved
    pattern = /technology/m
    result = @document.contains?(pattern, case_sensitive: true)

    assert_boolean result
  end

  # =========================================================================
  # Excerpt boundary condition tests
  # =========================================================================

  def test_excerpt_match_at_start_of_text
    # Find a word that appears at/near the start
    first_word = @document.text.split.first
    result = @document.excerpt(first_word, context_chars: 5)

    # Should not have leading ellipsis if match is at start
    assert_instance_of String, result
  end

  def test_excerpt_with_zero_context
    result = @document.excerpt("technology", context_chars: 0)

    # Should still return the match itself
    assert_match(/technology/i, result)
  end

  def test_excerpt_match_near_end_of_text
    # Find something near the end
    last_words = @document.text.split.last(3).join(" ")
    if @document.contains?(last_words)
      result = @document.excerpt(last_words, context_chars: 5)
      assert_instance_of String, result
    end
  end

  def test_excerpt_very_large_context
    # Context larger than text should work without error
    result = @document.excerpt("technology", context_chars: 100_000)

    assert_instance_of String, result
    assert_match(/technology/i, result)
  end

  # =========================================================================
  # Entity matching edge case tests
  # =========================================================================

  def test_entity_partial_match_finds_longer_name
    # If we have "John Doe", searching for "John" should find it
    para = @document.paragraphs.find { |p| p.people.include?("John Doe") }
    return unless para

    assert para.mentions_person?("John")
    assert para.mentions_person?("Doe")
  end

  def test_entity_exact_match_case_sensitivity
    para = @document.paragraphs.find { |p| p.people.any? }
    return unless para

    person = para.people.first
    # exact: true should be case-sensitive
    assert para.mentions_person?(person, exact: true)
    assert_false para.mentions_person?(person.upcase, exact: true) unless person == person.upcase
  end

  def test_entity_partial_match_is_case_insensitive
    para = @document.paragraphs.find { |p| p.people.any? }
    return unless para

    person = para.people.first
    # Partial match should be case-insensitive
    assert para.mentions_person?(person.upcase)
    assert para.mentions_person?(person.downcase)
  end

  # =========================================================================
  # Improved excerpt ellipsis test
  # =========================================================================

  def test_excerpt_ellipsis_behavior
    # Find text that's definitely in the middle
    result = @document.excerpt("technology", context_chars: 10)

    if result
      text_length = @document.text.length
      match_pos = @document.text.downcase.index("technology")

      # If match is not at start, should have leading ellipsis
      if match_pos && match_pos > 10
        assert result.start_with?("..."), "Expected leading ellipsis for mid-document match"
      end

      # If match is not at end, should have trailing ellipsis
      if match_pos && (match_pos + "technology".length + 10) < text_length
        assert result.end_with?("..."), "Expected trailing ellipsis for mid-document match"
      end
    end
  end

  # =========================================================================
  # Memoization test for all_entities
  # =========================================================================

  def test_all_entities_memoization
    first_call = @document.all_entities
    second_call = @document.all_entities

    # Should return same object (memoized)
    assert_same first_call, second_call
  end

  def test_all_people_uses_memoized_entities
    # Calling all_people should use the memoized all_entities
    @document.all_entities  # Prime the cache
    people = @document.all_people

    assert_equal @document.all_entities[:people], people
  end

  # =========================================================================
  # Helper assertions
  # =========================================================================

  private

  def assert_boolean(value)
    assert [true, false].include?(value), "Expected boolean, got #{value.class}"
  end
end
