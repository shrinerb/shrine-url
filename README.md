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

No HTTP requests are made at this point. When the cached file is uploaded to
permanent storage, `shrine-url` will by default use [Down] to download the file
from the given URL, before uploading it to permanent storage.

Note that Down doesn't yet support resuming the download in case of network
failures, so if you're expecting large files to be attached, you might want to
tell `Shrine::Storage::Url` to use `wget` instead of Down.

```rb
Shrine::Storage::Url.new(downloader: :wget)
```

Just note that using `wget` won't work well with the `restore_cached_data`
Shrine plugin from the performance standpoint, because `wget` doesn't support
partial downloads, so the file would first be fully downloaded before
extracting metadata.

If you're using permanent storage that supports uploading from remote URL (like
[shrine-cloudinary] or [shrine-uploadcare]), downloading will be completely
skipped and the permanent storage will use only the custom URL for uploading
the file.

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

## License

[MIT](/LICENSE.txt)

[Shrine]: https://github.com/janko-m/shrine
[shrine-transloadit]: https://github.com/janko-m/shrine-transloadit
[shrine-tus-demo]: https://github.com/janko-m/shrine-tus-demo
[shrine-cloudinary]: https://github.com/janko-m/shrine-cloudinary
[shrine-uploadcare]: https://github.com/janko-m/shrine-uploadcare
[Down]: https://github.com/janko-m/down
