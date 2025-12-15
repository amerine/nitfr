# frozen_string_literal: true

require "test_helper"

class HeadlineTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    document = NITFr::Document.new(xml)
    @headline = document.headlines
  end

  def test_primary_returns_hl1_text
    assert_equal "Revolutionary Technology Changes Industry", @headline.primary
  end

  def test_hl1_is_alias_for_primary
    assert_equal @headline.primary, @headline.hl1
  end

  def test_secondary_returns_hl2_text
    assert_equal "Experts predict widespread adoption within five years", @headline.secondary
  end

  def test_hl2_is_alias_for_secondary
    assert_equal @headline.secondary, @headline.hl2
  end

  def test_all_returns_all_headline_levels
    expected = [
      "Revolutionary Technology Changes Industry",
      "Experts predict widespread adoption within five years"
    ]
    assert_equal expected, @headline.all
  end

  def test_to_s_joins_all_headlines
    expected = "Revolutionary Technology Changes Industry - Experts predict widespread adoption within five years"
    assert_equal expected, @headline.to_s
  end

  def test_present_returns_true_when_headline_exists
    assert @headline.present?
  end
end
