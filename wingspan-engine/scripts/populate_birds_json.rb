# Quick script to pull birds from all_birds.csv into birds.json.
# Birds.json is the database of birds used to play the game.

require "csv"
require "json"
require "byebug"
require 'active_support/core_ext/string'

csv = CSV.read(File.join(File.dirname(__FILE__), "../data/all_birds.csv"), headers: true)

# Include 50 birds for now.
bird_rows = csv.select {|b| b["Expansion Version"] == "originalcore"}.first(50)

def bird_row_to_hash(bird)
  hash = bird.to_h

  # Camelcase all keys
  hash.transform_keys! { |key| key.gsub(" ","").camelcase(:lower)}

  # Remove trailing and leading spaces in values
  hash.transform_values! { |value| value.is_a?(String) ? value.strip : value }

  hash
end

bird_hash = bird_rows.map do |bird_row|
  bird_row_to_hash(bird_row)
end

bird_hash.each_with_index do |h, i|
  h[:id] = i
end

# Transform all keys to be camelcased
File.write(File.join(File.dirname(__FILE__), "../data/birds.json"), JSON.pretty_generate(bird_hash))