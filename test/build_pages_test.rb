require "fileutils"
require "minitest/autorun"
require "tmpdir"

load File.expand_path("../build-pages.sh", __dir__)

class BuildPagesTest < Minitest::Test
  def test_extract_proposal_reads_metadata_from_asciidoc
    Dir.mktmpdir do |dir|
      proposal_dir = File.join(dir, "EVRF-123")
      FileUtils.mkdir_p(proposal_dir)
      source_path = File.join(proposal_dir, "sample.asciidoc")

      File.write(source_path, <<~ASCIIDOC)
        = Example Proposal

        Date: 2026-06-18

        Author: Ada Lovelace

        Status: Draft

        Extension Number: EVRF-123

        == Motivation
      ASCIIDOC

      proposal = extract_proposal(proposal_dir)

      assert_equal "EVRF-123", proposal.id
      assert_equal "Example Proposal", proposal.title
      assert_equal "2026-06-18", proposal.date
      assert_equal "Ada Lovelace", proposal.author
      assert_equal "Draft", proposal.status
      assert_equal "EVRF-123", proposal.extension_number
      assert_equal source_path, proposal.source_path
      assert_equal "sample.html", proposal.html_filename
    end
  end

  def test_write_index_renders_links_from_proposal_data
    Dir.mktmpdir do |dir|
      proposals = [
        Proposal.new(
          id: "EVRF-001",
          title: "Loitering <fees>",
          date: "2026-03-05",
          author: "Reinier Lamers",
          status: "Proposal",
          extension_number: "EVRF-001",
          source_path: "proposals/EVRF-001/proposal.asciidoc",
          html_filename: "proposal.html"
        )
      ]

      write_index(proposals, dir)

      index = File.read(File.join(dir, "index.html"))
      assert_includes index, "<title>OCPI Feature Proposals</title>"
      assert_includes index, '<a href="EVRF-001/proposal.html">Loitering &lt;fees&gt;</a>'
      assert_includes index, "Status: Proposal"
      assert_includes index, "Extension Number: EVRF-001"
      assert_includes index, "Date: 2026-03-05"
      assert_includes index, "Author: Reinier Lamers"
    end
  end
end
