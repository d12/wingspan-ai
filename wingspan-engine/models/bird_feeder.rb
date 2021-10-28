require_relative "../errors/invalid_move_error"

class BirdFeeder
  NUMBER_OF_DICE = 5
  DICE_SIDES = [
    [:fish],
    [:rodent],
    [:invertebrate],
    [:seed, :nectar],
    [:fruit, :nectar],
    [:invertebrate, :seed],
  ]

  attr_reader :dice

  def initialize
    @dice = []
    reset_dice!
  end

  def take_dice!(dice_face)
    unless index = @dice.index(dice_face)
      raise InvalidMoveError, "Cannot take a dice that isn't in the birdfeeder"
    end

    @dice.delete_at(index)

    reset_dice! if @dice.empty?

    dice_face
  end

  def reset_dice!
    if @dice.uniq.length > 1
      raise InvalidMoveError, "Cannot reset the dicefeeder if there are multiple different dice to choose from."
    end

    @dice = []
    refill_birdfeeder!
  end

  private

  def refill_birdfeeder!
    NUMBER_OF_DICE.times do
      @dice << DICE_SIDES.sample
    end

    @dice
  end
end