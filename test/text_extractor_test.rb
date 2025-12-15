# frozen_string_literal: true

require "test_helper"

class TextExtractorTest < Test::Unit::TestCase
  include TestHelper

  # Test the shared TextExtractor module

  def setup
    @xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(@xml)
  end

  def test_extracts_nested_text
    # Paragraphs have nested elements like <person>, <org>, <em>
    para = @document.paragraphs.find { |p| p.text.include?("TechCorp") }
    assert_not_nil para

    # Should include text from nested <org> element
    assert_match(/TechCorp Inc/, para.text)

    # Should include text from nested <person> element
    assert_match(/John Doe/, para.text)

    # Should include text from nested <location> element
    assert_match(/San Francisco/, para.text)
  end

  def test_extracts_emphasized_text_in_context
    para = @document.paragraphs.find { |p| p.text.include?("five years") }
    assert_not_nil para

    # The emphasized text should be part of the full text
    assert_match(/five years/, para.text)
  end

  def test_extracts_link_text_in_context
    para = @document.paragraphs.find { |p| p.text.include?("website") }
    assert_not_nil para

    # Link text should be part of the full text
    assert_match(/our website/, para.text)
  end

  def test_byline_extracts_all_nested_text
    # Byline has nested <person> and <byttl> elements
    byline = @document.byline
    text = byline.text

    # Should contain all text including nested elements
    assert_match(/Jane Smith/, text)
    assert_match(/Senior Technology Reporter/, text)
  end

  def test_preserves_whitespace_between_elements
    para = @document.paragraphs.find { |p| p.text.include?("TechCorp") }

    # Words should be separated, not concatenated
    assert_false para.text.include?("TechCorp Inc,uses")
  end
end
