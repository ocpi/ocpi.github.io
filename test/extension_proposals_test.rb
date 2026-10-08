require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../_plugins/extension_proposals"

class ExtensionProposalsTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def write(path, content)
    full = File.join(@dir, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  def test_reads_makefile_metadata
    write("EVRF-004/Makefile", <<~MAKE)
      NAME     \t\t:= nap-extension
      VERSION  \t\t:= 1.0
      TITLE    \t\t:= NAP Data Extension
      SUBTITLE \t\t:= OCPI Data Exchange for National Access Points under AFIR
      DATE     \t\t:= 2026-09-24
      EVRF-NUMBER \t:= EVRF-004
      AUTHOR   \t\t:= Ben van Gameren, Tim Ververs
      STATUS   \t\t:= Under Review

      include ../common/extension.mk
    MAKE

    assert_equal [{
      "number" => "004",
      "title" => "NAP Data Extension",
      "date" => "2026-09-24",
      "author" => "Ben van Gameren, Tim Ververs",
      "status" => "Under Review",
      "filename" => "nap-extension.asciidoc",
      "pdf_source" => File.join(@dir, "out", "nap-extension-1.0.pdf"),
    }], ExtensionProposals.read(@dir)
  end

  def test_leaves_out_unset_metadata
    write("EVRF-008/Makefile", "NAME := connector-status\nVERSION := DRAFT\nSUBTITLE :=\n\ninclude ../common/extension.mk\n")

    assert_equal [{
      "number" => "008",
      "filename" => "connector-status.asciidoc",
      "pdf_source" => File.join(@dir, "out", "connector-status-DRAFT.pdf"),
    }], ExtensionProposals.read(@dir)
  end

  def test_skips_folders_without_makefile
    write("EVRF-001/Discount Offer.pdf", "")
    write("common/extension.mk", "NAME ?=\n")

    assert_empty ExtensionProposals.read(@dir)
  end

  def test_makefile_metadata_overrides_fallback_with_same_number
    extension = [
      { "number" => "010", "title" => "From Makefile" },
      { "number" => "011", "title" => "Makefile only" },
    ]
    fallback = [
      { "number" => "010", "title" => "From YAML", "status" => "Draft" },
      { "number" => "001", "title" => "PDF only" },
    ]

    assert_equal [
      { "number" => "010", "title" => "From Makefile", "status" => "Draft" },
      { "number" => "001", "title" => "PDF only" },
      { "number" => "011", "title" => "Makefile only" },
    ], ExtensionProposals.merge(extension, fallback)
  end
end
