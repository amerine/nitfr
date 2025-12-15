# frozen_string_literal: true

require "test_helper"

class NegativeTest < Test::Unit::TestCase
  include TestHelper

  # Invalid XML tests

  def test_malformed_xml_raises_parse_error
    assert_raises(NITFr::ParseError) do
      NITFr.parse("<invalid><unclosed>")
    end
  end

  def test_empty_string_raises_invalid_document_error
    assert_raises(NITFr::InvalidDocumentError) do
      NITFr.parse("")
    end
  end

  def test_non_nitf_xml_raises_invalid_document_error
    assert_raises(NITFr::InvalidDocumentError) do
      NITFr.parse("<html><body>Not NITF</body></html>")
    end
  end

  def test_whitespace_only_raises_parse_error
    # Whitespace-only is malformed XML (no root element), so ParseError
    assert_raises(NITFr::ParseError) do
      NITFr.parse("   \n\t   ")
    end
  end

  # Invalid date handling

  def test_invalid_date_format_returns_nil
    xml = load_fixture("bad_date.xml")
    doc = NITFr::Document.new(xml)

    assert_nil doc.issue_date
  end

  def test_invalid_date_release_returns_nil
    xml = load_fixture("bad_date.xml")
    doc = NITFr::Document.new(xml)

    # "99999999" is not a valid date
    assert_nil doc.docdata.release_date
  end

  def test_invalid_urgency_returns_zero
    xml = load_fixture("bad_date.xml")
    doc = NITFr::Document.new(xml)

    # "invalid".to_i returns 0
    assert_equal 0, doc.docdata.urgency
  end

  # Missing elements handling

  def test_missing_headline_returns_nil
    xml = load_fixture("head_only.xml")
    doc = NITFr::Document.new(xml)

    assert_nil doc.headline
    assert_nil doc.headlines
  end

  def test_missing_byline_returns_nil
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)

    assert_nil doc.byline
  end

  def test_missing_docdata_returns_nil
    xml = load_fixture("body_only.xml")
    doc = NITFr::Document.new(xml)

    assert_nil doc.docdata
    assert_nil doc.doc_id
    assert_nil doc.issue_date
  end

  def test_missing_media_returns_empty_array
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)

    assert_equal [], doc.media
  end

  def test_missing_paragraphs_returns_empty_array
    xml = load_fixture("head_only.xml")
    doc = NITFr::Document.new(xml)

    assert_equal [], doc.paragraphs
  end

  # Nil-safe method chaining

  def test_nil_safe_headline_access
    xml = load_fixture("head_only.xml")
    doc = NITFr::Document.new(xml)

    # Should not raise errors
    assert_nil doc.headlines&.primary
    assert_nil doc.headlines&.secondary
  end

  def test_nil_safe_byline_access
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)

    # Should not raise errors
    assert_nil doc.byline&.person
    assert_nil doc.byline&.title
  end

  def test_nil_safe_docdata_access
    xml = load_fixture("body_only.xml")
    doc = NITFr::Document.new(xml)

    # Should not raise errors
    assert_nil doc.docdata&.copyright_holder
    assert_nil doc.docdata&.urgency
  end

  # Empty content handling

  def test_empty_text_returns_empty_string
    xml = load_fixture("head_only.xml")
    doc = NITFr::Document.new(xml)

    assert_equal "", doc.text
  end

  def test_empty_block_quotes_returns_empty_array
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)

    assert_equal [], doc.body.block_quotes
  end

  def test_empty_identified_content
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)

    # When docdata exists but has no identified-content
    # These should return empty arrays, not error
    assert_equal [], doc.docdata&.subjects || []
    assert_equal [], doc.docdata&.locations || []
    assert_equal [], doc.docdata&.organizations || []
    assert_equal [], doc.docdata&.people || []
  end
end
