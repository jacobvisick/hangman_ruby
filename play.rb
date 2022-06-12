require './lib/hangman.rb'

def load_games(saved_games, wrong_tries)
    saved_games.each_with_index do |filename, index|
        name = filename.delete_prefix('saved_games/')
        name = name.delete_suffix('.save')
        puts "#{index + 1}) #{name}"
    end

    puts "Games are titled by date and time."
    puts "Please enter which game you'd like to load."
    game_choice = gets.chomp.to_i

    if game_choice <= saved_games.length && game_choice != 0
        Hangman.load_game(saved_games[game_choice - 1]).play
    else
        puts "Invalid choice."
        return if wrong_tries >= 3

        wrong_tries += 1
        load_games(saved_games, wrong_tries)
    end
end

saved_games = Dir.glob('saved_games/*.save')

if saved_games.length > 0
    puts "There are saved games!"
    puts "Would you like to load one now? (y / n)"
    response = gets.chomp.downcase

    if response == 'y' then
        load_games(saved_games, 0)
    else
        puts "Starting new game..."
        Hangman.new.play
    end
else
    Hangman.new.play
end