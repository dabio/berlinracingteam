﻿# encoding: utf-8
#
#   this is berlinracingteam.de, a cuba application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlinracingteam,
#   then a dot and a 'de')
#

require 'bundler'
Bundler.require

# Sinatra::Base. This way, we're not polluting the global namespace with your
# methods and routes and such.
class BerlinRacingTeam < Sinatra::Base; end

require_relative 'models/init'
require_relative 'helpers'
require_relative 'config'

# It's a good form to make your Sinatra applications be a subclass of
class BerlinRacingTeam

  get '/' do
    @news = News.all(:date.lte => today, :order => [:date.desc, :updated_at.desc],
                     :limit => 3)
    slim :index
  end


  get '/login' do
    redirect to('/') if has_auth?
    slim :login
  end


  post '/login' do
    params[:email] << '@berlinracingteam.de' unless params[:email]['@']
    @person = Person.authenticate(params[:email], params[:password])

    if @person
      session[:person_id] = @person.id
      redirect to(params[:next])
    else
      flash.now[:error] = 'Unbekannte E-Mail oder falsches Password eingegeben.'
      slim :login
    end
  end


  get '/logout' do
    not_found unless has_auth?
    session[:person_id] = nil
    redirect to('/')
  end


  put '/visit' do
    not_found unless has_auth?
    Visit.first_or_create(person: current_person).update(created_at: Time.now)
  end


  get '/team' do
    @people = Person.all :order => [:last_name, :first_name]
    slim :people
  end


  get '/team/:slug' do
    not_found unless @person = Person.first(:slug => params[:slug])
    slim :person
  end


  get '/team/:slug/edit' do
    not_found unless @person = Person.first(slug: params[:slug])

    if @person == current_person or has_admin?
      slim :person_form
    else
      not_found
    end
  end


  put '/team/:slug/edit'do
    not_found unless @person = Person.first(slug: params[:slug])

    if @person == current_person or has_admin?
      @person.attributes = {
        :email  => params[:person]['email'],
        :info   => params[:person]['info']
      }

      unless params[:person]['password'].empty?
        @person.password = params[:person]['password']
        @person.password_confirmation = params[:person]['password_confirmation']
      end

      if @person.save
        flash.now[:notice] = 'Änderung gesichert.'
        redirect to(@person.editlink)
      else
        slim :person_form
      end
    else
      not_found
    end
  end


  get '/rennen' do
    @events = Event.all(:date.gte => "#{today.year}-01-01",
                        :date.lte => "#{today.year}-12-31",
                        order: [:date, :updated_at.desc])
    slim :events
  end


  get '/rennen/:year' do
    @events = Event.all(:date.gte => "#{params[:year]}-01-01",
                        :date.lte => "#{params[:year]}-12-31",
                        order: [:date, :updated_at.desc])
    slim :events
  end


  get '/diskussionen' do
    not_found unless @debates = Debate.all(order: [:updated_at.desc]) and has_auth?
    slim :debates
  end


  get '/diskussionen/new' do
    not_found unless has_auth?

    @debate = Debate.new
    @comment = Comment.new
    slim :debate_form
  end


  post '/diskussionen/new' do
    not_found unless has_auth?

    @debate = Debate.new params[:debate]
    @debate.person = current_person
    @comment = Comment.new params[:comment]
    @comment.person = current_person

    if @debate.save
      @comment.debate = @debate
      if @comment.save
        redirect to(@debate.permalink)
      else
        @debate.destroy
        slim :debate_form
      end
    else
      slim :debate_form
    end
  end


  get '/diskussionen/:id' do
    not_found unless @debate = Debate.first(id: params[:id]) and has_auth?
    slim :debate
  end


  post '/comments/new' do
    not_found unless has_auth?

    @foreign_model = Kernel.const_get(params[:type]).first(id: params[:type_id])
    @comment = Comment.new(text: params[:text],
                           params[:type].downcase => @foreign_model,
                           person: current_person)
    if @comment.save
      @foreign_model.update updated_at: Time.now
      redirect to("#{@foreign_model.permalink}#comment_#{@comment.id}")
    else
      redirect to(@foreign_model.permalink)
    end
  end


  get '/kontakt' do
    @email = Email.new()
    slim :kontakt
  end


  post '/kontakt' do
    raise not_found unless params[:email].length == 0

    @email = Email.new params[:contact]
    if @email.save
      @email.update :send_at => Time.now

      send_email(ENV['CONTACT_EMAIL'], :from => @email.email, :from_alias => @email.name, :subject => 'Nachricht von berlinracingteam.de', :body => @email.message)
      flash.now[:notice] = "#{@email.name}, vielen Dank für deine Nachricht! Wir werden sie so schnell wie möglich beantworten."

      redirect to('/kontakt')
    else
      slim :kontakt
    end
  end


  get '/sponsoren' do
    slim :sponsoren
  end


  get '/css/styles.css' do
    cache_control :public, :max_age => 29030400
    scss :'css/styles'
  end


  not_found do
    slim :'404'
  end

end

