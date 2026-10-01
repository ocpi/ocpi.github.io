require_relative "extension_proposals"

module ExtensionProposals
  # A built PDF from the extensions checkout, published at /<dir>/<name>.
  class PdfFile < Jekyll::StaticFile
    def initialize(site, source, dir)
      super(site, site.source, dir, File.basename(source))
      @source = source
    end

    def path
      @source
    end
  end

  # Merges the AsciiDoc proposals into site.data.proposals.proposals, with
  # _data/proposals.yaml as the fallback for proposals not written in AsciiDoc,
  # and publishes their PDFs. The checkout is found via the EXTENSIONS_DIR
  # environment variable or the extensions_dir setting in _config.yml.
  class Generator < Jekyll::Generator
    priority :high

    def generate(site)
      dir = ENV["EXTENSIONS_DIR"] || site.config["extensions_dir"]
      dir = File.expand_path(dir, site.source) if dir
      unless dir && Dir.exist?(dir)
        Jekyll.logger.warn "Extensions:", "no ocpi/extensions checkout at #{dir.inspect}, listing _data/proposals.yaml only"
        return
      end

      proposals = ExtensionProposals.read(dir)
      proposals.each { |proposal| publish_pdf(site, proposal) }

      data = site.data["proposals"] ||= {}
      data["proposals"] = ExtensionProposals.merge(proposals, data["proposals"] || [])
    end

    private

    def publish_pdf(site, proposal)
      source = proposal.delete("pdf_source")
      unless File.exist?(source)
        Jekyll.logger.warn "Extensions:", "no PDF for EVRF-#{proposal['number']} at #{source}"
        return
      end

      pdf = PdfFile.new(site, source, "EVRF-#{proposal['number']}")
      site.static_files << pdf
      proposal["pdf_url"] = pdf.url
    end
  end
end
