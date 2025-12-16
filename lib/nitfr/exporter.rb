# frozen_string_literal: true

module NITFr
  # Provides export functionality for NITF documents
  #
  # Supports conversion to Markdown, plain text, and HTML formats.
  module Exporter
    # Convert document to Markdown format
    #
    # @return [String] Markdown representation of the document
    def to_markdown
      lines = []

      # Title/Headline
      if headline
        lines << "# #{headline}"
        lines << ""
      end

      # Byline
      if byline&.text
        lines << "*#{byline.text}*"
        lines << ""
      end

      # Dateline
      if body&.dateline
        lines << "**#{body.dateline}**"
        lines << ""
      end

      # Abstract
      if body&.abstract
        lines << "> #{body.abstract}"
        lines << ""
      end

      # Paragraphs
      paragraphs.each do |para|
        lines << format_paragraph_markdown(para)
        lines << ""
      end

      # Block quotes
      body&.block_quotes&.each do |quote|
        lines << "> #{quote}"
        lines << ""
      end

      # Footnotes
      if footnotes.any?
        lines << "---"
        lines << ""
        footnotes.each do |fn|
          label = fn.label || "*"
          lines << "[#{label}]: #{fn.value}"
        end
        lines << ""
      end

      lines.join("\n").strip
    end

    # Convert document to plain text format
    #
    # @return [String] plain text representation of the document
    def to_text
      lines = []

      # Title/Headline
      if headline
        lines << headline.upcase
        lines << "=" * headline.length
        lines << ""
      end

      # Byline
      if byline&.text
        lines << byline.text
        lines << ""
      end

      # Dateline
      if body&.dateline
        lines << body.dateline
        lines << ""
      end

      # Paragraphs
      paragraphs.each do |para|
        lines << para.text
        lines << ""
      end

      # Block quotes
      body&.block_quotes&.each do |quote|
        lines << "  \"#{quote}\""
        lines << ""
      end

      # Footnotes
      if footnotes.any?
        lines << "-" * 40
        lines << ""
        footnotes.each do |fn|
          label = fn.label || "*"
          lines << "[#{label}] #{fn.value}"
        end
        lines << ""
      end

      lines.join("\n").strip
    end

    # Convert document to HTML format
    #
    # @param include_wrapper [Boolean] whether to include html/body tags (default: false)
    # @return [String] HTML representation of the document
    def to_html(include_wrapper: false)
      html_parts = []

      # Article container
      html_parts << "<article>"

      # Header section
      html_parts << "  <header>"

      if headline
        html_parts << "    <h1>#{escape_html(headline)}</h1>"
      end

      if byline&.text
        html_parts << "    <p class=\"byline\">#{escape_html(byline.text)}</p>"
      end

      if body&.dateline
        html_parts << "    <p class=\"dateline\">#{escape_html(body.dateline)}</p>"
      end

      html_parts << "  </header>"

      # Abstract
      if body&.abstract
        html_parts << "  <aside class=\"abstract\">"
        html_parts << "    <p>#{escape_html(body.abstract)}</p>"
        html_parts << "  </aside>"
      end

      # Main content
      html_parts << "  <section class=\"content\">"

      paragraphs.each do |para|
        html_parts << format_paragraph_html(para)
      end

      # Block quotes
      body&.block_quotes&.each do |quote|
        html_parts << "    <blockquote>"
        html_parts << "      <p>#{escape_html(quote)}</p>"
        html_parts << "    </blockquote>"
      end

      html_parts << "  </section>"

      # Footnotes
      if footnotes.any?
        html_parts << "  <footer class=\"footnotes\">"
        html_parts << "    <ol>"
        footnotes.each do |fn|
          id_attr = fn.id ? " id=\"#{escape_html(fn.id)}\"" : ""
          html_parts << "      <li#{id_attr}>#{escape_html(fn.value)}</li>"
        end
        html_parts << "    </ol>"
        html_parts << "  </footer>"
      end

      html_parts << "</article>"

      content = html_parts.join("\n")

      if include_wrapper
        wrap_html(content)
      else
        content
      end
    end

    private

    def format_paragraph_markdown(para)
      text = para.text

      # Add emphasis markers
      para.emphasis.each do |em|
        text = text.gsub(em, "*#{em}*")
      end

      # Add strong markers
      para.strong.each do |strong|
        text = text.gsub(strong, "**#{strong}**")
      end

      text
    end

    def format_paragraph_html(para)
      text = escape_html(para.text)

      # Convert line breaks to <br>
      text = text.gsub("\n", "<br>\n")

      # Add emphasis tags
      para.emphasis.each do |em|
        escaped = escape_html(em)
        text = text.gsub(escaped, "<em>#{escaped}</em>")
      end

      # Add strong tags
      para.strong.each do |strong|
        escaped = escape_html(strong)
        text = text.gsub(escaped, "<strong>#{escaped}</strong>")
      end

      classes = []
      classes << "lead" if para.lead?

      class_attr = classes.any? ? " class=\"#{classes.join(' ')}\"" : ""
      "    <p#{class_attr}>#{text}</p>"
    end

    def escape_html(text)
      return "" if text.nil?

      text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
    end

    def wrap_html(content)
      <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>#{escape_html(title || headline || 'NITF Document')}</title>
        </head>
        <body>
        #{content}
        </body>
        </html>
      HTML
    end
  end
end
