require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true


helpers do
	def calculate_total(array)
	  sum = 0
	  y = array.map { |x| x.last }

	  y.each do |b|
	    if b == 'A'
	      sum += 11
	    elsif b.to_i == 0
	      sum += 10 
	    else
	      sum += b.to_i    
	    end
	  end

	  # correction for A
	  y.select{|e| e == 'A' }.count.times do
	    sum -=10 if sum > 21
	  end
	  return sum
	end

end

get '/' do
  erb :set_name
end

post '/save_name' do
	session[:player_name] = params[:player_name]
	redirect '/bet_amount'
end

get '/bet_amount' do
	erb :bet_amount
end

get '/start_game' do
	session[:player_amount] = params[:amount]
	session[:player_cards] = []
	session[:dealer_cards] = []

	suites = ['H', 'S', 'D', 'C']
	numbers = [ '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
	deck = suites.product(numbers)
	session[:deck] = deck.shuffle!

	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	
	erb :start_game
end




