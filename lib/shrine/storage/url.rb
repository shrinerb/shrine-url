require "shrine"
require "net/http"

class Shrine
  module Storage
    class Url
      def initialize(downloader: :down)
        @downloader = Downloader.new(downloader)
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
        (200..299).cover?(response.code.to_i)
      end

      def url(id, **options)
        id
      end

      def delete(id)
        request(:delete, id)
      end

      private

      def request(method, url)
        response = nil
        uri = URI(url)

        Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP.const_get(method.to_s.capitalize).new(uri.request_uri)
          yield request if block_given?
          response = http.request(request)
        end

        response
      end

      class Downloader
        SUPPORTED_TOOLS = [:down, :wget]

        def initialize(tool)
          raise ArgumentError, "unsupported downloading tool: #{tool}" unless SUPPORTED_TOOLS.include?(tool)

          @tool = tool
        end

        def download(url)
          send(:"download_with_#{@tool}", url)
        end

        def open(url)
          send(:"open_with_#{@tool}", url)
        end

        private

        def download_with_down(url)
          require "down"
          Down.download(url)
        end

        def open_with_down(url)
          require "down"
          Down.open(url)
        end

        def download_with_wget(url)
          require "tempfile"
          require "open3"

          tempfile = Tempfile.new("shrine-url", binmode: true)
          cmd = %W[wget --no-verbose #{url} -O #{tempfile.path}]

          begin
            stdout, stderr, status = Open3.capture3(*cmd)

            if !status.success?
              tempfile.close!
              raise Error, "downloading from #{url} failed: #{stderr}"
            end
          rescue Errno::ENOENT
            raise Error, "wget is not installed"
          end

          tempfile.open # refresh file descriptor
          tempfile
        end

        def open_with_wget(url)
          tempfile = download_with_wget(url)
          tempfile.instance_eval { def close(unlink_now=true) super end } # delete tempfile when it's closed
          tempfile
        end
      end
    end
  end
end
