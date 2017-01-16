def convert_to_celsius(degrees, scale)
    return degrees if scale == 'C'
    scale == 'K' ? degrees - 273.15 : (degrees - 32) * (5.0 / 9.0)
end
def convert_to_fahrenheit(degrees, scale)
    return degrees if scale == 'F'
    celsius_temperature = convert_to_celsius(degrees, scale)
    celsius_temperature * (9.0 / 5.0) + 32
end
def convert_to_kelvin(degrees, scale)
    return degrees if scale == 'K'
    celsius_temperature = convert_to_celsius(degrees, scale)
    celsius_temperature + 273.15
end
def convert_between_temperature_units(degrees, from, to)
    return degrees if from == to
    return convert_to_celsius(degrees, from) if to == 'C'
    return convert_to_fahrenheit(degrees, from) if to == 'F'
    return convert_to_kelvin(degrees, from) if to == 'K'
end
TEMPERATURES = {
    'water' => [0, 100],
    'ethanol' => [-114, 78.37],
    'gold' => [1064, 2700],
    'silver' => [961.8, 2162],
    'copper' => [1085, 2567]
}.freeze
# Rubocop: -Freeze!
# Me: ...
def melting_point_of_substance(substance, scale)
    convert_between_temperature_units(TEMPERATURES[substance].first, 'C', scale)
end
def boiling_point_of_substance(substance, scale)
    convert_between_temperature_units(TEMPERATURES[substance].last, 'C', scale)
end
