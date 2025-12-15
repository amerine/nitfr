# frozen_string_literal: true

require "test_helper"

class BylineTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    document = NITFr::Document.new(xml)
    @byline = document.byline
  end

  def test_text_returns_full_byline_text
    assert_match(/Jane Smith/, @byline.text)
  end

  def test_person_returns_author_name
    assert_equal "Jane Smith", @byline.person
  end

  def test_title_returns_byline_title
    assert_equal "Senior Technology Reporter", @byline.title
  end

  def test_present_returns_true_when_byline_has_content
    assert @byline.present?
  end

  def test_to_s_is_alias_for_text
    assert_equal @byline.text, @byline.to_s
  end
end
