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
      stub_request(:get, "http://example.com").to_return(body: "file")
      tempfile = @storage.download("http://example.com")
      assert_instance_of Tempfile, tempfile
      assert_equal "file", tempfile.read
    end
  end

  describe "#open" do
    it "opens the remote file" do
      stub_request(:get, "http://example.com").to_return(body: "file")
      io = @storage.open("http://example.com")
      assert_instance_of Down::ChunkedIO, io
      assert_equal "file", io.read
    end
  end

  describe "#exists?" do
    it "checks whether the remote file exists" do
      stub_request(:head, "http://example.com").to_return(status: 200)
      assert_equal true, @storage.exists?("http://example.com")

      stub_request(:head, "http://example.com").to_return(status: 404)
      assert_equal false, @storage.exists?("http://example.com")
    end
  end

  describe "#url" do
    it "returns the given URL" do
      assert_equal "http://example.com", @storage.url("http://example.com")
    end
  end

  describe "#delete" do
    it "issues a delete request" do
      stub_request(:delete, "http://example.com")
      @storage.delete("http://example.com")
      assert_requested(:delete, "http://example.com")
    end
  end

  describe "#clear!" do
    it "is a noop" do
      @storage.clear!
    end
  end
end
