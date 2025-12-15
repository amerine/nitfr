# frozen_string_literal: true

require "test_helper"

class HeadTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    document = NITFr::Document.new(xml)
    @head = document.head
  end

  def test_title_returns_title_text
    assert_equal "Sample News Article Title", @head.title
  end

  def test_docdata_returns_docdata_object
    assert_instance_of NITFr::Docdata, @head.docdata
  end

  def test_pubdata_returns_publication_metadata
    assert_equal "print", @head.pubdata[:type]
    assert_equal "Example Times", @head.pubdata[:name]
    assert_equal "Morning", @head.pubdata[:edition]
  end

  def test_keywords_extracts_keywords_from_meta_tags
    assert_includes @head.keywords, "technology, innovation, startup"
  end

  def test_meta_returns_all_meta_tags_as_hash
    assert_equal "technology, innovation, startup", @head.meta["keywords"]
    assert_equal "Jane Smith", @head.meta["author"]
  end
end
