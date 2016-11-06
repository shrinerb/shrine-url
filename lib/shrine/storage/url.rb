require "shrine"
require "down"
require "net/http"

class Shrine
  module Storage
    class Url
      def upload(io, id, **)
        id.replace(io.url)
      end

      def download(id)
        Down.download(id)
      end

      def open(id)
        Down.open(id)
      end

      def exists?(id)
        response = nil
        uri = URI(id)
        Net::HTTP.start(uri.host, uri.port) do |http|
          response = http.head(uri.request_uri)
        end
        response.code.to_i == 200
      end

      def url(id, **options)
        id
      end

      def delete(id)
        # noop
      end

      def clear!
        # noop
      end
    end
  end
end
