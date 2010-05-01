#!/usr/bin/ruby

require 'rubygems'
require 'open-uri'
require 'CGI'

# Set the image ID here
IMAGE_MEMEGENERATOR = '940'

# Set the repeat amount here
TO_REPEAT = 1

# Other vars
USER_AGENT = 'OMG LOLZ'
URL_AUTOMEME = 'http://automeme.net/moar.txt'
URL_MEMEGENERATOR = 'http://memegenerator.net/ImageMacro/Create'


def get_automemes
  puts "\nGetting more memes..."

  cmd = "curl -s -L -A \"#{USER_AGENT}\" \"#{URL_AUTOMEME}\" 2>&1"
  memes = `#{cmd}`
  puts "...gotten!\n\n"
  return memes.split("\n")
end

def post_memegenerator(meme)
  return false if meme.nil? || meme == ''

  # Attempt to break on first sentence
  line1 = meme.gsub(/^([A-Z0-9\-\,\_\*\;\:\s]+)([\.|\!|\?])(.*)$/i, '\1\2').strip
  line2 = meme.gsub(/^([A-Z0-9\-\,\_\*\;\:\s]+)([\.|\!|\?])(.*)$/i, '\3').strip rescue nil

  # If not, then break on comma, semicolon, or colon
  if line1 == line2 || line2.nil? || line2 == '' || line1.length <= 7
    line1 = meme.gsub(/^([A-Z0-9\-\_\*\s]+)([\,|\:|\;])(.*)$/i, '\1\2').strip
    line2 = meme.gsub(/^([A-Z0-9\-\_\*\s]+)([\,|\:|\;])(.*)$/i, '\3').strip rescue nil
  end

  # If this is a one-liner, attempt to break up in the middle (not so smart... yet)
  if line1 == line2 || line2.nil? || line2 == '' || line1.length <= 7
    lines = meme.split(' ')
    mid = (lines.length/2.to_f).floor.to_i
    line1 = lines[0..mid].join(' ')
    line2 = lines[(mid+1)..(lines.length-1)].join(' ')
  end

  # Why does regular ruby not have a .blank? :(
  if line1 == line2 || line1.nil? || line1 == '' || line2.nil? || line2 == ''
    puts "Cannot break apart #{meme}."
    return false
  end

  puts "Posting meme: #{meme}"

  # This is a POST to /ImageMacro/Create
  data = "fileID=#{IMAGE_MEMEGENERATOR}&firstline=#{CGI.unescape line1}&secondline=#{CGI.unescape line2}"

  cmd = "curl -s -d \"#{data}\" \"#{URL_MEMEGENERATOR}\""
  result = `#{cmd}`

  puts "Available at: http://memegenerator.net#{result.gsub(/\n/im, '').gsub(/^(.*)(href=\")([A-Z0-9\-\/\_]+)(\")(.*$)/i, '\3')}"

  sleep 15 # Lets be nice!
rescue
  puts "DERP! AN ERROR HAZ HAPPENED: #{$!}"
end


def generate_memes
  puts "Start...\n"

  memes = nil

  TO_REPEAT.times do
    memes = get_automemes if memes.nil? || memes.length < 1
    meme = memes.shift
    # meme = "This is a test Another one."
    post_memegenerator(meme)
  end

  puts "\nEnd..."
end

# Lets Go!
generate_memes
