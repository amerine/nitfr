# frozen_string_literal: true

require "test_helper"

class EdgeCasesTest < Test::Unit::TestCase
  include TestHelper

  # Empty and minimal documents

  def test_empty_body_document
    xml = load_fixture("empty_body.xml")
    doc = NITFr::Document.new(xml)

    assert doc.valid?
    assert_equal "Article with Empty Body", doc.title
    assert_equal [], doc.paragraphs
    assert_equal [], doc.media
    assert_nil doc.headline
  end

  def test_head_only_document
    xml = load_fixture("head_only.xml")
    doc = NITFr::Document.new(xml)

    assert doc.valid?
    assert_equal "Head Only Article", doc.title
    assert_equal "head-only-001", doc.doc_id
    assert_nil doc.body
    assert_nil doc.headline
    assert_equal [], doc.paragraphs
  end

  def test_body_only_document
    xml = load_fixture("body_only.xml")
    doc = NITFr::Document.new(xml)

    assert doc.valid?
    assert_nil doc.head
    assert_nil doc.title
    assert_equal "Body Only Article", doc.headline
    assert_equal 1, doc.paragraphs.size
  end

  # Unicode content

  def test_unicode_title
    xml = load_fixture("unicode_content.xml")
    doc = NITFr::Document.new(xml)

    assert_match(/Español/, doc.title)
    assert_match(/Ñ/, doc.title)
  end

  def test_unicode_headline
    xml = load_fixture("unicode_content.xml")
    doc = NITFr::Document.new(xml)

    assert_match(/日本語/, doc.headline)
    assert_match(/中文/, doc.headlines.secondary)
  end

  def test_unicode_byline
    xml = load_fixture("unicode_content.xml")
    doc = NITFr::Document.new(xml)

    assert_match(/François/, doc.byline.text)
    assert_match(/Müller/, doc.byline.text)
  end

  def test_unicode_paragraphs
    xml = load_fixture("unicode_content.xml")
    doc = NITFr::Document.new(xml)

    texts = doc.paragraphs.map(&:text)
    assert texts.any? { |t| t.include?("русский") }
    assert texts.any? { |t| t.include?("العربية") }
    assert texts.any? { |t| t.include?("Ελληνικά") }
    assert texts.any? { |t| t.include?("🎉") }
  end

  # Empty paragraphs

  def test_empty_paragraph_text
    xml = load_fixture("empty_paragraph.xml")
    doc = NITFr::Document.new(xml)

    paragraphs = doc.paragraphs
    assert_equal 3, paragraphs.size

    # Empty paragraph
    assert_equal "", paragraphs[0].text
    assert_false paragraphs[0].present?

    # Whitespace-only paragraph
    assert_equal "", paragraphs[1].text
    assert_false paragraphs[1].present?

    # Real content
    assert_equal "Real content here.", paragraphs[2].text
    assert paragraphs[2].present?
  end

  def test_empty_paragraph_word_count
    xml = load_fixture("empty_paragraph.xml")
    doc = NITFr::Document.new(xml)

    paragraphs = doc.paragraphs
    assert_equal 0, paragraphs[0].word_count
    assert_equal 0, paragraphs[1].word_count
    assert_equal 3, paragraphs[2].word_count
  end

  # Encoding parameter

  def test_parse_file_with_default_encoding
    doc = NITFr.parse_file(fixture_path("simple_article.xml"))
    assert doc.valid?
  end

  def test_parse_file_with_explicit_encoding
    doc = NITFr.parse_file(fixture_path("unicode_content.xml"), encoding: "UTF-8")
    assert doc.valid?
    assert_match(/日本語/, doc.headline)
  end

  def test_parse_file_nonexistent_raises_error
    assert_raises(Errno::ENOENT) do
      NITFr.parse_file("/nonexistent/path/to/file.xml")
    end
  end
end
