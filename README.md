# Shrine::Storage::Url

Provides a "storage" for [Shrine] for attaching uploaded files defined by a
custom URL.

## Installation

```rb
gem "shrine-url", "~> 2.0"
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
```

No HTTP requests are made when file is assigned (but you can load the
`restore_cached_data` Shrine plugin if you want metadata to be extracted on
assignment). When this "cached file" is about to be uploaded to a permanent
storage, `shrine-url` will download the file from the given URL using [Down].

```rb
uploaded_file.download      # Sends a GET request and streams body to Tempfile
uploaded_file.open { |io| } # Sends a GET request and yields `Down::ChunkedIO` ready for reading
uploaded_file.exists?       # Sends a HEAD request and returns true if response status is 2xx
uploaded_file.delete        # Sends a DELETE request if :delete is set to true
```

By default the `Down::Http` backend will be used for downloading, which is
implemented using [HTTP.rb]. You can change the Down backend via the
`:downloader` option:

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

## Deleting

Calling `Shrine::UploadedFile#delete` will call `Shrine::Storage::Url#delete`,
which for safety doesn't do anything by default. If you want it to make a
`DELETE` request to the URL, you can set `:delete` to `true` on initialization:

```rb
Shrine::Storage::Url.new(delete: true)
```

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

[Shrine]: https://github.com/shrinerb/shrine
[shrine-transloadit]: https://github.com/shrinerb/shrine-transloadit
[shrine-tus-demo]: https://github.com/shrinerb/shrine-tus-demo
[shrine-cloudinary]: https://github.com/shrinerb/shrine-cloudinary
[shrine-uploadcare]: https://github.com/shrinerb/shrine-uploadcare
[Down]: https://github.com/janko-m/down
[HTTP.rb]: https://github.com/httprb/http
[kennethreitz/httpbin]: https://github.com/kennethreitz/httpbin
