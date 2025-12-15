# frozen_string_literal: true

require "test_helper"
require "json"

class SerializationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(@xml)
  end

  # Document serialization

  def test_document_to_h_returns_hash
    assert_instance_of Hash, @document.to_h
  end

  def test_document_to_h_includes_basic_fields
    hash = @document.to_h

    assert_equal "-//IPTC//DTD NITF 3.5//EN", hash[:version]
    assert_equal "October 18, 2007", hash[:change_date]
    assert_equal "19:30", hash[:change_time]
    assert_equal "Sample News Article Title", hash[:title]
    assert_equal "article-2024-001", hash[:doc_id]
    assert_equal "2024-12-15", hash[:issue_date]
  end

  def test_document_to_h_includes_head_and_body
    hash = @document.to_h

    assert_instance_of Hash, hash[:head]
    assert_instance_of Hash, hash[:body]
  end

  def test_document_to_json_returns_valid_json
    json = @document.to_json
    parsed = JSON.parse(json)

    assert_instance_of Hash, parsed
    assert_equal "Sample News Article Title", parsed["title"]
  end

  def test_document_to_json_can_be_pretty_printed
    hash = @document.to_h
    json = JSON.pretty_generate(hash)

    assert json.include?("\n")
  end

  # Head serialization

  def test_head_to_h_includes_fields
    hash = @document.head.to_h

    assert_equal "Sample News Article Title", hash[:title]
    assert_instance_of Hash, hash[:meta]
    assert_instance_of Hash, hash[:pubdata]
    assert_instance_of Hash, hash[:docdata]
  end

  # Body serialization

  def test_body_to_h_includes_fields
    hash = @document.body.to_h

    assert_instance_of Hash, hash[:headline]
    assert_instance_of Hash, hash[:byline]
    assert_equal "SAN FRANCISCO, Dec 15", hash[:dateline]
    assert_instance_of Array, hash[:paragraphs]
  end

  def test_body_to_h_paragraphs_are_hashes
    hash = @document.body.to_h

    hash[:paragraphs].each do |para|
      assert_instance_of Hash, para
      assert para.key?(:text)
    end
  end

  # Headline serialization

  def test_headline_to_h_includes_levels
    hash = @document.headlines.to_h

    assert_equal "Revolutionary Technology Changes Industry", hash[:primary]
    assert_equal "Experts predict widespread adoption within five years", hash[:secondary]
  end

  # Byline serialization

  def test_byline_to_h_includes_fields
    hash = @document.byline.to_h

    assert_equal "Jane Smith", hash[:person]
    assert_equal "Senior Technology Reporter", hash[:title]
    assert hash[:text].include?("Jane Smith")
  end

  # Paragraph serialization

  def test_paragraph_to_h_includes_fields
    para = @document.paragraphs.first
    hash = para.to_h

    assert hash.key?(:text)
    assert hash.key?(:word_count)
    assert_equal true, hash[:lead]
  end

  def test_paragraph_to_h_includes_entities
    para = @document.paragraphs.find { |p| p.people.any? }
    hash = para.to_h

    assert_includes hash[:people], "John Doe"
    assert_includes hash[:organizations], "TechCorp Inc"
    assert_includes hash[:locations], "San Francisco"
  end

  # Media serialization

  def test_media_to_h_includes_fields
    media = @document.media.first
    hash = media.to_h

    assert_equal "image", hash[:type]
    assert_equal "images/tech_launch.jpg", hash[:source]
    assert_equal "image/jpeg", hash[:mime_type]
    assert_equal 800, hash[:width]
    assert_equal 600, hash[:height]
    assert hash[:caption].include?("CEO John Doe")
  end

  # Docdata serialization

  def test_docdata_to_h_includes_fields
    hash = @document.docdata.to_h

    assert_equal "article-2024-001", hash[:doc_id]
    assert_equal "2024-12-15", hash[:issue_date]
    assert_equal 4, hash[:urgency]
    assert_equal "Example News Corp", hash[:copyright][:holder]
  end

  def test_docdata_to_h_includes_identified_content
    hash = @document.docdata.to_h

    assert_includes hash[:subjects], "Technology"
    assert_includes hash[:organizations], "TechCorp Inc"
    assert_includes hash[:people], "John Doe"
    assert_includes hash[:locations], "San Francisco"
  end

  # Compact output (nil values excluded)

  def test_to_h_excludes_nil_values
    hash = @document.to_h

    hash.each_value do |value|
      assert_not_nil value
    end
  end

  def test_to_h_excludes_empty_arrays
    xml = load_fixture("minimal_article.xml")
    doc = NITFr::Document.new(xml)
    hash = doc.body.to_h

    # Empty arrays should not be present
    assert_nil hash[:media]
    assert_nil hash[:block_quotes]
  end

  # Round-trip test

  def test_json_round_trip_preserves_data
    json = @document.to_json
    parsed = JSON.parse(json)

    assert_equal @document.title, parsed["title"]
    assert_equal @document.headline, parsed["body"]["headline"]["primary"]
    assert_equal @document.paragraphs.size, parsed["body"]["paragraphs"].size
  end
end
