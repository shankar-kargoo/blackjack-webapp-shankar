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

	def card_image(card)
			suit = case card[0]
				when 'H' then 'hearts'
				when 'C' then 'clubs'
				when 'S' then 'spades'
				when 'D' then 'diamonds'
			end
			value = case card[1]
				when 'A' then 'ace'
				when 'J' then 'jack'
				when 'K' then 'king'
				when 'Q' then 'queen'
				else card[1]
			end
			"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
	end

	def find_winner(player_cards, dealer_cards)
		player_cards = session[:player_cards]
		dealer_cards = session[:dealer_cards]
		player_total = calculate_total(session[:player_cards])
		dealer_total = calculate_total(session[:dealer_cards])
		
		if player_total == dealer_total
			return "Tie"
		elsif player_total < dealer_total
			return "Dealer"
		elsif player_total > dealer_total
			return "Player"
		end
	end	
end

before do
	@show_buttons = true
	@dealer_button = false
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
	if session[:player_name].empty?
		@error = "Please enter your name"
		halt erb(:add_new_player)
	else	
		session[:player_amount] = params[:amount]
		redirect '/start_game'
	end
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
	
	player_total = calculate_total(session[:player_cards])
	dealer_total = calculate_total(session[:dealer_cards])
	
	if player_total == 21 && dealer_total == 21
			@show_buttons = false
			@sucess = "Well, both dealer and you hit blackjack, hence it's a tie!"

	elsif player_total == 21
		@sucess = "Congratulations #{session[:player_name]}, You hit Blackjack!"
		@show_buttons = false
		erb :start_game
	
	elsif dealer_total == 21
		@error = "Dealer hit Blackjack, #{session[:player_name]} you lost"
		@show_buttons = false
		erb :start_game
	
	elsif player_total > 21
		@error = "Sorry #{session[:player_name]}you are busted!"
		@show_buttons = false
		erb :start_game
	
	elsif dealer_total > 21
		@sucess = "Dealer went bust. Congratulations, #{session[:player_name]} you won!"
		@show_buttons = false
		erb :start_game

	else
		erb :start_game
	end
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	
	player_total = calculate_total(session[:player_cards])
	if player_total == 21
		@sucess = "Congratulations #{session[:player_name]}, You hit Blackjack!"
		@show_buttons = false
		erb :start_game
	elsif player_total > 21
		@error = "Sorry #{session[:player_name]}you are busted!"
		@show_buttons = false
		erb :start_game
	else 
		erb :start_game
	end
end

post '/game/player/stay' do
		player_cards = session[:player_cards]
		dealer_cards = session[:dealer_cards]
		player_total = calculate_total(session[:player_cards])
		dealer_total = calculate_total(session[:dealer_cards])
	
	if dealer_total > 16
		if find_winner(player_cards, dealer_cards) == "Tie"
			@sucess = "Both dealer and you have same hand. It's a Tie"
			@show_buttons = false
			erb :start_game
		
		elsif find_winner(player_cards, dealer_cards) == "Dealer"
			@error = "Dealer has better hand. #{session[:player_name]} you lost."
			@show_buttons = false
			erb :start_game
			
		elsif find_winner(player_cards, dealer_cards) == "Player"
			@sucess = "Congratulations #{session[:player_name]}, You have a better hand, you win!"
			@show_buttons = false
			erb :start_game
		end
	else
			@sucess = "You have chosen to stay"
			@dealer_button = true
			erb :start_game
	end
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop

	player_cards = session[:player_cards]
	dealer_cards = session[:dealer_cards]
	player_total = calculate_total(session[:player_cards])
	dealer_total = calculate_total(session[:dealer_cards])
	
	if dealer_total > 16
	
		if dealer_total == 21
			@error = "Dealer hit Blackjack, #{session[:player_name]} you lost"
			@show_buttons = false
			erb :start_game
	
		elsif dealer_total > 21
			@sucess = "Dealer went bust. Congratulations, #{session[:player_name]} you won!"
			@show_buttons = false
			erb :start_game
	
		else
			if find_winner(player_cards, dealer_cards) == "Tie"
				@sucess = "Both dealer and you have same hand. It's a Tie"
				@show_buttons = false
				erb :start_game
			
			elsif find_winner(player_cards, dealer_cards) == "Dealer"
				@error = "Dealer has better hand. #{session[:player_name]} you lost."
				@show_buttons = false
				erb :start_game
				
			else find_winner(player_cards, dealer_cards) == "Player"
				@sucess = "Congratulations #{session[:player_name]}, You have a better hand, you win!"
				@show_buttons = false
				erb :start_game
			end
		end
	
	else 
		@dealer_button = true
		erb :start_game
	end
end

post '/game/player/hit' do
	#what should happen when dealer hits
end


get '/logout' do
  session.clear
  redirect '/'
end

get '/restart' do
	session[:deck] = []
	session[:player_cards] = []
	session[:dealer_cards] = []
	redirect '/'
end

