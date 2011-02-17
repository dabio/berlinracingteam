# encoding: utf-8
#
#   this is berlinracingteam.de, a cuba application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlinracingteam,
#   then a dot and a 'de')
#

class Thread
  include DataMapper::Resource

  property :id,     Serial
  property :title,  String
  timestamps :at

  belongs_to :person
  has n, :comments

  validates_presence_of :title, :text

  def permalink
    "/diskussion/#{id}"
  end
end

