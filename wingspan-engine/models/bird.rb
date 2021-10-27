require_relative "../importers/bird_importer"

class Bird
  attr_reader :bird_id, :name, :expansion, :cost, :habitat, :color,
              :power_text, :power, :predator, :flocking, :nest,
              :victory_points, :egg_capacity, :wingspan,
              :bonus_card_eligibility

  alias :predator? :predator
  alias :flocking? :flocking

  def initialize(**kwargs)
    kwargs.each do |k ,v|
      instance_variable_set("@#{k}", v)
    end
  end

  class << self
    def get_bird(bird_id)
      @birds ||= {}
      return @birds[bird_id] if @birds[bird_id]

      @birds[bird_id] = BirdImporter.import(bird_id)
    end
  end
end