require 'rubygems'
require 'sinatra'
require 'sequel'
require 'haml'

DB = Sequel.connect "mysql://localhost/likebutton?user=likebutton&password=likebutton"
enable :sessions

get '/stylesheets/style.css' do
  sass :style
end

get '/' do
  @projects = DB[:projects]
  @cheat = session[:cheat]
  @voted = session[:voted]
  haml :index
end

post '/' do
  if session[:voted]
    session[:cheat] = true
  else
    session[:voted] = true
    votes = DB[:votes]
    votes.insert(:project_id => params[:project_id])
  end
  redirect '/'
end

get '/results' do
  @results = results = DB[:votes].group(:project_id).select('count(*) as count'.lit, :name, :creator).inner_join(:projects, :id => :project_id).order('count(*) desc'.lit)  
  haml :results
end