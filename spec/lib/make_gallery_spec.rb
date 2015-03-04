require 'spec_helper'
require 'make_gallery'

RSpec.describe MakeGallery::Thor do

  it "shows a banner" do
    result, output_buffer, error_buffer = save_output do 
      MakeGallery::Thor.start(%w[help])
    end
    expect(error_buffer).to be_empty, "Got errors: #{error_buffer}"
    expect(output_buffer).to match(/\ACommands:/), "Did not get a help banner. Output was: #{output_buffer}"
  end

  context "clean target directory" do
    let(:source) { File.expand_path("../../test_input_data/", __FILE__) }
    let(:target) { File.expand_path("../test_thumbs/", source) }
    let(:args)   do
      [
        "thumbs",
        "--source=#{source}",
        "--target=#{target}",
        "--dry-run"
      ]
    end

    it "creates thumbs" do
      FileUtils.rm_rf(target)
      result, output, error = save_output do
        MakeGallery::Thor.start(args)
      end
      expect(output).to include(%q|{"force"=>false, "verbose"=>true, "debug"=>true, "dry_run"=>true, "source"=>"/Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data", "target"=>"/Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_thumbs", "size"=>200, "format"=>"gif", "quality"=>60}|)
      expect(output).to include(%q|Creating thumbs images in /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data to /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_thumbs|)
      expect(output).to include(%q|/usr/local/bin/mogrify -verbose -format gif -path /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_thumbs -quality 60 -thumbnail 200x200^ -gravity center -extent 200x200 /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data/squirrel-001.jpg /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data/squirrel-002.jpg /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data/squirrel-003.jpg /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data/squirrel-004.jpg /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data/squirrel-005.jpg /Users/tamara/Projects/rubystuff/scripts/make_gallery/spec/test_input_data/squirrel-006.jpg|)
      expect(output).to include(%q|Completed|)
      expect(error).to be_empty, "Error output not empty: #{error}"
    end
  end

  context "existing target directory" do
    let(:source) { File.expand_path("../../test_input_data/", __FILE__) }
    let(:target) { File.expand_path("../test_thumbs/", source) }
    let(:args)   do
      [
        "thumbs",
        "--source=#{source}",
        "--target=#{target}",
        "--dry-run"
      ]
    end

    it "gives a warning to use --force" do
      FileUtils.mkdir_p(target)
      result, output, error = save_output do
        MakeGallery::Thor.start(args)
      end
      expect(result).to match(%r|.*/test_thumbs exist. Use --force to overwrite|)

      # expect(1).to eq(0), "Result: #{result}\nOutput: #{output}\nError: #{error}"
    end

  end

end
