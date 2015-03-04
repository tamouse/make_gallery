# MakeGallery

I like to show several pictures in some of my blog posts as a gallery
of sorts, with square thumbnails that link to the web-sized images.

I found a nifty one-line bash command that uses ImageMagick to
automate part of this process:

``` bash
#!/bin/bash

set -xv

: ${THUMBSIZE:=200}
: ${THUMBNAIL:=${THUMBSIZE}x${THUMBSIZE}}

mkdir -p thumbs
mogrify -format gif -path thumbs -thumbnail ${THUMBNAIL}^ -gravity center -extent ${THUMBNAIL} *.jpg
```

which creates small-ish .gif thumbnails in a `thumbs/` subdirectory.

In addition, I want to create web-scale .jpgs in a `web/` subdirectory
(mid-quality 1024 pixels wide).

## Installation

Or install it yourself as:

    $ gem install make_gallery

## Usage

    $ make_gallery (thumbs | web) [--source DIR] [--target DIR] [--size SIZE] [--format FORMAT] [--force] [--verbose] [--debug]

* **thumbs:** create (square) thumbnails
* **web:** create web-sized images (maintains aspect ratio)
* *source:* the directory to take starting images from (default is current directory)
* *target:* the directory to write to (default is `./thumbs/` or `./web/`)
* *size:* horizontal size for web images, side size for thumbs
* *format:* JPG for web images, GIF for thumbs
* *force:* overwrite (default is abort if directory already exists)
* *verbose:* be chatty
* *debug:* be SUPER chatty about a lot of things

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `bin/console` for an interactive prompt that
will allow you to experiment. Run `bundle exec make_gallery` to use
the code located in this directory, ignoring other installed copies of
this gem.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release` to create a git
tag for the version, push git commits and tags, and push the `.gem`
file to [rubygems.org](https://rubygems.org).

## Contributing

Review the [Guidelines](CONTRIBUTING.md) for any information on how to contribute to this tool.

Make sure to also read the [Code of Conduct](CODE_OF_CONDUCT.md) if you wish to contribute.

1. Fork it ( https://github.com/tamouse/make_gallery/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

*"fork in, branch it, commit it, push it." -- daft punking our way through open source!*

