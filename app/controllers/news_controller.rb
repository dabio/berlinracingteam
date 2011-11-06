# encoding: utf-8
#
#   this is berlinracingteam.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlinracingteam,
#   then a dot and a 'de')
#

#
# NEWS
#
class BerlinRacingTeam

  get '/news' do
    @count, @news = News.paginated(page: current_page, per_page: 5,
                                   :date.lte => today,
                                   order: [:date.desc, :updated_at.desc])
    not_found if !@news or @news.length < 1
    slim :'news/news'
  end


  post '/news' do
    not_found unless has_auth?

    @news = News.new(params[:news])
    @news.person = current_person

    if @news.save
      flash[:notice] = 'Meldung gesichert'
      redirect to('/')
    end

    redirect to('/news')
  end


  get '/news/:y/:m/:d/:slug' do |year, month, day, slug|
    date = Date.new(year.to_i, month.to_i, day.to_i)
    not_found unless @news = News.first(date: date, slug: slug)

    slim :'news/news_detail'
  end

  put '/news/:y/:m/:d/:slug' do |year, month, day, slug|
    date = Date.new(year.to_i, month.to_i, day.to_i)
    not_found unless has_auth? and news = News.first(date: date, slug: slug)

    news.update(params[:news])
    redirect to(news.permalink)
  end


  delete '/news/:y/:m/:d/:slug' do |year, month, day, slug|
    date = Date.new(year.to_i, month.to_i, day.to_i)
    not_found unless has_auth? and news = News.first(date: date, slug: slug)

    news.destroy
    'success'
  end

end

