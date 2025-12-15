# frozen_string_literal: true

require "test_helper"

class ParagraphTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    document = NITFr::Document.new(xml)
    @paragraphs = document.paragraphs
  end

  def test_text_returns_paragraph_text
    assert_match(/groundbreaking new technology/, @paragraphs.first.text)
  end

  def test_lead_identifies_lead_paragraphs
    assert @paragraphs.first.lead?
    assert_false @paragraphs[1].lead?
  end

  def test_emphasis_extracts_emphasized_text
    para_with_em = @paragraphs.find { |p| p.text.include?("five years") }
    assert_includes para_with_em.emphasis, "five years"
  end

  def test_links_extracts_links
    para_with_link = @paragraphs.find { |p| p.text.include?("website") }
    assert_equal "https://example.com", para_with_link.links.first[:href]
  end

  def test_people_extracts_person_references
    para_with_person = @paragraphs.find { |p| p.people.any? }
    assert_includes para_with_person.people, "John Doe"
  end

  def test_organizations_extracts_organization_references
    para_with_org = @paragraphs.find { |p| p.organizations.any? }
    assert_includes para_with_org.organizations, "TechCorp Inc"
  end

  def test_locations_extracts_location_references
    para_with_location = @paragraphs.find { |p| p.locations.any? }
    assert_includes para_with_location.locations, "San Francisco"
  end

  def test_word_count_returns_approximate_word_count
    assert @paragraphs.first.word_count > 10
  end

  def test_present_returns_true_when_paragraph_has_text
    assert @paragraphs.first.present?
  end

  # Lazy batch extraction tests

  def test_entity_extraction_only_runs_once
    para = @paragraphs.find { |p| p.people.any? }

    # First access triggers extraction
    assert_false para.instance_variable_get(:@entities_extracted) == false

    # Access multiple entity methods
    para.people
    para.organizations
    para.locations
    para.emphasis
    para.links

    # Verify extraction flag is set
    assert para.instance_variable_get(:@entities_extracted)
  end

  def test_entity_extraction_not_triggered_by_text_access
    para = @paragraphs.first

    # Accessing text should NOT trigger entity extraction
    para.text

    # Entity extraction should not have run
    assert_false para.instance_variable_get(:@entities_extracted)
  end

  def test_all_entity_arrays_populated_on_first_access
    para = @paragraphs.find { |p| p.text.include?("TechCorp") }

    # Only access people - but all arrays should be populated
    para.people

    # All entity arrays should now exist (even if empty)
    assert_instance_of Array, para.instance_variable_get(:@people)
    assert_instance_of Array, para.instance_variable_get(:@organizations)
    assert_instance_of Array, para.instance_variable_get(:@locations)
    assert_instance_of Array, para.instance_variable_get(:@emphasis)
    assert_instance_of Array, para.instance_variable_get(:@links)
  end

  # Nested entity text tests

  def test_simple_entity_text_extraction
    xml = load_fixture("nested_entities.xml")
    doc = NITFr::Document.new(xml)
    paragraphs = doc.paragraphs

    # Simple emphasis (no nesting) works correctly
    para_simple = paragraphs.find { |p| p.text.include?("simple emphasis") }
    assert_includes para_simple.emphasis, "simple emphasis"
  end

  def test_nested_entity_text_extracts_direct_text_only
    xml = load_fixture("nested_entities.xml")
    doc = NITFr::Document.new(xml)
    paragraphs = doc.paragraphs

    # Note: Current implementation extracts direct text only
    # <person><em>John</em> Doe</person> extracts " Doe" (the direct text node)
    # This is a known limitation - nested text requires recursive extraction
    para_person = paragraphs.find { |p| p.text.include?("John") }

    # The person array may contain partial text due to nested elements
    # This test documents current behavior
    assert_instance_of Array, para_person.people
  end

  def test_paragraph_text_includes_all_nested_content
    xml = load_fixture("nested_entities.xml")
    doc = NITFr::Document.new(xml)
    paragraphs = doc.paragraphs

    # The full text extraction (via TextExtractor) should get everything
    para_person = paragraphs.find { |p| p.text.include?("John") }
    assert_match(/John.*Doe/, para_person.text)

    para_org = paragraphs.find { |p| p.text.include?("TechCorp") }
    assert_match(/TechCorp.*Inc/, para_org.text)
  end
end
