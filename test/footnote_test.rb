# frozen_string_literal: true

require "test_helper"

class FootnoteTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("with_footnotes.xml")
    @document = NITFr::Document.new(xml)
    @footnotes = @document.footnotes
  end

  def test_document_footnotes_returns_array
    assert_instance_of Array, @footnotes
  end

  def test_document_footnotes_returns_footnote_objects
    @footnotes.each do |fn|
      assert_instance_of NITFr::Footnote, fn
    end
  end

  def test_footnotes_count_includes_content_and_end
    # 2 in body.content + 1 in body.end = 3 total
    assert_equal 3, @footnotes.size
  end

  def test_footnote_id_returns_id_attribute
    assert_equal "fn1", @footnotes.first.id
  end

  def test_footnote_label_returns_label_text
    assert_equal "1", @footnotes.first.label
    assert_equal "2", @footnotes[1].label
    assert_equal "*", @footnotes[2].label
  end

  def test_footnote_value_returns_value_text
    assert_match(/Control group/, @footnotes.first.value)
    assert_match(/Statistical significance/, @footnotes[1].value)
    assert_match(/National Science Foundation/, @footnotes[2].value)
  end

  def test_footnote_text_is_alias_for_value
    assert_equal @footnotes.first.value, @footnotes.first.text
  end

  def test_footnote_content_is_alias_for_value
    assert_equal @footnotes.first.value, @footnotes.first.content
  end

  def test_footnote_present_returns_true_when_has_value
    assert @footnotes.first.present?
  end

  def test_footnote_to_h_returns_hash
    hash = @footnotes.first.to_h

    assert_instance_of Hash, hash
    assert_equal "fn1", hash[:id]
    assert_equal "1", hash[:label]
    assert_match(/Control group/, hash[:value])
  end

  def test_body_footnotes_returns_same_as_document
    assert_equal @document.footnotes.size, @document.body.footnotes.size
  end

  def test_footnotes_included_in_body_to_h
    hash = @document.body.to_h

    assert hash.key?(:footnotes)
    assert_equal 3, hash[:footnotes].size
  end

  def test_footnotes_excluded_from_to_h_when_empty
    xml = load_fixture("simple_article.xml")
    doc = NITFr::Document.new(xml)
    hash = doc.body.to_h

    assert_nil hash[:footnotes]
  end
end

class FootnoteEmptyTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(xml)
  end

  def test_footnotes_returns_empty_array_when_none
    assert_equal [], @document.footnotes
  end

  def test_body_footnotes_returns_empty_array_when_none
    assert_equal [], @document.body.footnotes
  end
end
