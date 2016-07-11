# Shrine::Storage::Url

Provides a fake storage which allows you to create a Shrine attachment defined
only by a custom URL.

## Installation

```ruby
gem "shrine-url"
```

## Usage

The representation of the uploaded file assumes that the ID will be a custom
URL:

```rb
{
  id: "http://example.com/image.jpg",
  storage: "url",
  metadata: {}
}
```

This is used in [shrine-transloadit] for direct uploads, where a temporary URL
of the uploaded file is returned, and we want to use that URL for further
processing, eventually replacing the attachment with permanent files.

## Contributing

```sh
$ rake test
```

## License

[MIT](/LICENSE.txt)

[shrine-transloadit]: https://github.com/janko-m/shrine-transloadit
