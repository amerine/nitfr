# frozen_string_literal: true

require "test_helper"

class ExporterMarkdownTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(xml)
  end

  def test_to_markdown_returns_string
    assert_instance_of String, @document.to_markdown
  end

  def test_to_markdown_includes_headline
    markdown = @document.to_markdown

    assert_match(/^# Revolutionary Technology/, markdown)
  end

  def test_to_markdown_includes_byline
    markdown = @document.to_markdown

    assert_match(/\*.*Jane Smith.*\*/m, markdown)
  end

  def test_to_markdown_includes_dateline
    markdown = @document.to_markdown

    assert_match(/\*\*SAN FRANCISCO/, markdown)
  end

  def test_to_markdown_includes_abstract
    markdown = @document.to_markdown

    assert_match(/^> .*technology platform/, markdown)
  end

  def test_to_markdown_includes_paragraphs
    markdown = @document.to_markdown

    assert_match(/groundbreaking new technology/, markdown)
  end

  def test_to_markdown_includes_block_quotes
    markdown = @document.to_markdown

    assert_match(/^> Innovation distinguishes/, markdown)
  end

  def test_to_markdown_formats_emphasis
    markdown = @document.to_markdown

    # Emphasis should be wrapped in single asterisks
    assert_match(/\*five years\*/, markdown)
  end
end

class ExporterPlainTextTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(xml)
  end

  def test_to_text_returns_string
    assert_instance_of String, @document.to_text
  end

  def test_to_text_includes_headline_uppercase
    text = @document.to_text

    assert_match(/^REVOLUTIONARY TECHNOLOGY/, text)
  end

  def test_to_text_includes_underline_after_headline
    text = @document.to_text

    assert_match(/^=+$/, text)
  end

  def test_to_text_includes_byline
    text = @document.to_text

    assert_match(/Jane Smith/, text)
  end

  def test_to_text_includes_paragraphs
    text = @document.to_text

    assert_match(/groundbreaking new technology/, text)
  end

  def test_to_text_includes_block_quotes_indented
    text = @document.to_text

    assert_match(/^\s+"Innovation distinguishes/, text)
  end
end

class ExporterHtmlTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("simple_article.xml")
    @document = NITFr::Document.new(xml)
  end

  def test_to_html_returns_string
    assert_instance_of String, @document.to_html
  end

  def test_to_html_includes_article_tag
    html = @document.to_html

    assert_match(/<article>/, html)
    assert_match(/<\/article>/, html)
  end

  def test_to_html_includes_headline_h1
    html = @document.to_html

    assert_match(/<h1>Revolutionary Technology/, html)
  end

  def test_to_html_includes_byline_class
    html = @document.to_html

    assert_match(/<p class="byline">/, html)
  end

  def test_to_html_includes_dateline_class
    html = @document.to_html

    assert_match(/<p class="dateline">/, html)
  end

  def test_to_html_includes_abstract_aside
    html = @document.to_html

    assert_match(/<aside class="abstract">/, html)
  end

  def test_to_html_includes_paragraphs
    html = @document.to_html

    assert_match(/<p>.*groundbreaking.*<\/p>/m, html)
  end

  def test_to_html_marks_lead_paragraph
    html = @document.to_html

    assert_match(/<p class="lead">/, html)
  end

  def test_to_html_includes_block_quotes
    html = @document.to_html

    assert_match(/<blockquote>/, html)
  end

  def test_to_html_escapes_special_characters
    # Create document with special chars
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <nitf version="-//IPTC//DTD NITF 3.5//EN">
        <head><title>Test &amp; Title</title></head>
        <body>
          <body.head><headline><hl1>Test &lt;Headline&gt;</hl1></headline></body.head>
          <body.content><p>Text with "quotes" &amp; special chars</p></body.content>
        </body>
      </nitf>
    XML

    doc = NITFr::Document.new(xml)
    html = doc.to_html

    assert_match(/&amp;/, html)
    assert_match(/&lt;/, html)
    assert_match(/&gt;/, html)
    assert_match(/&quot;/, html)
  end

  def test_to_html_with_wrapper_includes_doctype
    html = @document.to_html(include_wrapper: true)

    assert_match(/^<!DOCTYPE html>/, html)
    assert_match(/<html/, html)
    assert_match(/<head>/, html)
    assert_match(/<body>/, html)
  end

  def test_to_html_wrapper_includes_title
    html = @document.to_html(include_wrapper: true)

    assert_match(/<title>.*Sample News Article.*<\/title>/m, html)
  end
end

class ExporterWithFootnotesTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("with_footnotes.xml")
    @document = NITFr::Document.new(xml)
  end

  def test_to_markdown_includes_footnotes_section
    markdown = @document.to_markdown

    assert_match(/^---$/, markdown)
    assert_match(/\[1\]:.*Control group/, markdown)
  end

  def test_to_text_includes_footnotes_section
    text = @document.to_text

    assert_match(/^-+$/, text)
    assert_match(/\[1\].*Control group/, text)
  end

  def test_to_html_includes_footnotes_footer
    html = @document.to_html

    assert_match(/<footer class="footnotes">/, html)
    assert_match(/<ol>/, html)
    assert_match(/<li id="fn1">/, html)
  end
end

class ExporterWithStrongTest < Test::Unit::TestCase
  include TestHelper

  def setup
    xml = load_fixture("strong_emphasis.xml")
    @document = NITFr::Document.new(xml)
  end

  def test_to_markdown_formats_strong
    markdown = @document.to_markdown

    assert_match(/\*\*bold text\*\*/, markdown)
  end

  def test_to_html_formats_strong
    html = @document.to_html

    assert_match(/<strong>bold text<\/strong>/, html)
  end
end
