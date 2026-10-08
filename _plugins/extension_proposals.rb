# Proposal metadata from a checkout of the ocpi/extensions repository.
#
# A proposal written in AsciiDoc has a Makefile in its EVRF-NNN folder that
# carries the metadata of its document:
#
#     NAME     := loitering-fees-with-grace-periods
#     VERSION  := PROPOSAL
#     TITLE    := Loitering fees with grace periods for OCPI 2.3.0
#     SUBTITLE :=
#     DATE     := 2026-03-05
#     AUTHOR   := Reinier Lamers
#     STATUS   := Proposal
#     include ../common/extension.mk
#
# The number comes from the folder name. TITLE and DATE are optional, so
# _data/proposals.yaml supplies whatever the Makefile leaves out.
module ExtensionProposals
  ASSIGNMENT = /\A([A-Za-z][\w-]*)\s*[:?]?=\s*(.*?)\s*\z/

  def self.read(extensions_dir)
    Dir.glob(File.join(extensions_dir, "EVRF-*", "Makefile")).sort.filter_map do |path|
      vars = makefile_variables(path)
      name = vars["NAME"]
      next unless name

      {
        "number" => File.basename(File.dirname(path)).delete_prefix("EVRF-"),
        "title" => vars["TITLE"],
        "date" => vars["DATE"],
        "author" => vars["AUTHOR"],
        "status" => vars["STATUS"],
        "filename" => "#{name}.asciidoc",
        # Where common/extension.mk (make pdf) puts the PDF of this document.
        "pdf_source" => File.join(extensions_dir, "out", "#{name}-#{vars['VERSION']}.pdf"),
      }.reject { |_, value| value.nil? || value.empty? }
    end
  end

  # The simple variable assignments (NAME := value) in a Makefile.
  def self.makefile_variables(path)
    File.readlines(path, chomp: true).each_with_object({}) do |line, vars|
      match = ASSIGNMENT.match(line)
      vars[match[1]] = match[2] if match
    end
  end

  # Fields read from ocpi/extensions override those of the fallback entry with
  # the same number.
  def self.merge(extension_proposals, fallback_proposals)
    by_number = extension_proposals.to_h { |p| [p["number"], p] }
    merged = fallback_proposals.map do |fallback|
      extension = by_number.delete(fallback["number"].to_s)
      extension ? fallback.merge(extension) : fallback
    end
    merged + by_number.values
  end
end
