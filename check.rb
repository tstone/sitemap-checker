require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'xmlsimple'
require 'benchmark'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

# parse args

args = {
	domain: "",
	delay: 1 # in seconds
}

ARGV.each_with_index do |arg, i|
  if i == 0
    args[:domain] = arg.strip
  elsif i == 1
    args[:delay] = arg.strip.to_i
  end
end

if args[:domain].nil? or args[:domain].empty?
  puts "Domain to check required."
else
  SitemapChecker.new(args).check  
end
