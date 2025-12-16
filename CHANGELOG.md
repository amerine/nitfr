# Changelog

All notable changes to NITFr will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-12-15

### Added

#### Serialization
- `Document#to_h` - Hash representation of entire document
- `Document#to_json` - JSON serialization
- `Head#to_h` - Hash representation
- `Body#to_h` - Hash representation
- `Headline#to_h` - Hash representation
- `Byline#to_h` - Hash representation
- `Paragraph#to_h` - Hash representation
- `Media#to_h` - Hash representation
- `Docdata#to_h` - Hash representation
- `Footnote#to_h` - Hash representation

#### Reading Statistics
- `Document#word_count` - Total word count across all paragraphs (memoized)
- `Document#reading_time(words_per_minute:)` - Estimated reading time (e.g., "3 min read")

#### Search & Query
- `Document#search(query, case_sensitive:)` - Full-text search with match positions and context
- `Document#contains?(query, case_sensitive:)` - Check if text exists in document
- `Document#paragraphs_containing(query, case_sensitive:)` - Find paragraphs by text
- `Document#paragraphs_mentioning(person:, org:, location:, match_all:)` - Find paragraphs by entity
- `Document#paragraphs_where(&block)` - Custom predicate filtering
- `Document#find_paragraph(&block)` - Find first matching paragraph
- `Document#find_media(type:)` - Filter media by type
- `Document#images` / `#videos` / `#audio` - Media type convenience accessors
- `Document#all_people` - All unique person names (memoized)
- `Document#all_organizations` - All unique organization names (memoized)
- `Document#all_locations` - All unique location names (memoized)
- `Document#all_entities` - Hash of all entity types (memoized, single-pass)
- `Document#count_occurrences(query, case_sensitive:)` - Count matches
- `Document#excerpt(query, context_chars:, case_sensitive:)` - Context snippet around match

#### Paragraph Search Helpers
- `Paragraph#contains?(query, case_sensitive:)` - Text search within paragraph
- `Paragraph#mentions_person?(name, exact:)` - Check for person reference
- `Paragraph#mentions_org?(name, exact:)` - Check for organization reference
- `Paragraph#mentions_location?(name, exact:)` - Check for location reference
- `Paragraph#mentions?(person:, org:, location:)` - Multi-entity check
- `Paragraph#has_links?` - Check if paragraph contains links
- `Paragraph#has_emphasis?` - Check if paragraph contains emphasis
- `Paragraph#has_strong?` - Check if paragraph contains strong text
- `Paragraph#has_entities?` - Check if paragraph contains any entities

#### Extended Headline Levels
- `Headline#tertiary` / `#hl3` - Tertiary headline
- `Headline#quaternary` / `#hl4` - Quaternary headline
- `Headline#quinary` / `#hl5` - Quinary headline
- Updated `Headline#all` and `Headline#to_h` to include all five levels

#### Strong/Bold Text
- `Paragraph#strong` - Extract `<strong>` elements (alongside existing `<em>` support)
- `Paragraph#has_strong?` - Check for strong text
- Included in `Paragraph#to_h` serialization

#### Slugline Support
- `Document#slugline` - Section/category identifier
- `Body#slugline` - Slugline from body.head
- Included in `Body#to_h` serialization

#### Footnotes
- `Footnote` class for parsing `<fn>` elements with label and value
- `Document#footnotes` - Array of Footnote objects
- `Body#footnotes` - Footnotes from body.content and body.end
- `Footnote#id` - Footnote ID attribute
- `Footnote#label` - Reference marker (e.g., "1", "*")
- `Footnote#value` / `#text` / `#content` - Footnote content
- `Footnote#present?` - Check if has content
- Included in `Body#to_h` serialization

#### Line Break Preservation
- `<br/>` elements now converted to newline characters in text extraction
- Preserves intended line breaks within paragraph content

#### Export Formats
- `Document#to_markdown` - Markdown export with headers, emphasis, blockquotes, footnotes
- `Document#to_text` - Plain text export with underlined headlines
- `Document#to_html(include_wrapper:)` - Semantic HTML with article/header/section structure
- `Exporter` module for export functionality

### Notes

- 337 tests with comprehensive coverage (173 new tests)
- Memoization added for frequently accessed computed values
- `SearchPattern` module for consistent pattern building across classes

---

## [1.0.0] - 2025-12-14

### Added

#### Core Parsing
- `NITFr.parse(xml)` - Parse NITF XML string into a Document
- `NITFr.parse_file(path)` - Parse NITF file with encoding support
- `Document` class as main entry point for NITF content
- `Head` class for document head section (title, meta, pubdata, docdata)
- `Body` class for document body section
- `Headline` class with primary (hl1) and secondary (hl2) headline support
- `Byline` class for author/contributor information
- `Paragraph` class for body content paragraphs
- `Media` class for embedded media (images, video, audio)
- `Docdata` class for document metadata

#### Document Attributes
- `Document#title` - Document title from head
- `Document#headline` - Primary headline text
- `Document#headlines` - Full Headline object
- `Document#byline` - Byline object
- `Document#paragraphs` - Array of Paragraph objects
- `Document#text` - Full concatenated article text
- `Document#media` - Array of Media objects
- `Document#docdata` - Document metadata
- `Document#doc_id` - Document identifier
- `Document#issue_date` - Issue date
- `Document#version` - NITF version
- `Document#change_date` - Last change date
- `Document#change_time` - Last change time
- `Document#valid?` - Check if valid NITF document
- `Document#to_xml` - Original XML string

#### Headline Support
- `Headline#primary` / `#hl1` - Primary headline
- `Headline#secondary` / `#hl2` - Secondary headline
- `Headline#all` - Array of headline levels
- `Headline#to_s` - Combined headline text
- `Headline#present?` - Check if headline exists

#### Body Content
- `Body#headline` - Headline object
- `Body#byline` - Byline object
- `Body#dateline` - Dateline text
- `Body#abstract` - Article abstract/summary
- `Body#distributor` - Wire service/distributor
- `Body#series` - Series information
- `Body#paragraphs` - Paragraph array
- `Body#media` - Media array
- `Body#block_quotes` - Block quote texts
- `Body#lists` - List structures (ul, ol, dl)
- `Body#tables` - Raw table elements
- `Body#tagline` - Tagline from body.end
- `Body#notes` - Editorial notes

#### Byline Features
- `Byline#person` - Author name
- `Byline#title` - Author title/role
- `Byline#org` - Organization
- `Byline#location` - Location
- `Byline#text` - Full byline text
- `Byline#present?` - Check if byline has content

#### Paragraph Features
- `Paragraph#text` - Plain text content
- `Paragraph#id` - Paragraph ID attribute
- `Paragraph#lede` - Lede attribute value
- `Paragraph#lead?` - Check if lead paragraph
- `Paragraph#word_count` - Word count
- `Paragraph#inner_html` - Raw XML content
- `Paragraph#present?` - Check if has content

#### Entity Extraction (Lazy Batch)
- `Paragraph#people` - Person references (`<person>`)
- `Paragraph#organizations` - Organization references (`<org>`)
- `Paragraph#locations` - Location references (`<location>`)
- `Paragraph#emphasis` - Emphasized text (`<em>`)
- `Paragraph#links` - Link information (text and href)
- Efficient single-pass DOM traversal on first access

#### Media Support
- `Media#type` - Media type (image, video, audio)
- `Media#image?` / `#video?` / `#audio?` - Type checks
- `Media#caption` - Media caption
- `Media#producer` / `#credit` - Credit information
- `Media#source` / `#src` / `#url` - Source URL
- `Media#mime_type` - MIME type
- `Media#alt_text` - Alternate text
- `Media#width` / `#height` - Dimensions
- `Media#references` - All media references
- `Media#primary_reference` - First/main reference
- `Media#metadata` - Additional metadata

#### Docdata Features
- `Docdata#doc_id` - Document identifier
- `Docdata#issue_date` - Issue date (parsed as Date)
- `Docdata#release_date` - Release date
- `Docdata#expire_date` - Expiration date
- `Docdata#urgency` - Urgency level (1-8)
- `Docdata#fixture` - Fixture identifier
- `Docdata#doc_scope` - Document scope
- `Docdata#ed_msg` - Editorial message
- `Docdata#series` - Series information
- `Docdata#copyright` - Copyright holder and year
- `Docdata#subjects` - Subject classifiers
- `Docdata#people` - Identified people
- `Docdata#organizations` - Identified organizations
- `Docdata#locations` - Identified locations

#### Head Features
- `Head#title` - Document title
- `Head#meta` - Meta tags as hash
- `Head#pubdata` - Publication data
- `Head#docdata` - Docdata object
- `Head#revision_history` - Revision entries

#### Text Processing
- `TextExtractor` module for recursive text extraction from nested elements

#### Security
- XXE (XML External Entity) attack protection
- Entity expansion limits configured at load time
- REXML security settings (100 entity limit, 10KB text limit)
- No external entity processing

#### Error Handling
- `NITFr::ParseError` - XML parsing errors
- `NITFr::InvalidDocumentError` - Invalid NITF structure (missing `<nitf>` root)

### Notes

- Pure Ruby implementation using REXML (no native dependencies)
- Lazy batch extraction for efficient entity parsing
- 164 tests with comprehensive coverage
