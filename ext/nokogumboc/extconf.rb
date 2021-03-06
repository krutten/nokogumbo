require 'mkmf'
$CFLAGS += " -std=c99"

if have_library('xml2', 'xmlNewDoc') 
  # libxml2 libraries from http://www.xmlsoft.org/
  pkg_config('libxml-2.0')

  # nokogiri configuration from gem install
  nokogiri_lib = Gem.find_files('nokogiri').
    select { |name| name.include? 'lib/nokogiri' }.
    sort_by {|name| name[/nokogiri-([\d.]+)/,1].split('.').map(&:to_i)}.last
  if nokogiri_lib
    nokogiri_ext = nokogiri_lib.sub(%r(lib/nokogiri(.rb)?$), 'ext/nokogiri')

    # if that doesn't work, try workarounds found in Nokogiri's extconf
    unless find_header('nokogiri.h', nokogiri_ext)
      require "#{nokogiri_ext}/extconf.rb"
    end

    # if found, enable direct calls to Nokogiri (and libxml2)
    $CFLAGS += ' -DNGLIB' if find_header('nokogiri.h', nokogiri_ext)
  end
end

# add in gumbo-parser source from github if not already installed
unless have_library('gumbo', 'gumbo_parse')
  rakehome = ENV['RAKEHOME'] || File.expand_path('../..')
  unless File.exist? "#{rakehome}/ext/nokogumboc/gumbo.h"
    require 'fileutils'
    FileUtils.cp Dir["#{rakehome}/gumbo-parser/src/*"],
      "#{rakehome}/ext/nokogumboc"
    $srcs = $objs = nil
  end
end

create_makefile('nokogumboc')
