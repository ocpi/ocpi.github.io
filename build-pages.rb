#!/usr/bin/env ruby

require "cgi"
require "fileutils"

Proposal = Struct.new(
  :id,
  :title,
  :date,
  :author,
  :status,
  :extension_number,
  :source_path,
  :html_filename,
  keyword_init: true
)

def extract_proposal(proposal_dir)
  source_path = Dir.glob(File.join(proposal_dir, "*.asciidoc")).sort.first
  raise "No AsciiDoc proposal found in #{proposal_dir}" unless source_path

  title = nil
  metadata = {}

  File.readlines(source_path, chomp: true).each do |line|
    title ||= line.delete_prefix("= ").strip if line.start_with?("= ")
    break if line.start_with?("== ")

    next unless line.match?(/\A[^:]+:\s+.+\z/)

    key, value = line.split(":", 2)
    metadata[key.strip] = value.strip
  end

  raise "No level-one title found in #{source_path}" unless title

  Proposal.new(
    id: metadata["Extension Number"] || File.basename(proposal_dir),
    title: title,
    date: metadata["Date"],
    author: metadata["Author"],
    status: metadata["Status"],
    extension_number: metadata["Extension Number"],
    source_path: source_path,
    html_filename: "#{File.basename(source_path, ".asciidoc")}.html"
  )
end

def write_index(proposals, output_dir)
  FileUtils.mkdir_p(output_dir)

  File.write(File.join(output_dir, "index.html"), <<~HTML)
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>OCPI Feature Proposals</title>
      </head>
      <body>
        <main>
          <h1>OCPI Feature Proposals</h1>
          <ul>
    #{proposals.map { |proposal| proposal_index_entry(proposal) }.join("\n")}
          </ul>
        </main>
      </body>
    </html>
  HTML
end

def proposal_index_entry(proposal)
  details = [
    ["Status", proposal.status],
    ["Extension Number", proposal.extension_number],
    ["Date", proposal.date],
    ["Author", proposal.author]
  ].map do |label, value|
    next if value.nil? || value.empty?

    "#{escape_html(label)}: #{escape_html(value)}"
  end.compact

  href = "#{escape_html(proposal.id)}/#{escape_html(proposal.html_filename)}"

  <<~HTML.chomp
            <li>
              <a href="#{href}">#{escape_html(proposal.title)}</a>
              <div>#{details.join(" | ")}</div>
            </li>
  HTML
end

def escape_html(value)
  CGI.escapeHTML(value.to_s)
end

def render_proposal(proposal, output_dir)
  proposal_output_dir = File.join(output_dir, proposal.id)
  FileUtils.mkdir_p(proposal_output_dir)

  system("bundle", "exec", "asciidoctor", proposal.source_path, "-D", proposal_output_dir, exception: true)
end

def build_site(proposals_dir = "proposals", output_dir = "pages-out")
  FileUtils.rm_rf(output_dir)
  FileUtils.mkdir_p(output_dir)

  proposals = Dir.glob(File.join(proposals_dir, "*"))
                 .select { |path| File.directory?(path) }
                 .sort
                 .map { |proposal_dir| extract_proposal(proposal_dir) }

  proposals.each { |proposal| render_proposal(proposal, output_dir) }
  write_index(proposals, output_dir)
end

build_site if __FILE__ == $PROGRAM_NAME
