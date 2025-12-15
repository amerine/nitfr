# frozen_string_literal: true

require "test_helper"

class MediaTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    document = NITFr::Document.new(xml)
    @media = document.media.first
  end

  def test_type_returns_media_type
    assert_equal "image", @media.type
  end

  def test_image_returns_true_for_image_type
    assert @media.image?
  end

  def test_audio_returns_false_for_image_type
    assert_false @media.audio?
  end

  def test_video_returns_false_for_image_type
    assert_false @media.video?
  end

  def test_caption_returns_caption_text
    assert_match(/CEO John Doe/, @media.caption)
  end

  def test_producer_returns_producer_credit
    assert_equal "Photo by Alex Johnson", @media.producer
  end

  def test_credit_is_alias_for_producer
    assert_equal @media.producer, @media.credit
  end

  def test_references_returns_all_media_references
    assert_equal 1, @media.references.size
  end

  def test_references_includes_reference_details
    ref = @media.references.first
    assert_equal "images/tech_launch.jpg", ref[:source]
    assert_equal "image/jpeg", ref[:mime_type]
    assert_equal 800, ref[:width]
    assert_equal 600, ref[:height]
  end

  def test_source_returns_primary_reference_source
    assert_equal "images/tech_launch.jpg", @media.source
  end

  def test_alt_text_returns_alternate_text
    assert_equal "TechCorp product launch event", @media.alt_text
  end

  def test_width_returns_width
    assert_equal 800, @media.width
  end

  def test_height_returns_height
    assert_equal 600, @media.height
  end
end
