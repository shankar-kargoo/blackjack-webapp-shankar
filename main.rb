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

before do
	@show_buttons = true
end

get '/' do
	if session[:player_name] 
  	redirect '/start_game'
	else
		redirect '/new_player'
	end
end

get '/new_player' do
	erb :add_new_player
end

post '/new_player' do
	session[:player_name] = params[:player_name]
	session[:player_amount] = params[:amount]
	redirect '/start_game'
end

get '/start_game' do

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

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	@player_total = calculate_total(session[:player_cards])
	if @player_total <= 21
		erb :start_game
	elsif @player_total == 21
		@sucess = "You hit Blackjack!"
		@show_buttons = false
		erb :start_game
	else
		@error = "Sorry you are busted!"
		@show_buttons = false
		erb :start_game
		end
end

post '/game/player/stay' do
	@sucess = "You have chosen to stay"
		@show_buttons = false
	erb :start_game
end



