require 'json'

d = JSON.parse(File.read('cocktails.json'))

cocktail_list = d["cocktails"]
materials = d["materials"]

puts(cocktail_list.length.to_s + " cocktails in the list")
puts ""

def validate(materials, cocktail_list)
  for cocktail in cocktail_list
    if !materials["glasses"].include? cocktail["glass"]
      puts "#{cocktail["name"]} has invalid glass: #{cocktail["glass"]}"
    end
    if ![true, false].include? cocktail["ice"]
      puts "#{cocktail["name"]} has non-boolean for ice"
    end
    if (!materials["rims"].include? cocktail["rim"]) && (!cocktail["rim"].nil?)
      puts "#{cocktail["name"]} has invalid rim: #{cocktail["rim"]}"
    end
    for item in cocktail["ingredients"]
      if item["volume"].nil?
        if !materials["solid ingredients"].include? item["ingredient"]
          puts "#{cocktail["name"]} has invalid solid ingredient: #{item["ingredient"]}"
        end
      else
        if !materials["liquid ingredients"].include? item["ingredient"]
          puts "#{cocktail["name"]} has invalid liquid ingredient: #{item["ingredient"]}"
        end
        if !materials["volumes"].include? item["volume"]
          puts "#{cocktail["name"]} has invalid volume: #{item["volume"]}"
        end
      end
    end
    if ![true, false].include? cocktail["shaken"]
      puts "#{cocktail["name"]} has non-boolean for shaken"
    end
    for garnish in cocktail["garnish"]
      if !materials["garnishes"].include? garnish
        puts "#{cocktail["name"]} has invalid garnish: #{garnish}"
      end
    end
  end
end

def generate_mixing_sequence(cocktail)
  out = []

  staging = []
  staging << (cocktail["glass"] + " glass")
  if !cocktail["rim"].nil?
    staging << (cocktail["rim"] + " rim")
  end
  if cocktail["ice"]
    staging << "ice"
  end

  if !cocktail["shaken"]
    out += staging
  else
    out << "shaker"
  end

  ingredients_sequence = []
  top = nil
  for item in cocktail["ingredients"]
    if item["volume"].nil?
      ingredients_sequence << item["ingredient"]
    elsif item["volume"] == "top"
      top = item["ingredient"]
    else
      ingredients_sequence << "#{item["volume"]} ml #{item["ingredient"]}"
    end
  end
  if cocktail["shaken"]
    out << ingredients_sequence
    out << "shake"
    out += staging
    out << "pour"
  else
    out += ingredients_sequence
  end
  if !top.nil?
    out << ("top off with " + top)
  end

  out << cocktail["garnish"] << "serve"
end

def play_mixing_sequence(seq)
  helps = 0

  for item in seq
    if item.class == Array
      while item.length > 0
        input = gets().chomp
        if item.include? input
          item.delete(input)
        elsif input == "help"
          puts item.inspect
          helps += item.length
        else
          puts "Try again!"
        end
      end
    elsif item.class == String
      input = gets().chomp
      while input != item
        if input == "help"
          puts item
          helps += 1
        else
          puts "Try again!"
        end
        input = gets().chomp
      end
    else
      puts "Invalid sequence element: #{item}"
    end
  end

  return helps
end

def quiz(cocktail_list, trials)
  helps = 0
  start_time = Time.now.to_i

  for i in 1..trials
    n = rand(cocktail_list.length-1)
    puts cocktail_list[n]["name"]
    puts ''
    seq = generate_mixing_sequence(cocktail_list[n])
    helps += play_mixing_sequence(seq)
    puts ''
  end

  elapsed = Time.now.to_i - start_time

  puts "Asked for help #{helps} times."
  puts "#{elapsed} seconds elapsed."

  score = 75 - (helps*5 + elapsed)/trials

  puts "Your final score is #{score}."
end

validate(materials, cocktail_list)
quiz(cocktail_list, 3)
