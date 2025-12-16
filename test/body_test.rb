# frozen_string_literal: true

require "test_helper"

class BodyTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    document = NITFr::Document.new(xml)
    @body = document.body
  end

  def test_headline_returns_headline_object
    assert_instance_of NITFr::Headline, @body.headline
  end

  def test_byline_returns_byline_object
    assert_instance_of NITFr::Byline, @body.byline
  end

  def test_dateline_returns_dateline_text
    assert_equal "SAN FRANCISCO, Dec 15", @body.dateline
  end

  def test_abstract_returns_abstract_text
    assert_match(/new technology platform/, @body.abstract)
  end

  def test_paragraphs_returns_all_paragraphs
    assert_equal 4, @body.paragraphs.size
  end

  def test_paragraphs_preserves_order
    assert_match(/groundbreaking/, @body.paragraphs.first.text)
  end

  def test_media_returns_all_media_objects
    assert_equal 1, @body.media.size
  end

  def test_block_quotes_extracts_block_quotes
    assert_includes @body.block_quotes, "Innovation distinguishes between a leader and a follower."
  end

  def test_tagline_returns_tagline_from_body_end
    assert_equal "Contact: press@example.com", @body.tagline
  end

  def test_slugline_returns_nil_when_not_present
    assert_nil @body.slugline
  end
end

class SluglineTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("with_slugline.xml")
    @document = NITFr::Document.new(xml)
    @body = @document.body
  end

  def test_body_slugline_returns_slugline_text
    assert_equal "SPORTS-BASKETBALL-NBA", @body.slugline
  end

  def test_document_slugline_returns_slugline_text
    assert_equal "SPORTS-BASKETBALL-NBA", @document.slugline
  end

  def test_slugline_is_memoized
    first_call = @body.slugline
    second_call = @body.slugline

    assert_equal first_call, second_call
  end

  def test_slugline_included_in_body_to_h
    hash = @body.to_h

    assert_equal "SPORTS-BASKETBALL-NBA", hash[:slugline]
  end

  def test_slugline_excluded_from_to_h_when_nil
    xml = load_fixture("simple_article.xml")
    doc = NITFr::Document.new(xml)
    hash = doc.body.to_h

    assert_nil hash[:slugline]
  end
end
