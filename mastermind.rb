#to hide codemakers code input
require 'io/console'

class Codemaker
  def initialize(player)
    @player = player
  end

  def choose_pattern
    @player.pattern
  end
end

class Codebreaker
  def initialize(player)
    @player = player
  end

  def choose_guess(respon,last)
    @player.guess(respon,last)
  end
end

class Computer

  def pattern
    code = Array.new
    4.times do
      code << CodePeg.colors.at(rand(6))
    end
    code.each do |x|
      CodePeg.new(x)
    end
  end

  def guess(respon,last)
    if respon == nil
      pattern
    elsif respon.empty?
      pattern
    else
      analyze(respon,last)
    end

  end

  def analyze(respon,last)
    code = Array.new
    track = Array.new
    respon.each do |x|
      if x == "B"
        #keep random peg n position in previous codepeg
        #add to prospective new guess codepeg
        keep = random_slot(track)
        track.push(keep)

        code[keep] = last[keep]
      elsif x == "W"
        #keep random peg color but change to random position
        #also add to prospective
        keep2 = random_slot(track)
        track.push(keep2)
        keep3 = random_slot(track)
        code[keep2] = last[keep3]
      end
    end

    4.times do |y|
      #generate random peg for open code slot
      unless track.include? y
        code[y] = CodePeg.colors.at(rand(6))
        track.push(y)
      end
    end

    code.each do |x|
      CodePeg.new(x)
    end
  end

  def random_slot(track)
    num = rand(0..3)
    while track.include? num && track.length < 4
      num = rand(0..3)
    end
    return num
  end
end

class Human
  def pattern
    puts "Codemaker, Enter the 4 slotted code you want to create. "
    puts "R = Red, G = Green, B = Blue, C = Cyan, Y = Yellow, M = Magenta, _ = Blank Space"
    puts "Example: RRCY"
    code = STDIN.noecho {|i| i.gets}.chomp.upcase.split(//).to_a
    code.each do |x|
      CodePeg.new(x)
    end
  end
  def guess(respon,last)
    puts "R = Red, G = Green, B = Blue, C = Cyan, Y = Yellow, M = Magenta, _ = Blank Space"
    puts "Example: RRCY"
    puts "Enter your code guess:"
    code_guess = gets.chomp.upcase.split(//)
    code_guess.each do |x|
      CodePeg.new(x)
    end
  end
end

class CodePeg
  @@colors = Array["R","G","_","B","C","M","Y"]

  def initialize(color)
    @color = color
    check_peg
  end

  def check_peg
    if @@colors.include? @color
      @color
    # else
    #   abort("Color not included.")
    end
  end

  def self.colors
    @@colors
  end
end

class KeyPeg
  @@keys = Array["B","W"]

  def initialize(key)
    @key = key
  end
end

class Board
  attr_accessor :shield, :coderows, :keyrows

  def initialize
    @shield = Array.new(4, " # ")
    @coderows = Array.new(Game.CHANCES) { Array.new(4) }
    @keyrows = Array.new(Game.CHANCES) { Array.new(4) }
  end

  def set_coderow(guess, row)
    @coderows[row] = guess
  end

  def set_keyrow(feedback, row)
    @keyrows[row] = feedback
  end

  def get_keyrow(row)
    if row == 0
      nil
    else
      @keyrows[row-1]
    end
  end

  def get_coderow(row)
    if row == 0
      nil
    else
      @coderows[row-1]
    end
  end

  def display(turns)
    puts "    Codebreaker Guess  |  Codemaker Response "
    count = turns + 1
    count.times do |x|
      puts "#{x+1}: #{@coderows[x]} #{@keyrows[x]}"
    end
  end

  def display_shield
    print "Shield:"
    @shield.each do |x|
      print "#{x}"
    end
    print "\n"
  end
end

class Game
  @@CHANCES = 12

  def initialize
    @board = Board.new
    welcome
  end

  def self.CHANCES
    @@CHANCES
  end

  def welcome
    puts "      ~Welcome to Mastermind~      "
    puts "                                   "
    start
  end


  def start
    @codemaker = choose_players(Codemaker)
    @codebreaker = choose_players(Codebreaker)
    play
  end

  def choose_players(player_type)
    puts "Will a human play as the #{player_type}? [Y/N]"
    who = gets.chomp.upcase
    if who == "Y"
      player_type.new(Human.new)
    elsif who == "N"
      player_type.new(Computer.new)
    else
      puts "Incorrect input"
      start
    end
  end

  def play
    @board.shield=(@codemaker.choose_pattern)
    take_turn
  end

  def take_turn
    #once a guess and feedback occurs, a turn is completed
    turns = 0
    while (turns < 12)
      @board.set_coderow(@codebreaker.choose_guess(@board.get_keyrow(turns),@board.get_coderow(turns)), turns)
      @board.set_keyrow(feedback(@board.coderows[turns],@board.shield), turns)
      @board.display(turns)
      if @board.coderows[turns] == @board.shield
        end_game("Codebreaker wins!")
      end
      turns += 1
    end

    if turns == 12
      end_game("Codebreaker loses! Codemaker wins!")
    end
  end


  def feedback(code_r, shield_r)
    #second check if any of each of the colors match,
    #first check if any slots are correct
    key_code = Array.new
    code = code_r.clone
    shield = shield_r.clone

    code.each_index do |x|
      if code[x] == shield[x]
        key_code << "B"
        code[x], shield[x] = nil
      end
    end

    code.each_index do |x|
      if code[x] != nil
        if shield.include? code[x]
          i = shield.find_index(code[x])
          key_code << "W"
          code[x], shield[i] = nil
        end
      end
    end

    key_code.each do |i|
      KeyPeg.new(i)
    end
  end

  def end_game(message)
    puts message
    @board.display_shield
    exit
  end

end

Game.new
