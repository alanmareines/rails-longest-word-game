require 'open-uri'
require 'json'

# :nodoc:
class GamesController < ApplicationController
  # frozen_string_literal:true
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @time = Time.now.to_i - DateTime.parse(params[:time_start]).to_i
    run_game(params[:word], params[:grid], @time)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, time)
    @result = { time: time }

    score_and_message = score_and_message(attempt, grid, time)
    @result[:score] = score_and_message.first
    @result[:message] = score_and_message.last

    @result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end
end
