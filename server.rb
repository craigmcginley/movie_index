require 'sinatra'
require 'csv'

def get_movie_data
  movies = []
  CSV.foreach('movies.csv', headers: true, header_converters: :symbol) do |row|
    movies << row.to_hash
  end
  movies.sort_by! {|k| k[:title]}
end

get '/movies' do
  page = params[:page].to_i
  search = params[:query].to_s.downcase
  @movies = get_movie_data
  @display_movies = []
  @no_results = ""
  @search_movies = []

  if @movies.length % 20 == 0
    @max_length = (@movies.length/20)
  else
    @max_length = ((@movies.length/20) + 1)
  end
  if params[:page] == nil
    page = 1
  end

  @display_movies = @movies[(20*(page-1))..(20*(page-1)+19)]

  if search == ""
  else
    @movies.each do |movie|
      if movie[:title].downcase.match(/\b#{search}\b/)
        @search_movies << movie
      elsif movie[:synopsis] == "" || movie[:synopsis] == nil
      elsif movie[:synopsis].downcase.match(/\b#{search}\b/)
        @search_movies << movie
      else
        @no_results = "***No search results***"
      end
    end
    @display_movies = @search_movies[(20*(page-1))..(20*(page-1)+19)]
  end

  erb :index
end

get '/movies/:id' do
  @movies = get_movie_data
  @movie = nil
  @movies.each do |movie|
    if movie[:id] == params[:id]
      @movie = movie
    end
  end
  erb :id
end
