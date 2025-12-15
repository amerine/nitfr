# frozen_string_literal: true

module NITFr
  # Base error class for NITFr
  class Error < StandardError; end

  # Raised when XML parsing fails
  class ParseError < Error; end

  # Raised when the document is not valid NITF
  class InvalidDocumentError < Error; end
end
