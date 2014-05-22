require 'sinatra'
require 'csv'
require 'pry'

def get_movie_data
  movies = []
  CSV.foreach('movies.csv', headers: true, header_converters: :symbol) do |row|
    movies << row.to_hash
  end
  movies.sort_by! {|k| k[:title]}
end

def search(search, movies)
  return [] if search == ""
  search_results = []
  movies.each do |movie|
    if movie[:title].downcase.match(/\b#{search}\b/)
      search_results << movie
    elsif movie[:synopsis] == "" || movie[:synopsis] == nil
    elsif movie[:synopsis].downcase.match(/\b#{search}\b/)
      search_results << movie
    end
  end
  search_results
end

def display(page, movies)
  movies[(20*(page-1))..(20*(page-1)+19)]
end

def max_length(movies)
  max_length = 0
  if movies.length % 20 == 0
    max_length = movies.length / 20
  else
    max_length = ((movies.length / 20) + 1)
  end
  max_length
end

get '/' do
  redirect '/movies'
end

get '/movies' do
  page = 1
  if params.has_key?("page")
    if params["page"] == ""
      page = 1
    else
      page = params["page"].to_i
    end
  end

  search = nil
  if params.has_key?("query")
    search = params["query"].to_s.downcase
  end

  @movies = get_movie_data
  @display_movies = []
  @max_length = max_length(@movies)

  @display_movies = display(page, @movies)

  if search != nil
    @display_movies = search(search, @movies)
  end

  erb :index2
end

get '/movies/:id' do
  @movies = get_movie_data
  @max_length = max_length(@movies)

  @movie = nil
  @movies.each do |movie|
    if movie[:id] == params[:id]
      @movie = movie
    end
  end

  erb :id2
end
