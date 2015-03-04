require "thor"
require "fileutils"
require "open3"
require "make_gallery/command"

module MakeGallery
  class Exception < RuntimeError; end
  
  class Thor < Thor

    include Thor::Actions

    class_option(:force,   type: :boolean, aliases: %w[-F], default: false,
      desc: "overwrite if directory or files exist")
    class_option(:verbose, type: :boolean, aliases: %w[-V], default: false,
      desc: "be chatty")
    class_option(:debug,   type: :boolean, aliases: %w[-D], default: false,
      desc: "be even *more* chatty")
    class_option(:dry_run, type: :boolean, aliases: %w[-n], default: false,
      desc: "Dry run, just show would happen, but do not do it")
    class_option(:mogrify_path, type: :string,
      desc: "path to mogrify command if make_gallery cannot find it")


    desc "thumbs", "Make small, square thumbnails of images in the source directory, saving them in the target directory."
    method_option(:source,  type: :string,  aliases: %w[-s], default: ".",
      desc: "source directory for images",
      banner: "DIR")
    method_option(:target,  type: :string,  aliases: %w[-t], default: "./thumbs/",
      desc: "destination directory for thumbnails",
      banner: "DIR")
    method_option(:size,    type: :numeric, aliases: %w[-w], default: 200,
      desc: "height and width in pixels")
    method_option(:format,  type: :string,  aliases: %w[-f], default: "gif",
      desc: "format of thumbnail")
    method_option(:quality, type: :numeric, aliases: %w[-q], default: 60,
      desc: "quality of image")
    def thumbs
      MakeGallery::Command.new(:thumbs, options).process_images
    rescue MakeGallery::Exception => e
      return e.to_s
    end

    desc "web", "Make web-sized images of the images in the source directory, saving them in the target directory. The new images retain the same aspect ratio as the source images."
    method_option(:source,  type: :string,  aliases: %w[-s], default: ".",
      desc: "source directory for images",
      banner: "DIR")
    method_option(:target,  type: :string,  aliases: %w[-t], default: "./web/",
      desc: "destination directory for thumbnails",
      banner: "DIR")
    method_option(:size,    type: :numeric, aliases: %w[-w], default: 1024,
      desc: "horizontal width in pixels")
    method_option(:format,  type: :string,  aliases: %w[-f], default: "jpg",
      desc: "format of thumbnail")
    method_option(:quality, type: :numeric, aliases: %w[-q], default: 60,
      desc: "quality of image")
    def web
      MakeGallery::Command.new(:web, options).process_images
    rescue MakeGallery::Exception => e
      return e.to_s
    end
    
    private

  end
end
