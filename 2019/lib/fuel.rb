class Fuel

  def self.fuel_for(mass)
    (mass / 3.0).floor - 2
  end

  def self.fuel_for_module(mass)
    total = 0

    while true
      fuel = fuel_for(mass)
      break if fuel <= 0
      total += fuel
      mass = fuel
    end

    total
  end

end
