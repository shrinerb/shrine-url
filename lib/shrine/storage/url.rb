require "shrine"
require "net/https"
require "uri"

class Shrine
  module Storage
    class Url
      attr_reader :downloader

      def initialize(downloader: :net_http)
        if downloader.is_a?(Symbol)
          require "down/#{downloader}"
          const_name = downloader.to_s.split("_").map(&:capitalize).join
          @downloader = Down.const_get(const_name)
        else
          @downloader = downloader
        end
      end

      def upload(io, id, **)
        id.replace(io.url)
      end

      def download(id)
        @downloader.download(id)
      end

      def open(id)
        @downloader.open(id)
      end

      def exists?(id)
        response = request(:head, id)
        (200..399).cover?(response.code.to_i)
      end

      def url(id, **options)
        id
      end

      def delete(id)
        request(:delete, id)
      end

      private

      def request(verb, url, follows_remaining: 2)
        uri     = URI.parse(url)
        use_ssl = uri.is_a?(URI::HTTPS)

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl) do |http|
          request = Net::HTTP.const_get(verb.capitalize).new(uri.request_uri)
          yield request if block_given?
          http.request(request)
        end

        if response.is_a?(Net::HTTPRedirection) && follows_remaining > 0
          location = URI.parse(response["Location"])
          location = uri + location if location.relative?

          response = request(verb, location.to_s, follows_remaining: follows_remaining - 1)
        end

        response
      end
    end
  end
end
