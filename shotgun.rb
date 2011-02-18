# encoding: utf-8
#
#   this is berlinracingteam.de, a cuba application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlinracingteam,
#   then a dot and a 'de')
#

require 'cuba'
require 'slim'
require 'sass'
require 'rack/no-www'
require 'rack-r18n'
require 'dm-core'
require 'dm-timestamps'
#require 'dm-types'
require 'dm-validations'
require 'unidecode'

Dir.glob('./lib/*.rb') do |lib|
  require lib
end



