# frozen_string_literal: true

require "test_helper"

class LineBreakTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("with_line_breaks.xml")
    @document = NITFr::Document.new(xml)
    @paragraphs = @document.paragraphs
  end

  def test_paragraph_text_preserves_line_breaks
    poem_para = @paragraphs.first

    assert_includes poem_para.text, "\n"
  end

  def test_line_breaks_convert_to_newlines
    poem_para = @paragraphs.first
    lines = poem_para.text.split("\n")

    assert_equal 3, lines.size
    assert_match(/First line/, lines[0])
    assert_match(/Second line/, lines[1])
    assert_match(/Third line/, lines[2])
  end

  def test_paragraphs_without_breaks_unchanged
    plain_para = @paragraphs[1]

    assert_false plain_para.text.include?("\n")
    assert_match(/paragraph without any line breaks/, plain_para.text)
  end

  def test_multiple_paragraphs_with_breaks
    address_para = @paragraphs[2]
    lines = address_para.text.split("\n")

    assert_equal 3, lines.size
    assert_match(/Address line one/, lines[0])
    assert_match(/Address line two/, lines[1])
    assert_match(/City, State ZIP/, lines[2])
  end

  def test_word_count_with_line_breaks
    poem_para = @paragraphs.first

    # Word count should count words across all lines
    # "First line of the poem" + "Second line of the poem" + "Third line of the poem"
    # = 5 + 5 + 5 = 15 words
    assert poem_para.word_count >= 15
  end

  def test_document_text_includes_line_breaks
    # Document text joins paragraphs with double newlines
    # but preserves single newlines within paragraphs
    assert @document.text.include?("\n")
  end
end

class LineBreakTextExtractorTest < Test::Unit::TestCase
  include TestHelper

  def test_extract_all_text_preserves_br_as_newline
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <nitf version="-//IPTC//DTD NITF 3.5//EN">
        <head><title>Test</title></head>
        <body>
          <body.head><headline><hl1>Test</hl1></headline></body.head>
          <body.content>
            <p>Line one<br/>Line two</p>
          </body.content>
        </body>
      </nitf>
    XML

    doc = NITFr::Document.new(xml)
    para = doc.paragraphs.first

    assert_equal "Line one\nLine two", para.text
  end

  def test_extract_all_text_handles_self_closing_br
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <nitf version="-//IPTC//DTD NITF 3.5//EN">
        <head><title>Test</title></head>
        <body>
          <body.head><headline><hl1>Test</hl1></headline></body.head>
          <body.content>
            <p>Before<br/>After</p>
          </body.content>
        </body>
      </nitf>
    XML

    doc = NITFr::Document.new(xml)
    para = doc.paragraphs.first

    assert_includes para.text, "\n"
  end

  def test_extract_all_text_handles_consecutive_breaks
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <nitf version="-//IPTC//DTD NITF 3.5//EN">
        <head><title>Test</title></head>
        <body>
          <body.head><headline><hl1>Test</hl1></headline></body.head>
          <body.content>
            <p>Line one<br/><br/>Line three</p>
          </body.content>
        </body>
      </nitf>
    XML

    doc = NITFr::Document.new(xml)
    para = doc.paragraphs.first

    # Should have two consecutive newlines
    assert_includes para.text, "\n\n"
  end
end
