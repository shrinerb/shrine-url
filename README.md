# Shrine::Storage::Url

Provides a "storage" which allows you to save uploaded files defined by a
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

```rb
photo = Photo.new

attachment_data = {
  id: "http://example.com/image.jpg",
  storage: "cache",
  metadata: {...}
}

photo.image = attachment_data.to_json
photo.image #=> #<Shrine::UploadedFile>

photo.image.url           #=> "http://example.com/image.jpg"
photo.image.download      # Sends a GET request and streams body to Tempfile
photo.image.open { |io| } # Sends a GET request and yields `Down::ChunkedIO` ready for reading
photo.image.exists?       # Sends a HEAD request and returns true if it's 2xx
photo.image.delete        # Sends a DELETE request
```

The custom URL can be saved to `id`, and `#url` will simply read that field.
When this `Shrine::UploadedFile` is uploaded to another storage (e.g. permanent
storage), if the storage doesn't support upload from URL the file will simply
be downloaded from the custom URL, just like for any other storage.

## Use cases

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

[shrine-transloadit]: https://github.com/janko-m/shrine-transloadit
[shrine-tus-demo]: https://github.com/janko-m/shrine-tus-demo
