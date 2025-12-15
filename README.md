# NITFr

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0-red.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Ruby gem for parsing NITF (News Industry Text Format) XML files.

NITF is a standard XML format developed by the IPTC (International Press Telecommunications Council) for marking up news articles. NITFr makes it easy for Ruby applications to parse and extract content from NITF documents.

## Requirements

- Ruby 3.0 or higher
- No native extensions or external dependencies (pure Ruby using REXML)

## Security

NITFr is designed with security in mind:

- **XXE Protection**: REXML does not expand external entities by default, protecting against XML External Entity (XXE) attacks
- **Entity Expansion Limits**: Configured to prevent "Billion Laughs" and similar entity expansion attacks
- **No Code Execution**: The parser never evaluates or executes content from XML documents

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nitfr'
```

And then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install nitfr
```

## Usage

### Basic Parsing

```ruby
require 'nitfr'

# Parse from a string
xml = File.read('article.xml')
doc = NITFr.parse(xml)

# Or parse directly from a file
doc = NITFr.parse_file('article.xml')

# With explicit encoding
doc = NITFr.parse_file('article.xml', encoding: 'ISO-8859-1')
```

### Accessing Content

```ruby
# Get the headline
doc.headline          # => "Revolutionary Technology Changes Industry"
doc.headlines.primary # => "Revolutionary Technology Changes Industry"
doc.headlines.secondary # => "Experts predict widespread adoption"

# Get byline information
doc.byline.text       # => "By Jane Smith, Senior Reporter"
doc.byline.person     # => "Jane Smith"
doc.byline.title      # => "Senior Reporter"

# Get the article text
doc.paragraphs.each do |para|
  puts para.text
end

# Or get all text at once
puts doc.text
```

### Working with Metadata

```ruby
# Document metadata
doc.title           # => "Sample News Article Title"
doc.doc_id          # => "article-2024-001"
doc.issue_date      # => #<Date: 2024-12-15>

# Copyright info
doc.docdata.copyright_holder  # => "Example News Corp"
doc.docdata.copyright_year    # => "2024"

# Urgency (1-8, 1 being most urgent)
doc.docdata.urgency           # => 4

# Identified content
doc.docdata.subjects      # => ["Technology", "Business"]
doc.docdata.organizations # => ["TechCorp Inc"]
doc.docdata.people        # => ["John Doe"]
doc.docdata.locations     # => ["San Francisco"]
```

### Working with Body Content

```ruby
# Access the body section
body = doc.body

# Dateline and abstract
body.dateline   # => "SAN FRANCISCO, Dec 15"
body.abstract   # => "A new technology platform..."

# Block quotes
body.block_quotes  # => ["Innovation distinguishes..."]

# Tagline from body.end
body.tagline    # => "Contact: press@example.com"
```

### Working with Paragraphs

```ruby
doc.paragraphs.each do |para|
  # Check if it's the lead paragraph
  puts "LEAD: " if para.lead?

  # Get plain text
  puts para.text

  # Get entities mentioned in this paragraph
  puts "People: #{para.people.join(', ')}"
  puts "Organizations: #{para.organizations.join(', ')}"
  puts "Locations: #{para.locations.join(', ')}"

  # Get emphasized text
  puts "Emphasized: #{para.emphasis.join(', ')}"

  # Get links
  para.links.each do |link|
    puts "Link: #{link[:text]} -> #{link[:href]}"
  end

  # Word count
  puts "Words: #{para.word_count}"
end
```

### Working with Media

```ruby
doc.media.each do |media|
  puts "Caption: #{media.caption}"
  puts "Credit: #{media.credit}"
  puts "MIME type: #{media.mime_type}"

  if media.image?
    puts "Image: #{media.source}"
    puts "Size: #{media.width}x#{media.height}"
    puts "Alt text: #{media.alt_text}"
  elsif media.video?
    puts "Video: #{media.source}"
  elsif media.audio?
    puts "Audio: #{media.source}"
  end

  # Access all references (different sizes/formats)
  media.references.each do |ref|
    puts "  #{ref[:source]} (#{ref[:mime_type]})"
  end
end
```

### Error Handling

```ruby
begin
  doc = NITFr.parse(xml)
rescue NITFr::ParseError => e
  puts "Invalid XML: #{e.message}"
rescue NITFr::InvalidDocumentError => e
  puts "Not a valid NITF document: #{e.message}"
end
```

### Document Attributes

```ruby
# NITF version and change information
doc.version      # => "-//IPTC//DTD NITF 3.5//EN"
doc.change_date  # => "October 18, 2007"
doc.change_time  # => "19:30"

# Check validity
doc.valid?       # => true

# Get raw XML
doc.to_xml       # => "<?xml version..."
```

## Advanced Usage

### Head Section Details

```ruby
head = doc.head

# Meta tags as a hash
head.meta        # => {"keywords" => "tech, news", "author" => "Jane"}
head.keywords    # => ["tech, news"]

# Publication data
head.pubdata[:type]        # => "print"
head.pubdata[:name]        # => "Example Times"
head.pubdata[:edition]     # => "Morning"
head.pubdata[:volume]      # => "42"

# Revision history
head.revision_history.each do |rev|
  puts "#{rev[:name]} (#{rev[:function]}): #{rev[:comment]}"
end
```

### Extended Docdata

```ruby
docdata = doc.docdata

# Additional dates
docdata.release_date  # => #<Date: 2024-12-15>
docdata.expire_date   # => #<Date: 2024-12-31>

# Document scope and fixture
docdata.doc_scope     # => "national"
docdata.fixture       # => "fixture-123"

# Series information
docdata.series[:name]   # => "Investigation"
docdata.series[:part]   # => 2
docdata.series[:total]  # => 5

# Editorial status
docdata.management_status[:info]         # => "Approved"
docdata.management_status[:message_type] # => "advisory"
```

### Body Section Extras

```ruby
body = doc.body

# Distributor and series
body.distributor  # => "Wire Service"
body.series[:name]      # => "Special Report"
body.series[:part]      # => "1"
body.series[:totalpart] # => "3"

# Lists in the content
body.lists.each do |list|
  puts "#{list[:type]}: #{list[:items].join(', ')}"
end

# Tables (returns raw REXML elements)
body.tables.each do |table|
  # Process table XML as needed
end

# Notes from body.end
body.notes  # => ["Editor's note: ...", "Correction: ..."]

# Bibliography
body.body_end_content[:bibliography]  # => ["Source 1", "Source 2"]
```

## NITF Structure

A typical NITF document has this structure:

```xml
<nitf>
  <head>
    <title>...</title>
    <docdata>
      <doc-id id-string="..."/>
      <date.issue norm="YYYYMMDD"/>
      ...
    </docdata>
  </head>
  <body>
    <body.head>
      <headline>
        <hl1>Primary Headline</hl1>
        <hl2>Secondary Headline</hl2>
      </headline>
      <byline>By Author Name</byline>
      <dateline>CITY, Date</dateline>
    </body.head>
    <body.content>
      <p>Paragraph content...</p>
      <media media-type="image">...</media>
    </body.content>
    <body.end>
      <tagline>...</tagline>
    </body.end>
  </body>
</nitf>
```

## Development

After checking out the repo, install dependencies and run the tests:

```bash
bundle install
bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amerine/nitfr.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## References

- [IPTC NITF Specification](https://iptc.org/standards/nitf/)
- [NITF 3.5 DTD](http://www.nitf.org/IPTC/NITF/3.5/specification/nitf-3-5.dtd)
