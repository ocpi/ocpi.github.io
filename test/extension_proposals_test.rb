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

  def test_reads_header_attributes
    write("EVRF-010/loitering.asciidoc", <<~ADOC)
      = Loitering `fees`
      :evrf-number: 010
      :author: Hakan Ebabil, Matthew Penny
      :revdate: 2026-03-05
      :evrf-status: Draft

      Date: {revdate}
    ADOC

    assert_equal [{
      "number" => "010",
      "title" => "Loitering fees",
      "author" => "Hakan Ebabil, Matthew Penny",
      "status" => "Draft",
      "date" => "2026-03-05",
      "filename" => "loitering.asciidoc",
      "pdf_source" => File.join(@dir, "out", "loitering.pdf"),
    }], ExtensionProposals.read(@dir)
  end

  def test_formal_layout_uses_ocpi_document_as_title
    write("EVRF-003/accessibility.asciidoc", <<~ADOC)
      :ocpi_document: Accessibility Extension
      :document_date: 2026-09-01
      :evrf-number: 003
      :revdate: {document_date}

      include::../common/extension_layout.asciidoc[]
    ADOC

    proposal = ExtensionProposals.read(@dir).first
    assert_equal "Accessibility Extension", proposal["title"]
    assert_equal "2026-09-01", proposal["date"]
  end

  def test_skips_documents_without_number
    write("EVRF-003/domain.asciidoc", "== Domain\n")
    write("extension-document-template.asciidoc", "= Template\n:evrf-number: NNN\n")

    assert_empty ExtensionProposals.read(@dir)
  end

  def test_asciidoc_replaces_fallback_with_same_number
    asciidoc = [{ "number" => "010", "title" => "From AsciiDoc" }]
    fallback = [{ "number" => "010", "title" => "From YAML" }, { "number" => "001", "title" => "PDF only" }]

    assert_equal [{ "number" => "001", "title" => "PDF only" }, { "number" => "010", "title" => "From AsciiDoc" }],
                 ExtensionProposals.merge(asciidoc, fallback)
  end
end
