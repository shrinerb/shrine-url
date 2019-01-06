require "shrine"
require "http"

class Shrine
  module Storage
    class Url
      attr_reader :downloader

      def initialize(downloader: :http)
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

      def download(id, **options)
        @downloader.download(id, **options)
      end

      def open(id, **options)
        @downloader.open(id, **options)
      end

      def exists?(id)
        response = request(:head, id)
        response.status.success?
      end

      def url(id, **options)
        id
      end

      def delete(id)
        request(:delete, id)
      end

      private

      def request(verb, url, follow: {}, **options)
        options[:follow] = { max_hops: 2 }.merge(follow)

        HTTP.request(verb, url, options)
      end
    end
  end
end
