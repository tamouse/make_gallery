$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'make_gallery'
require 'stringio'
require 'fileutils'

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
