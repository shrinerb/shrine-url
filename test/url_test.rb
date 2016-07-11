require "test_helper"
require "ostruct"

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
      tempfile = @storage.download("http://example.com")
      assert_instance_of Tempfile, tempfile
    end
  end

  describe "#open" do
    it "opens the remote file" do
      tempfile = @storage.open("http://example.com")
      assert_instance_of Down::ChunkedIO, tempfile
    end
  end

  describe "#exists?" do
    it "checks whether the remote file exists" do
      assert_equal true, @storage.exists?("http://example.com")
    end
  end

  describe "#url" do
    it "returns the given URL" do
      assert_equal "http://example.com", @storage.url("http://example.com")
    end
  end

  describe "#delete" do
    it "is a noop" do
      @storage.delete("http://example.com")
    end
  end

  describe "#clear!" do
    it "is a noop" do
      @storage.clear!
    end
  end
end
