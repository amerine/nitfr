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

  # =========================================================================
  # Extended headline levels (hl3, hl4, hl5) tests
  # =========================================================================

  def test_tertiary_returns_nil_when_not_present
    assert_nil @headline.tertiary
  end

  def test_quaternary_returns_nil_when_not_present
    assert_nil @headline.quaternary
  end

  def test_quinary_returns_nil_when_not_present
    assert_nil @headline.quinary
  end

  def test_hl3_is_alias_for_tertiary
    assert_equal @headline.tertiary, @headline.hl3
  end

  def test_hl4_is_alias_for_quaternary
    assert_equal @headline.quaternary, @headline.hl4
  end

  def test_hl5_is_alias_for_quinary
    assert_equal @headline.quinary, @headline.hl5
  end
end

class FullHeadlineTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("full_headlines.xml")
    document = NITFr::Document.new(xml)
    @headline = document.headlines
  end

  def test_tertiary_returns_hl3_text
    assert_equal "Tertiary Headline", @headline.tertiary
  end

  def test_hl3_is_alias_for_tertiary
    assert_equal @headline.tertiary, @headline.hl3
  end

  def test_quaternary_returns_hl4_text
    assert_equal "Quaternary Headline", @headline.quaternary
  end

  def test_hl4_is_alias_for_quaternary
    assert_equal @headline.quaternary, @headline.hl4
  end

  def test_quinary_returns_hl5_text
    assert_equal "Quinary Headline", @headline.quinary
  end

  def test_hl5_is_alias_for_quinary
    assert_equal @headline.quinary, @headline.hl5
  end

  def test_all_returns_all_five_levels
    expected = [
      "Primary Headline",
      "Secondary Headline",
      "Tertiary Headline",
      "Quaternary Headline",
      "Quinary Headline"
    ]
    assert_equal expected, @headline.all
  end

  def test_to_s_joins_all_five_headlines
    expected = "Primary Headline - Secondary Headline - Tertiary Headline - Quaternary Headline - Quinary Headline"
    assert_equal expected, @headline.to_s
  end

  def test_to_h_includes_all_levels
    hash = @headline.to_h

    assert_equal "Primary Headline", hash[:primary]
    assert_equal "Secondary Headline", hash[:secondary]
    assert_equal "Tertiary Headline", hash[:tertiary]
    assert_equal "Quaternary Headline", hash[:quaternary]
    assert_equal "Quinary Headline", hash[:quinary]
  end

  def test_present_returns_true_with_all_levels
    assert @headline.present?
  end
end
