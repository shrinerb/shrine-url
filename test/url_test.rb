require "test_helper"
require "ostruct"
require "cgi"

describe Shrine::Storage::Url do
  before do
    @storage = url
  end

  def url(**options)
    Shrine::Storage::Url.new(**options)
  end

  describe "#initialize" do
    it "uses :http downloader by default" do
      assert_equal Down::Http, url.downloader
    end

    it "accepts any down backend" do
      storage = url(downloader: :net_http)
      assert_equal Down::NetHttp, storage.downloader

      storage = url(downloader: :http)
      assert_equal Down::Http, storage.downloader

      storage = url(downloader: :wget)
      assert_equal Down::Wget, storage.downloader
    end
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
      tempfile = @storage.download("#{$httpbin}/bytes/100")
      assert_instance_of Tempfile, tempfile
      assert_equal 100, tempfile.size
    end

    it "accepts additional down options" do
      @storage.download("#{$httpbin}/post", method: :post)
    end
  end

  describe "#open" do
    it "opens the remote file" do
      io = @storage.open("#{$httpbin}/bytes/100")
      assert_instance_of Down::ChunkedIO, io
      assert_equal 100, io.size
    end

    it "accepts additional down options" do
      @storage.open("#{$httpbin}/post", method: :post)
    end
  end

  describe "#url" do
    it "returns the given URL" do
      assert_equal "http://example.com", @storage.url("http://example.com")
    end
  end

  describe "#exists?" do
    it "checks whether the remote file exists" do
      assert_equal true,  @storage.exists?("#{$httpbin}/status/200")
      assert_equal true,  @storage.exists?("#{$httpbin}/status/204")
      assert_equal false, @storage.exists?("#{$httpbin}/status/404")
    end

    it "follows redirects" do
      assert_equal true,  @storage.exists?("#{$httpbin}/redirect/1")
      assert_equal true,  @storage.exists?("#{$httpbin}/redirect/2")

      assert_equal true,  @storage.exists?("#{$httpbin}/relative-redirect/1")
      assert_equal true,  @storage.exists?("#{$httpbin}/absolute-redirect/1")

      assert_raises(HTTP::Redirector::TooManyRedirectsError) do
        @storage.exists?("#{$httpbin}/redirect/3")
      end

      assert_equal true,  @storage.exists?("#{$httpbin}/redirect-to?url=#{CGI.escape("#{$httpbin}/status/200")}")
      assert_equal false, @storage.exists?("#{$httpbin}/redirect-to?url=#{CGI.escape("#{$httpbin}/status/404")}")
    end
  end

  describe "#delete" do
    describe "by default" do
      it "is a no-op" do
        assert_nil @storage.delete("#{$httpbin}/delete")
      end
    end

    describe "with delete: true" do
      before do
        @storage = url(delete: true)
      end

      it "issues a delete request" do
        @storage.delete("#{$httpbin}/delete")
      end

      it "doesn't care what status is returned" do
        @storage.delete("#{$httpbin}/status/404")
      end
    end
  end
end
