# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "nitfr"
require "test/unit"

module TestHelper
  def fixture_path(filename)
    File.join(File.dirname(__FILE__), "fixtures", filename)
  end

  def load_fixture(filename)
    File.read(fixture_path(filename))
  end
end
