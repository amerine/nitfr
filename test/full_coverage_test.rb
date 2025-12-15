# frozen_string_literal: true

require "test_helper"

class FullCoverageTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @xml = load_fixture("full_featured.xml")
    @document = NITFr::Document.new(@xml)
  end

  # Head tests

  def test_head_revision_history
    history = @document.head.revision_history
    assert_instance_of Array, history
    assert_equal 1, history.size
    assert_equal "Initial version", history.first[:comment]
    assert_equal "Editor", history.first[:name]
    assert_equal "editor", history.first[:function]
  end

  # Body tests

  def test_body_distributor
    assert_equal "Wire Service", @document.body.distributor
  end

  def test_body_series
    series = @document.body.series
    assert_instance_of Hash, series
    assert_equal "Investigation", series[:name]
    assert_equal "2", series[:part]
    assert_equal "3", series[:totalpart]
  end

  def test_body_lists
    lists = @document.body.lists
    assert_equal 2, lists.size

    # Unordered list
    ul = lists.find { |l| l[:type] == "ul" }
    assert_not_nil ul
    assert_includes ul[:items], "List item 1"
    assert_includes ul[:items], "List item 2"

    # Ordered list
    ol = lists.find { |l| l[:type] == "ol" }
    assert_not_nil ol
    assert_includes ol[:items], "Ordered item 1"
  end

  def test_body_tables
    tables = @document.body.tables
    assert_equal 1, tables.size
    assert_instance_of REXML::Element, tables.first
  end

  def test_body_notes
    notes = @document.body.notes
    assert_equal 2, notes.size
    assert_includes notes, "Editor's note: This is a test."
    assert_includes notes, "Second note."
  end

  def test_body_end_content_bibliography
    content = @document.body.body_end_content
    assert_equal 2, content[:bibliography].size
    assert_includes content[:bibliography], "Reference 1"
  end

  # Docdata tests

  def test_docdata_expire_date
    assert_equal Date.new(2025, 12, 15), @document.docdata.expire_date
  end

  def test_docdata_doc_scope
    assert_equal "national", @document.docdata.doc_scope
  end

  def test_docdata_fixture
    assert_equal "fixture-123", @document.docdata.fixture
  end

  def test_docdata_series
    series = @document.docdata.series
    assert_equal "Test Series", series[:name]
    assert_equal 1, series[:part]
    assert_equal 5, series[:total]
  end

  def test_docdata_management_status
    status = @document.docdata.management_status
    assert_equal "Test message", status[:info]
    assert_equal "advisory", status[:message_type]
  end

  # Byline tests

  def test_byline_org
    assert_equal "News Organization", @document.byline.org
  end

  def test_byline_location
    assert_equal "New York", @document.byline.location
  end

  # Paragraph tests

  def test_paragraph_id
    para = @document.paragraphs.first
    assert_equal "p1", para.id
  end

  def test_paragraph_inner_html
    para = @document.paragraphs.first
    html = para.inner_html
    assert_match(/<em>emphasized<\/em>/, html)
  end

  # Media tests

  def test_multiple_media_types
    media = @document.media
    assert_equal 2, media.size

    image = media.find(&:image?)
    assert_not_nil image

    video = media.find(&:video?)
    assert_not_nil video
  end

  def test_media_metadata
    image = @document.media.find(&:image?)
    metadata = image.metadata
    assert_equal "img1", metadata[:id]
    assert_equal "photo", metadata[:class]
  end

  def test_media_mime_type
    image = @document.media.find(&:image?)
    assert_equal "image/jpeg", image.mime_type
  end

  def test_video_media
    video = @document.media.find(&:video?)
    assert video.video?
    assert_false video.image?
    assert_false video.audio?
    assert_equal "test.mp4", video.source
  end
end
