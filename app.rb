require 'sinatra'
require 'imgkit'
require 'base64'
require './songs'
require './countries'

IMGKit.configure do |config|
  config.wkhtmltoimage = File.dirname(__FILE__) + '/bin/wkhtmltoimage-amd64'
end  

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
    @songs = songs.map do |country|
      {
        :artist => song_list.dig(country.to_sym, :artist),
        :song => song_list.dig(country.to_sym, :song),
        :country => COUNTRIES[country.to_sym]
      }
    end

    kit = IMGKit.new(erb(:image, layout: false), :quality => 90)
    kit.stylesheets << 'public/css/image.css'

    @img = Base64.encode64(kit.to_img)

    erb :share
  else
    "Share code not valid"
  end
end