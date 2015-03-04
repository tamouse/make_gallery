require 'spec_helper'
require 'make_gallery'
require 'stringio'

def save_output(&block)
  old_output = $stdout
  old_error = $stderr

  stro = StringIO.open('', 'w+')
  stre = StringIO.open('', 'w+')

  $stdout = stro
  $stderr = stre

  block_result = yield

  stro.rewind
  output = stro.read

  stre.rewind
  error = stre.read

  $stdout = old_output
  $stderr = old_error
  
  [ block_result, output, error ]
end

RSpec.describe MakeGallery do

  it "shows a banner" do
    result, output_buffer, error_buffer = save_output do 
      MakeGallery.start(%w[help])
    end
    expect(error_buffer).to be_empty, "Got errors: #{error_buffer}"
    expect(output_buffer).to match(/\ACommands:/), "Did not get a Commands: banner. Output was: #{output_buffer}"
  end

end
