require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    grid = []
    10.times { grid << ('A'..'Z').to_a.sample(1) }
    @letters = grid.flatten
  end

  def score
    @result = {}
    @attempt = params[:attempt]
    @letters = params[:letters]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now

    @result = run_game(@attempt, @letters, @start_time, @end_time)
  end

  def isenglish?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"

    attempt_serialized = open(url).read
    api_result = JSON.parse(attempt_serialized)

    api_result["found"]
  end

  def letters_check?(attempt, grid)
    attempt_hash = Hash.new(0)
    grid_hash = Hash.new(0)

    attempt.chars.each { |char| attempt_hash[char.upcase] += 1 }

    grid.split(" ").each { |char| grid_hash[char] += 1 }

    attempt_hash.all? do |key, _value|
      attempt_hash[key] <= grid_hash[key]
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    result = {}
    result[:time] = end_time - start_time

    if isenglish?(attempt)
      if letters_check?(attempt, grid)
        result[:message] = "well done"
        result[:score] = (attempt.length / result[:time].to_f)
      else
        result[:message] = "Your word is not in the grid"
        result[:score] = 0
      end
    else
      result[:message] = "Your word is not an English word"
      result[:score] = 0
    end
    return result
  end
end
