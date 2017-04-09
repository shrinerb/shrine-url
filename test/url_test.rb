require "test_helper"
require "ostruct"
require "webmock/minitest"

describe Shrine::Storage::Url do
  before do
    @storage = Shrine::Storage::Url.new
  end

  describe "#upload" do
    it "replaces the id with an URL" do
      io = OpenStruct.new(url: "http://example.com")
      @storage.upload(io, id = "foo")
      assert_equal "http://example.com", id
    end
  end

  describe "#download" do
    it "downloads the remote file into a Tempfile" do
      stub_request(:get, "http://example.com?foo=bar").to_return(body: "file")
      tempfile = @storage.download("http://example.com?foo=bar")
      assert_instance_of Tempfile, tempfile
      assert_equal "file", tempfile.read
    end

    it "works with wget" do
      @storage = Shrine::Storage::Url.new(downloader: :wget)
      tempfile = @storage.download("http://example.com?foo=bar")
      assert_instance_of Tempfile, tempfile
      assert_equal 0, tempfile.pos
    end

    it "raises an error when wget download failed" do
      @storage = Shrine::Storage::Url.new(downloader: :wget)
      assert_raises(Shrine::Error) { @storage.download("http://example.com/foobar") }
    end
  end

  describe "#open" do
    it "opens the remote file" do
      stub_request(:get, "http://example.com?foo=bar").to_return(body: "file")
      io = @storage.open("http://example.com?foo=bar")
      assert_instance_of Down::ChunkedIO, io
      assert_equal "file", io.read
    end

    it "works with wget" do
      @storage = Shrine::Storage::Url.new(downloader: :wget)
      tempfile = @storage.open("http://example.com?foo=bar")
      assert_instance_of Tempfile, tempfile
      assert_equal 0, tempfile.pos

      path = tempfile.path
      tempfile.close
      refute File.exist?(path)
    end
  end

  describe "#exists?" do
    it "checks whether the remote file exists" do
      stub_request(:head, "http://example.com?foo=bar").to_return(status: 200)
      assert_equal true, @storage.exists?("http://example.com?foo=bar")

      stub_request(:head, "http://example.com?foo=bar").to_return(status: 204)
      assert_equal true, @storage.exists?("http://example.com?foo=bar")

      stub_request(:head, "http://example.com?foo=bar").to_return(status: 404)
      assert_equal false, @storage.exists?("http://example.com?foo=bar")
    end
  end

  describe "#url" do
    it "returns the given URL" do
      assert_equal "http://example.com", @storage.url("http://example.com")
    end
  end

  describe "#delete" do
    it "issues a delete request" do
      stub_request(:delete, "http://example.com?foo=bar")
      @storage.delete("http://example.com?foo=bar")
      assert_requested(:delete, "http://example.com?foo=bar")
    end
  end
end
