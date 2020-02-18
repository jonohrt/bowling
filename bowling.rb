require "pry"

class Game
  class BowlingError < StandardError; end

  def initialize
    @current_score = []
  end

  def roll(number_of_pins)
    raise BowlingError if number_of_pins.negative?
    raise BowlingError if number_of_pins > 10
    @current_score = add_roll(number_of_pins, @current_score)
    raise BowlingError if @current_score.length < 10 && last(@current_score).sum > 10
  end

  def score
    @current_score.each_with_index.reduce(0) do |score, (current_frame, index) |
      score + score_frame(current_frame, index, @current_score)
    end
  end

  private def add_roll(roll, current_score)
    return current_score + [[roll]] if last_frame_complete?(last(current_score)) && !tenth_frame_extra_roll?(current_score)

    add_another_roll(current_score, roll)
  end

  private def score_frame(current_frame, index, current_score)
    return current_frame.sum + current_score[index + 1].first if spare?(current_frame)
    return score_strike(current_frame, index, current_score) if strike?(current_frame)
    current_frame.sum
  end

  private def score_strike(current_frame, index, current_score)
    current_frame.sum +
      current_score[index + 1].first +
      (
        current_score[index + 1][1] || current_score[index + 2].first
      )
  end


  private def tenth_frame_extra_roll?(current_score)
    tenth_frame?(current_score) &&
      tenth_frame_second_or_third_roll?(last(current_score))
  end

  private def tenth_frame?(current_score)
    current_score.length == 10
  end

  private def tenth_frame_second_or_third_roll?(last_frame)
    last_frame.sum == 10 || last_frame.sum == 20
  end

  private def add_another_roll(current_score, roll)
    drop_last(current_score) + [last(current_score) + [roll]]
  end

  private def last_frame_complete?(last_frame)
    last_frame.nil? ||  complete?(last_frame) || strike?(last_frame)
  end

  private def strike?(frame)
    !frame.nil? && frame.length == 1 && frame.first == 10
  end

  private def spare?(frame)
    !frame.nil? && frame.length == 2 && frame.sum == 10
  end


  private def drop_last(current_score)
    current_score[0..-2]
  end

  private def last(current_score)
    current_score.slice(-1)
  end

  private def complete?(frame)
    frame.length == 2
  end
end
