require "asciidoctor"

# Proposal metadata from a checkout of the ocpi/extensions repository.
#
# A proposal's master AsciiDoc document lives in its EVRF-NNN folder and
# carries the metadata as header attributes:
#
#     = Loitering fees with grace periods
#     :evrf-number: 010
#     :author: Reinier Lamers
#     :revdate: 2026-03-05
#     :evrf-status: Draft
#
# Documents without :evrf-number: (included chapters) are skipped. Documents
# using the formal layout have no "= Title" line; their :ocpi_document: is the
# title instead.
module ExtensionProposals
  def self.read(extensions_dir)
    Dir.glob(File.join(extensions_dir, "EVRF-*", "*.asciidoc")).sort.filter_map do |path|
      # :secure leaves include directives unresolved, which the header does not need.
      doc = Asciidoctor.load_file(path, parse_header_only: true, safe: :secure)
      number = doc.attr("evrf-number")
      next unless number

      {
        "number" => number,
        "title" => doc.doctitle(sanitize: true) || doc.attr("ocpi_document"),
        "author" => doc.attr("author"),
        "status" => doc.attr("evrf-status"),
        "date" => doc.attr("revdate"),
        "filename" => File.basename(path),
        # Where the extensions build (make) puts the PDF of this document.
        "pdf_source" => File.join(extensions_dir, "out", "#{File.basename(path, '.asciidoc')}.pdf"),
      }
    end
  end

  # Proposals read from AsciiDoc replace fallback entries with the same number.
  def self.merge(asciidoc_proposals, fallback_proposals)
    numbers = asciidoc_proposals.map { |p| p["number"] }
    fallback_proposals.reject { |p| numbers.include?(p["number"].to_s) } + asciidoc_proposals
  end
end
