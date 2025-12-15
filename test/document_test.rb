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

  # Word count tests

  def test_word_count_returns_total_word_count
    count = @document.word_count

    assert_instance_of Integer, count
    assert count > 0
  end

  def test_word_count_equals_sum_of_paragraph_word_counts
    expected = @document.paragraphs.sum(&:word_count)

    assert_equal expected, @document.word_count
  end

  def test_word_count_is_memoized
    first_call = @document.word_count
    second_call = @document.word_count

    assert_equal first_call, second_call
  end

  def test_word_count_returns_zero_for_empty_document
    xml = load_fixture("head_only.xml")
    doc = NITFr::Document.new(xml)

    assert_equal 0, doc.word_count
  end

  # Reading time tests

  def test_reading_time_returns_string
    assert_instance_of String, @document.reading_time
  end

  def test_reading_time_includes_min_read
    assert_match(/min read/, @document.reading_time)
  end

  def test_reading_time_with_default_speed
    # Default is 200 words per minute
    expected_minutes = (@document.word_count / 200.0).ceil
    expected = "#{expected_minutes} min read"

    assert_equal expected, @document.reading_time
  end

  def test_reading_time_with_custom_speed
    # Slower reader at 100 wpm should take longer
    slow_time = @document.reading_time(words_per_minute: 100)
    fast_time = @document.reading_time(words_per_minute: 300)

    slow_minutes = slow_time.match(/(\d+)/)[1].to_i
    fast_minutes = fast_time.match(/(\d+)/)[1].to_i

    assert slow_minutes >= fast_minutes
  end

  def test_reading_time_singular_minute
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)

    # With few words, should be "1 min read"
    assert_match(/1 min read|Less than 1 min read/, doc.reading_time)
  end

  def test_reading_time_less_than_one_minute
    xml = load_fixture("head_only.xml")
    doc = NITFr::Document.new(xml)

    # Empty document has 0 words
    result = doc.reading_time

    assert_equal "Less than 1 min read", result
  end
end
