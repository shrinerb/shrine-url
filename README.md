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

photo.image.url      #=> "http://example.com/image.jpg"
photo.image.download # Downloads from this URL
photo.image.exists?  # Checks whether a request to this URL returns 200
photo.image.delete   # No-op
```

This cached file will be promoted to permanent storage like any other cached
file.

## Use cases

This storage can be used with [shrine-transloadit] for direct uploads, where a
temporary URL of the uploaded file is returned, and we want to use that URL for
further background processing, eventually replacing the attachment with
processed files.

## Contributing

```sh
$ rake test
```

## License

[MIT](/LICENSE.txt)

[shrine-transloadit]: https://github.com/janko-m/shrine-transloadit
