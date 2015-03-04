require "thor"
require "fileutils"
require "open3"
require "make_gallery/version"

class MakeGallery < Thor

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
    process_images(:thumbs, options.dup)
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
    process_images(:web, options.dup)
  end
  
  private

  def process_images(action, options)
    options[:dry_run] = true if options[:debug]
    options[:debug] = options[:debug] || options[:dry_run]
    options[:verbose] = options[:verbose] || options[:debug]

    $debug = options[:debug]

    debug "Options\n#{options.inspect}" if options[:debug]
    
    fatal "#{options[:target]} exist. Use --force to overwrite" if File.exists?(options[:target]) && ! options[:force]
    say("Creating #{action} images in #{options[:source]} to #{options[:target]}\n", :green) if options[:verbose]

    mogrify = locate_mogrify(options[:mogrify_path])
    debug "mogrify command: #{mogrify.inspect}" if options[:debug]
    cmd_opts = set_mogrify_options(action, options)
    debug "command opts: #{cmd_opts.inspect}" if options[:debug]
    debug "source: #{options[:source]}" if options[:debug]
    debug "source files: #{Dir[File.join(options[:source],'*')]}" if options [:debug]
    source_images = Dir[File.join(options[:source],'*')].grep(/jpe?g|png|gif/i)
    debug "source images: #{source_images.inspect}" if options[:debug]

    FileUtils.mkdir_p(options[:target]) unless options[:dry_run]
    cmd = [mogrify, cmd_opts, source_images].join(" ")
    if options[:verbose]
      say("\nRunning:\n", :green)
      say(cmd, :yellow)
    end

    # skip the rest if it's a dry run
    unless options[:dry_run]
      o, e, s = Open3.capture3(cmd)
      fatal e unless s.success?
      if options[:verbose]
        say("\nOutput:\n", :green)
        say(o, :cyan)
        say(e, :cyan)
        say("\n")
      end
    end

    say("\nCompleted\n", :green) if options[:verbose]
  end

  def locate_mogrify(mogrify_path)
    if mogrify_path
      fatal "Path given for mogrify command is wrong" unless File.exist?(mogrify_path)
    else
      mogrify_path = %x(which mogrify).chomp
      fatal "Cannot find mogrify command. Use --mogrify_path option instead" unless File.exist?(mogrify_path)
    end
    mogrify_path
  end

  def set_mogrify_options(action, options)
    cmd_opts = []
    cmd_opts << "-verbose" if options[:verbose]
    cmd_opts << "-format #{options[:format]}"
    cmd_opts << "-path #{options[:target]}"
    cmd_opts << "-quality #{options[:quality]}"

    if action == :thumbs
      geometry = [options[:size], options[:size]].join("x")
      cmd_opts << "-thumbnail #{geometry}^"
      cmd_opts << "-gravity center"
      cmd_opts << "-extent #{geometry}"
    elsif action == :web
      cmd_opts << "-resize #{options[:size]}"
    end

    debug "Command Line Options\n#{cmd_opts.inspect}" if options[:debug]

    cmd_opts.join(" ")
  end

  def fatal(m)
    say(m, :red)
    exit(-1)
  end

  def debug(m)
    say(m, [:red, :on_white]) if $debug
  end
end
