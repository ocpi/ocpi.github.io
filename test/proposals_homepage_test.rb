require "minitest/autorun"
require "open3"
require "fileutils"

class ProposalsHomepageTest < Minitest::Test
  def setup
    @root = File.expand_path("..", __dir__)
    @site = File.join(@root, "_site")
  end

  def test_homepage_lists_proposals_from_data_file
    FileUtils.rm_rf(@site)

    stdout, stderr, status = Open3.capture3(
      "bundle", "exec", "jekyll", "build",
      chdir: @root
    )
    assert status.success?, "jekyll build failed:\n#{stdout}\n#{stderr}"

    index = File.read(File.join(@site, "index.html"))

    assert_includes index, "OCPI Feature Proposals"
    assert_includes index, "Processes for Feature Development for OCPI"
    assert_includes index, "extension-of-ocpi.pdf"
    assert_includes index, "0000"
    assert_includes index, "0010"
    assert_includes index, "Greg Fitzpatrick"
    assert_includes index, "Author:"
    assert_includes index, "Status:"
    assert_includes index, "Date:"

    # filename "-" must not render a Filename line for proposal 0001
    proposal_0001 = index[/<li class="proposal-row">\s*<div class="proposal-number">0001<\/div>.*?<\/li>/m]
    refute_nil proposal_0001, "expected proposal 0001 in homepage HTML"
    refute_includes proposal_0001, "Filename:"

    # proposals without date show an em dash
    assert_includes index, "Date: —"
  end
end
