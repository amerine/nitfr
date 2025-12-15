# frozen_string_literal: true

require "test_helper"

class DocdataTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    document = NITFr::Document.new(xml)
    @docdata = document.docdata
  end

  def test_doc_id_returns_document_id
    assert_equal "article-2024-001", @docdata.doc_id
  end

  def test_issue_date_returns_date_object
    assert_equal Date.new(2024, 12, 15), @docdata.issue_date
  end

  def test_release_date_returns_release_date
    assert_equal Date.new(2024, 12, 15), @docdata.release_date
  end

  def test_urgency_returns_urgency_level
    assert_equal 4, @docdata.urgency
  end

  def test_copyright_returns_copyright_information
    assert_equal "Example News Corp", @docdata.copyright[:holder]
    assert_equal "2024", @docdata.copyright[:year]
  end

  def test_copyright_holder_returns_holder
    assert_equal "Example News Corp", @docdata.copyright_holder
  end

  def test_copyright_year_returns_year
    assert_equal "2024", @docdata.copyright_year
  end

  def test_subjects_returns_subject_classifiers
    assert_includes @docdata.subjects, "Technology"
    assert_includes @docdata.subjects, "Business"
  end

  def test_locations_returns_location_identifiers
    assert_includes @docdata.locations, "San Francisco"
  end

  def test_organizations_returns_organization_identifiers
    assert_includes @docdata.organizations, "TechCorp Inc"
  end

  def test_people_returns_person_identifiers
    assert_includes @docdata.people, "John Doe"
  end
end
