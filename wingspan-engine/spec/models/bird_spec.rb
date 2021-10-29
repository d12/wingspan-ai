require_relative "../../models/bird"

describe Bird do
  let(:bird) { Bird.get_bird(0) }
  describe "initialization" do
    it "can be initialized with all valid arguments, and getters are defined for all properties" do
      props = {
        id: 1,
        name: "name",
        expansion: "exp",
        cost: {foo: 1},
        habitat: {bar: 2},
        color: "white",
        power_text: "hello",
        power: nil,
        predator: true,
        flocking: true,
        nest: "nest",
        victory_points: 5,
        egg_capacity: 4,
        wingspan: 67,
        bonus_card_eligibility: nil
      }

      bird = Bird.new(props)

      props.each do |k, v|
        expect(bird.send(k)).to eq(v)
      end
    end

    it "has aliases for flocking and predator properties" do
      expect(bird.flocking?).to eq(bird.flocking)
      expect(bird.predator?).to eq(bird.predator)
    end
  end

  describe "get_bird" do
    it "can get a bird by ID from the json blob using get_bird" do
      bird = Bird.get_bird(5)
      expect(bird.id).to eq(5)
      expect(bird.name).to eq("American Goldfinch")

      bird = Bird.get_bird(6)
      expect(bird.id).to eq(6)
      expect(bird.name).to eq("American Kestrel")
    end
  end
end