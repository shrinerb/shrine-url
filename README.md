# Shrine::Storage::Url

Provides a "storage" for [Shrine] for attaching uploaded files defined by a
custom URL.

## Installation

```ruby
gem "shrine-url"
```

## Usage

```rb
require "shrine/storage/url"

Shrine.storages[:cache] = Shrine::Storage::Url.new
```

The custom URL should be assigned to the `id` field in the Shrine uploaded file
JSON representation:

```rb
{
  "id": "http://example.com/image.jpg",
  "storage": "cache",
  "metadata": {
    # ...
  }
}
```

Now you can assign this data as the cached attachment:

```rb
photo = Photo.new(image: data)
photo.image #=> #<Shrine::UploadedFile>

photo.image.url           #=> "http://example.com/image.jpg"
photo.image.download      # Sends a GET request and streams body to Tempfile
photo.image.open { |io| } # Sends a GET request and yields `Down::ChunkedIO` ready for reading
photo.image.exists?       # Sends a HEAD request and returns true if it's 2xx
photo.image.delete        # Sends a DELETE request
```

No HTTP requests are made at this point. When this "cached file" is about to be
uploaded to a permanent storage, `shrine-url` will download the file from the
given URL using [Down]. By default the `Down::NetHttp` backend will be used for
downloading, but you can tell `shrine-url` to use another Down backend:

```rb
Shrine::Storage::Url.new(downloader: :wget)
# or
require "down/http"
Shrine::Storage::Url.new(downloader: Down::Http)
# or
require "down/net_http"
Shrine::Storage::Url.new(downloader: Down::NetHttp.new("User-Agent" => "MyApp/1.0.0"))
```

Note that if you're using permanent storage that supports uploading from a
remote URL (like [shrine-cloudinary] or [shrine-uploadcare]), downloading will
be completely skipped as the permanent storage will use only the URL for
uploading the file.

## Advantages and Use Cases

The main advantage of using `shrine-url` over the `remote_url` Shrine plugin is
that you can put downloading from the URL into a background job by loading the
`backgrounding` Shrine plugin. Another advantage is that you can assign
multiple remote URLs as multiple versions.

This storage can be used with [shrine-transloadit] for direct uploads, where a
temporary URL of the uploaded file is returned, and we want to use that URL for
further background processing, eventually replacing the attachment with
processed files.

It is also used in [shrine-tus-demo], where the files are uploaded to a
separate endpoint, and then its file URL is attached to a database record and
promoted to permanent storage.

## Contributing

```sh
$ rake test
```

The test suite pulls and runs [kennethreitz/httpbin] as a Docker container, so
you'll need to have Docker installed and running.

## License

[MIT](/LICENSE.txt)

[Shrine]: https://github.com/janko-m/shrine
[shrine-transloadit]: https://github.com/janko-m/shrine-transloadit
[shrine-tus-demo]: https://github.com/janko-m/shrine-tus-demo
[shrine-cloudinary]: https://github.com/janko-m/shrine-cloudinary
[shrine-uploadcare]: https://github.com/janko-m/shrine-uploadcare
[Down]: https://github.com/janko-m/down
[kennethreitz/httpbin]: https://github.com/kennethreitz/httpbin
