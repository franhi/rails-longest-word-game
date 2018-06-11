require 'open-uri'
require 'date'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def score
    @word = params[:word]
    @letters = params[:letters]
    @end_time = params[:end_time]
    @message = message
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(guess, time_taken)
    time_taken > 60.0 ? 0 : guess.size * (1.0 - time_taken / 60.0)
  end


  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

  # def compute_score(guess)
    # guess.size**2
  # end

  def message
    @time_taken = @end_time - @start_time
    if included?(@word.upcase, @letters)
      if english_word?(@word)
        ["Well done! your score is: #{compute_score(@word, @time_taken)}"]
      else
        ["Not an english word", "Score: 0"]
      end
    else
      ["Not in the grid Score", "Score: 0"]
    end
  end
end
