require "spec_helper"
require "make_gallery/command"

RSpec.describe MakeGallery::Command do
  let(:source) { "./spec/test_input_data/" }
  let(:target) { "./spec/test_thumbs/" }
  let(:args) do
    {
      :debug => false,
      :dry_run => true,
      :verbose => true,
      :format => "gif",
      :quality => 30,
      :size => 200,
      :source => source,
      :target => target,
      :force => true
    }
  end
  subject { MakeGallery::Command.new(:thumbs, args) }

  describe "#build_command" do
    it "returns the mogrify command" do
      expect(subject.build_command).to match_array([
          "/usr/local/bin/mogrify",
          "-verbose",
          "-format gif",
          "-path ./spec/test_thumbs/",
          "-quality 30",
          "-thumbnail 200x200^",
          "-gravity center",
          "-extent 200x200",
          "./spec/test_input_data/squirrel-001.jpg",
          "./spec/test_input_data/squirrel-002.jpg",
          "./spec/test_input_data/squirrel-003.jpg",
          "./spec/test_input_data/squirrel-004.jpg",
          "./spec/test_input_data/squirrel-005.jpg",
          "./spec/test_input_data/squirrel-006.jpg"
        ])
    end
  end

  describe "#locate_mogrify" do
    context "when mogrify_path is NOT given" do
      context "when mogrify DOES exist" do
        it "returns the mogrify program location" do
          expect(File).to receive(:exist?).with("/usr/local/bin/mogrify").and_return(true)
          expect(subject.locate_mogrify).to eq("/usr/local/bin/mogrify")
        end
      end

      context "when mogrify does NOT exist" do
        it "prints an error and raises an exception" do
          expect(File).to receive(:exist?).with("/usr/local/bin/mogrify").and_return(false)
          expect{subject.locate_mogrify}.to raise_error
        end
      end
    end

    context "when mogrify_path IS given" do
      context "when mogrify DOES exist" do
        it "returns the mogrify program location" do
          subject.mogrify_path "/usr/local/bin/mogrify"
          expect(File).to receive(:exist?).with("/usr/local/bin/mogrify").and_return(true)
          expect(subject.locate_mogrify).to eq("/usr/local/bin/mogrify")
        end
      end

      context "when mogrify does NOT exist" do
        it "prints an error and raises an exception" do
          subject.mogrify_path "/usr/local/bin/mogrify"
          expect(File).to receive(:exist?).with("/usr/local/bin/mogrify").and_return(false)
          expect{subject.locate_mogrify}.to raise_error
        end
      end
    end
  end

  describe "#set_mogrify_options" do
    context "when the :thumbs action is used" do
      it "returns the correct command options" do
        expect(subject.set_mogrify_options).to match_array([
            "-verbose",
            "-format gif",
            "-path ./spec/test_thumbs/",
            "-quality 30",
            "-thumbnail 200x200^",
            "-gravity center",
            "-extent 200x200"
          ])
      end 
    end
    context "when the :web action is used" do
      it "returns the correct command options" do
        subject.action(:web)
        expect(subject.set_mogrify_options).to match_array([
            "-verbose",
            "-format gif",
            "-path ./spec/test_thumbs/",
            "-quality 30",
            "-resize 200"
          ])
      end 
    end
  end

  describe "#select_source_images" do
    it "returns the set of images" do
      expect(subject.select_source_images).to match_array([
          "./spec/test_input_data/squirrel-001.jpg",
          "./spec/test_input_data/squirrel-002.jpg",
          "./spec/test_input_data/squirrel-003.jpg",
          "./spec/test_input_data/squirrel-004.jpg",
          "./spec/test_input_data/squirrel-005.jpg",
          "./spec/test_input_data/squirrel-006.jpg"
        ])
    end 
  end
end
