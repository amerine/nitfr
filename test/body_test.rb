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
end
