require_relative "json_importer"
require "json"

class BirdImporter < JSONImporter
  BIRD_DATA_PATH = "../data/birds.json"

  class << self
    def import(bird_id)
      puts "Importing bird id #{bird_id}"

      bird_json = raw_data.find{ |bird| bird["id"] == bird_id }
      return unless bird_json

      hash_to_bird_obj(bird_json)
    end

    private

    def hash_to_bird_obj(hash)
      Bird.new(
        bird_id: hash["id"],
        name: hash["commonName"],
        expansion: hash["expansionVersion"],
        cost: hash_to_cost_obj(hash),
        habitat: hash_to_habitat_obj(hash),
        color: hash["color"],
        power_text: hash["powerText"],
        power: nil, # TODO
        predator: !!hash["predator"],
        flocking: !!hash["flocking"],
        nest: hash["nestType"],
        victory_points: hash["victoryPoints"].to_i,
        egg_capacity: hash["eggCapacity"].to_i,
        wingspan: hash["wingspan"].to_i,
        bonus_card_eligibility: nil # TODO
      )
    end

    def hash_to_cost_obj(hash)
      {
        invertebrate: hash["invertebrate"].to_i,
        seed: hash["seed"].to_i,
        fish: hash["fish"].to_i,
        fruit: hash["fruit"].to_i,
        rodent: hash["rodent"].to_i,
        nectar: hash["nectar"].to_i,
        wild: hash["wild"].to_i
      }
    end

    def hash_to_habitat_obj(hash)
      {
        forest: !!hash["forest"],
        grassland: !!hash["grassland"],
        wetland: !!hash["wetland"]
      }
    end

    def raw_data
      file_path = File.join(File.dirname(__FILE__), BIRD_DATA_PATH)
      @raw_data ||= JSON.parse(File.read(file_path))
    end
  end
end