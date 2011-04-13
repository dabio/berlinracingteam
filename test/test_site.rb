# coding:utf-8
#
#   this is berlinracingteam.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlinracingteam,
#   then a dot and a 'de')
#


require 'helper'

class TestSite < Test::Unit::TestCase
  include Rack::Test::Methods
  include Helpers

  def app
    BerlinRacingTeam
  end

  def login
    post '/login', {email: 'dummy@user.com', password: 'test123'}
  end

  def logout
    get '/logout'
  end

  def test_main_css
    get '/css/styles.css'
    assert last_response.ok?
    assert last_response.body.include?('background')
  end

  def test_head_index
    head '/'
    assert last_response.ok?
    assert !last_response.body.include?('DOCTYPE html')
  end

  def test_front_page_essentials
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('DOCTYPE html')
    assert last_response.body.include?('Neuigkeiten rund um das Berlin Racing Team')
  end

  def test_dashboard_404
    get '/dashboard'
    assert_equal 404, last_response.status
  end

  def test_dashboard
    login
    get '/dashboard'
    assert last_response.ok?
    logout
  end

  def test_login
    get '/login'
    assert last_response.ok?
    assert last_response.body.include?('Anmelden')
  end

  def test_login_wrong_credentials
    post '/login', {email: 'dummy@user.com', password: 'blahblah'}
    assert last_response.ok?
    assert last_response.body.include?('Unbekannte E-Mail oder falsches Password')
  end

  def test_team_site_essentials
    get '/team'
    assert last_response.ok?
    Person.all.each do |person|
      assert last_response.body.include?(person.medium_url)
    end
  end

  def test_person_detail
    person = Person.first(slug: 'danilo-braband')

    get person.permalink
    assert last_response.ok?

    person.participations.each do |p|
      assert last_response.body.include?(p.event.title)
    end
    assert last_response.body.include?("Rennen: #{person.participations.length}")
    assert last_response.body.include?(encrypt_email(person.email))
  end

  def test_person_edit_404
    person = Person.first(slug: 'dummy-user')
    get person.editlink
    assert_equal 404, last_response.status
  end

  def test_person_visit_404
    put '/visit'
    assert_equal 404, last_response.status
  end

  def test_events_site_essentials
    year = today.year
    @events = Event.all(:date.gte => "#{year}-01-01", :date.lte => "#{year}-12-31")

    get '/rennen'
    assert last_response.ok?
    @events.each do |event|
      assert last_response.body.include?("<h3>#{event.title.sub(/\s.+/, '')}")
    end
  end

  def test_events_previous_year
    year = today.year-1

    @events = Event.all(:date.gte => "#{year}-01-01", :date.lte => "#{year}-12-31")

    get "/rennen/#{year}"
    assert last_response.ok?
    @events.each do |event|
      assert last_response.body.include?("<h3>#{event.title.sub(/\s.+/, '')}")
    end
  end

  def test_sponsoren
    get '/sponsoren'
    assert last_response.ok?
  end

  def test_404
    get '/fake/path'
    assert_equal 404, last_response.status
    assert last_response.body.include?('Seite nicht gefunden werden')
  end
end
