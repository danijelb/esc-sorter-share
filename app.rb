require 'sinatra'
require './songs'
require './countries'

get '/' do
  erb :index
end

post '/share' do
  share_code = params[:share_code]
  year = share_code.match(/\d+/)[0].to_i
  order = share_code.match(/(\w+,\s*)+\w+/)[0].gsub(", ", ",")
  
  redirect "/share/#{year}/#{order}"
end

get '/share/:year/:order' do
  song_list = SONGS[params[:year]]

  # Split the order param and remove duplicates
  songs = params[:order].split(',').uniq

  # Make sure only valid country codes are in the array
  songs = songs.select { |code| song_list.has_key?(code.to_sym) }

  # Proceed only if all countries are present in the list
  if songs.length == song_list.length
    output_arr = songs.map { |country| 
      "#{song_list.dig country.to_sym, :artist} - #{song_list.dig country.to_sym, :song}\n"
    }

    output_arr
  else
    "Share code not valid"
  end
end