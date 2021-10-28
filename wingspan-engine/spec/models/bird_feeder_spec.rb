require_relative "../../models/bird_feeder"

describe BirdFeeder do
  let(:birdfeeder) { BirdFeeder.new }

  let(:rigged_birdfeeder) do
    birdfeeder = BirdFeeder.new
    birdfeeder.instance_variable_set(:@dice, [
      [:fish],
      [:rodent],
      [:invertebrate],
      [:seed, :nectar],
      [:fruit, :nectar],
    ])

    birdfeeder
  end

  let(:all_same_birdfeeder) do
    birdfeeder = BirdFeeder.new
    birdfeeder.instance_variable_set(:@dice, [
      [:fish],
      [:fish],
      [:fish]
    ])

    birdfeeder
  end

  describe "initialization" do
    it "is initialized with five dice" do
      expect(birdfeeder.dice.length).to eq(5)
    end

    it "is initialized with random dice" do
      srand 1
      first_dice = BirdFeeder.new.dice

      srand 2
      second_dice = BirdFeeder.new.dice

      expect(first_dice).to_not eq(second_dice)
    end
  end

  describe "taking dice" do
    it "removes a dice from the birdfeeder if the chosen dice is valid" do
      expect(rigged_birdfeeder.dice.length).to eq(5)
      expect(rigged_birdfeeder.dice).to include([:fish])

      value = rigged_birdfeeder.take_dice!([:fish])
      expect(rigged_birdfeeder.dice.length).to eq(4)
      expect(rigged_birdfeeder.dice).to_not include([:fish])

      expect(value).to eq([:fish])
    end

    it "rerolls the bird feeder if we take the last dice" do
      4.times do
        birdfeeder.take_dice!(birdfeeder.dice.first)
      end

      expect(birdfeeder.dice.length).to eq(1)
      birdfeeder.take_dice!(birdfeeder.dice.first)

      expect(birdfeeder.dice.length).to eq(5)
    end

    it "raises an error if the dice value is invalid" do
      expect { birdfeeder.take_dice!([:cheese]) }.to raise_error(InvalidMoveError)
    end

    it "raises an error if the dice value is not in the birdfeeder" do
      expect { rigged_birdfeeder.take_dice!([:invertebrate, :seed]) }.to raise_error(InvalidMoveError)
    end
  end

  describe "resetting the birdfeeder" do
    it "resets the bird feeder when there is only one dice remaining in the birdfeeder" do
      4.times do
        birdfeeder.take_dice!(birdfeeder.dice.first)
      end

      expect(birdfeeder.dice.length).to eq(1)
      birdfeeder.reset_dice!

      expect(birdfeeder.dice.length).to eq(5)
    end

    it "resets the bird feeder when there are more than 1 dice remaining, but they're all the same" do
      expect(all_same_birdfeeder.dice.uniq.length).to eq(1)
      expect(all_same_birdfeeder.dice.length).to be > 1
      expect(all_same_birdfeeder.dice.length).to be < 5

      all_same_birdfeeder.reset_dice!
      expect(all_same_birdfeeder.dice.length).to eq(5)
    end

    it "raises an error if there are multiple unique dice in the birdfeeder" do
      expect { rigged_birdfeeder.reset_dice! }.to raise_error(InvalidMoveError)
    end
  end
end