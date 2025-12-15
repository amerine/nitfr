# frozen_string_literal: true

require "test_helper"

class DocumentTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(@xml)
  end

  def test_parses_valid_nitf_xml
    assert @document.valid?
  end

  def test_extracts_version_information
    assert_equal "-//IPTC//DTD NITF 3.5//EN", @document.version
  end

  def test_extracts_change_date
    assert_equal "October 18, 2007", @document.change_date
  end

  def test_extracts_change_time
    assert_equal "19:30", @document.change_time
  end

  def test_title_returns_document_title
    assert_equal "Sample News Article Title", @document.title
  end

  def test_headline_returns_primary_headline
    assert_equal "Revolutionary Technology Changes Industry", @document.headline
  end

  def test_headlines_returns_headline_object
    assert_instance_of NITFr::Headline, @document.headlines
  end

  def test_headlines_has_primary_and_secondary
    assert_equal "Revolutionary Technology Changes Industry", @document.headlines.primary
    assert_equal "Experts predict widespread adoption within five years", @document.headlines.secondary
  end

  def test_byline_returns_byline_object
    assert_instance_of NITFr::Byline, @document.byline
  end

  def test_byline_contains_information
    assert_equal "Jane Smith", @document.byline.person
    assert_equal "Senior Technology Reporter", @document.byline.title
  end

  def test_paragraphs_returns_array_of_paragraph_objects
    @document.paragraphs.each do |para|
      assert_instance_of NITFr::Paragraph, para
    end
  end

  def test_paragraphs_extracts_all_paragraphs
    assert_equal 4, @document.paragraphs.size
  end

  def test_paragraphs_identifies_lead_paragraph
    assert @document.paragraphs.first.lead?
  end

  def test_text_returns_concatenated_paragraph_text
    assert_match(/groundbreaking new technology/, @document.text)
    assert_match(/game-changer/, @document.text)
  end

  def test_media_returns_array_of_media_objects
    @document.media.each do |media|
      assert_instance_of NITFr::Media, media
    end
  end

  def test_media_extracts_media_information
    assert_equal "image", @document.media.first.type
    assert_match(/CEO John Doe/, @document.media.first.caption)
  end

  def test_docdata_returns_docdata_object
    assert_instance_of NITFr::Docdata, @document.docdata
  end

  def test_doc_id_returns_document_id
    assert_equal "article-2024-001", @document.doc_id
  end

  def test_issue_date_returns_date
    assert_equal Date.new(2024, 12, 15), @document.issue_date
  end

  def test_to_xml_returns_original_xml
    assert_match(/<nitf/, @document.to_xml)
  end

  def test_handles_minimal_nitf_documents
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)

    assert_equal "Minimal Article", doc.title
    assert_equal "Simple Headline", doc.headline
    assert_equal 1, doc.paragraphs.size
  end
end
