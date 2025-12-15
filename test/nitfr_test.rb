# frozen_string_literal: true

require "test_helper"

class NITFrTest < Test::Unit::TestCase
  include TestHelper

  def test_has_version_number
    assert_not_nil NITFr::VERSION
  end

  def test_parse_valid_nitf_xml_string
    xml = load_fixture("simple_article.xml")
    doc = NITFr.parse(xml)
    assert_instance_of NITFr::Document, doc
  end

  def test_parse_raises_parse_error_for_malformed_xml
    assert_raises(NITFr::ParseError) do
      NITFr.parse("<invalid><xml>")
    end
  end

  def test_parse_raises_invalid_document_error_for_non_nitf_xml
    xml = load_fixture("invalid.xml")
    assert_raises(NITFr::InvalidDocumentError) do
      NITFr.parse(xml)
    end
  end

  def test_parse_file_parses_valid_nitf_file
    doc = NITFr.parse_file(fixture_path("simple_article.xml"))
    assert_instance_of NITFr::Document, doc
    assert_equal "Revolutionary Technology Changes Industry", doc.headline
  end
end
