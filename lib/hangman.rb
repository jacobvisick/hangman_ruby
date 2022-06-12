require 'msgpack'

DICTIONARY = File.readlines('res/valid_words.txt', chomp: true)
MAX_GUESSES = 6

class Hangman
    def initialize(secret_word = get_random_word, guessed_letters = [], incorrect_guesses = 0, filename = nil)
        @secret_word = secret_word
        @guessed_letters = guessed_letters
        @incorrect_guesses = incorrect_guesses
        @filename = filename

        puts revealed_letters
        puts "You have #{MAX_GUESSES - @incorrect_guesses} incorrect guesses left."
        puts "Enter 'save' or 'exit' to stop playing."
    end

    public
    def play
        while @incorrect_guesses < MAX_GUESSES && revealed_letters.include?('_') do
            guess = validate_guess(prompt_for_guess)
            @guessed_letters.push(guess)

            @incorrect_guesses += 1 unless @secret_word.include?(guess)

            puts "\n" + revealed_letters

            print "Letters guessed: "
            @guessed_letters.sort.each { |c| print c }
            print "\n\n"

            puts "You have #{MAX_GUESSES - @incorrect_guesses} guesses left."
        end

        revealed_letters.include?('_') ? game_lost : game_won
        File.delete(@filename) unless @filename == nil
    end

    def self.load_game(filename)
        #returns Hangman instance
        state = File.read(filename)
        self.unserialize_state(state)
    end

    def self.unserialize_state(data)
        state = MessagePack.load(data)
        self.new(state['secret_word'], state['guessed_letters'], state['incorrect_guesses'], state['filename'])
    end

    private
    def game_won
        puts "You win! You guessed #{@secret_word} with #{MAX_GUESSES - @incorrect_guesses} guesses left."
    end

    def game_lost
        puts "You lose! The word was #{@secret_word}"
    end

    def get_random_word
        DICTIONARY[rand(DICTIONARY.length)].upcase
    end

    def prompt_for_guess
        puts "Guess a letter"
        gets.chomp.upcase
    end

    def validate_guess(guess)
        if guess.downcase == "save" || guess.downcase == "exit"
            save_and_quit
        elsif @guessed_letters.include?(guess)
            puts "You've already guessed #{guess}."
            guess = validate_guess(prompt_for_guess)
        elsif guess.length != 1
            puts "Only one letter at a time, please."
            guess = validate_guess(prompt_for_guess)
        else
            guess
        end
    end

    def revealed_letters
        result = ''

        @secret_word.each_char do |letter|
            if @guessed_letters.include?(letter)
                result += letter
            else
                result += '_'
            end
            result += ' '
        end

        result
    end

    def save_and_quit
        puts "Would you like to save before quitting? (y / n)"
        confirmation = gets.chomp.downcase

        confirmation == 'y' ? save_game : exit
        exit
    end

    def serialize_state
        MessagePack.dump({
            secret_word: @secret_word,
            guessed_letters: @guessed_letters,
            incorrect_guesses: @incorrect_guesses,
            filename: @filename
        })
    end

    public
    def save_game
        puts "Saving game..."
        date = "#{Time.now.month}-#{Time.now.day} @ #{Time.now.hour}:#{Time.now.min.to_s.rjust(2,'0')}"
        
        Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
        @filename = "saved_games/#{date}.save"

        if File.exist?(@filename)
            @filename.delete_suffix!(".save")
            tries = 1

            @filename = @filename + " (#{tries})"
            while File.exist?(@filename + ".save")
                tries += 1
                @filename[-2] = tries.to_s
            end

            @filename += ".save"
        end

        File.open(@filename, 'w') { |file| file.print serialize_state }
    end

end