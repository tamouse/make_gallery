require 'fattr'
require 'highline'

module MakeGallery
  class Command 

    OUTLOG = HighLine.new($stdin, $stdout)
    ERRLOG = HighLine.new($stdin, $stderr)
    
    FATTRS = %w[action source target size format quality force verbose debug dry_run mogrify_path]

    fattrs *FATTRS

    def fattrs
      self.class.fattrs
    end


    def initialize(action, options)
      action(action)

      options.each do |k, v|
        public_send k, v
      end

      if debug
        fattrs.each do |attr|
          a = ERRLOG.color(attr, :cyan, :on_black)
          b = ERRLOG.color(public_send(attr).inspect, :white, :on_black)
          ERRLOG.say("DEBUG: #{a}: #{b}")
        end
      end

      fatal_say("#{target} exists. Use --force to overwrite") if File.exists?(target) && ! force
    end
    
    def to_h
      fattrs.inject({}) {|hash, attr| hash.update attr => public_send(attr) }
    end

    def process_images
      say("Creating #{action} images in #{source} to #{target}\n", :green)
      
      FileUtils.mkdir_p(target) unless dry_run

      cmd = build_command.join(" ")
      say("\nRunning: #{cmd}", :green)

      # skip the rest if it's a dry run
      unless dry_run
        o, e, s = Open3.capture3(cmd)
        fatal e unless s.success?
        say("\nOutput:\n", :green)
        say(o, :cyan)
        say(e, :cyan)
        say("\n")
      end

      say("\nCompleted\n", :green)
    end

    def build_command
      mogrify = locate_mogrify
      cmd_opts = set_mogrify_options
      source_images = select_source_images
      [mogrify, cmd_opts, source_images].flatten.tap do |t|
        debug_say("Command: #{t.inspect}")
      end
    end


    def locate_mogrify
      if mogrify_path
        fatal_say("Path given for mogrify command is wrong") unless File.exist?(mogrify_path)
        mogrify = mogrify_path
      else
        mogrify = %x(which mogrify).chomp
        fatal_say("Cannot find mogrify command. Use --mogrify_path option instead") unless File.exist?(mogrify)
      end
      debug_say("mogrify command: #{mogrify.inspect}")
      mogrify
    end

    def set_mogrify_options
      cmd_opts = []
      cmd_opts << "-verbose" if verbose
      cmd_opts << "-format #{format}"
      cmd_opts << "-path #{target}"
      cmd_opts << "-quality #{quality}"

      if action == :thumbs
        geometry = [size, size].join("x")
        cmd_opts << "-thumbnail #{geometry}^"
        cmd_opts << "-gravity center"
        cmd_opts << "-extent #{geometry}"
      elsif action == :web
        cmd_opts << "-resize #{size}"
      end

      debug_say "command opts: #{cmd_opts.inspect}"
      cmd_opts
    end

    def select_source_images
      debug_say "source: #{source}"
      debug_say "source files: #{Dir[File.join(source,'*')]}"
      source_images = Dir[File.join(source,'*')].grep(/jpe?g|png|gif/i)
      debug_say "source images: #{source_images.inspect}"
      fatal_say("No images found in #{source}!") if source_images.empty?
      source_images
    end

    def say(m, *colors)
      if colors.empty?
        colors = [:red, :on_black, :bold]
      end

      m = OUTLOG.color(m, *colors)
      OUTLOG.say(m) if verbose
    end      

    def fatal_say(m, *colors)
      if colors.empty?
        colors = [:red, :on_black, :bold]
      end

      m = ERRLOG.color(m, *colors)
      ERRLOG.say("FATAL: #{m}")

      raise MakeGallery::Exception.new(m)
    end

    def debug_say(m, *colors)
      if colors.empty?
        colors = [:yellow, :on_black, :bold]
      end

      m = ERRLOG.color(m, *colors)
      ERRLOG.say("DEBUG: #{m}") if debug
    end
  end
end
