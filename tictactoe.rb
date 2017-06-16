class Board
  def initialize
    @position = Hash.new
    (1..9).each do |x|
      @position[x] = "#{x}"
    end
  end

  def set_board(key,value)
    @position[key] = value
  end

  def get_board(key)
    @position[key]
  end

  def display_board
    puts "\n"
    @position.each do |x,y|
      print " #{y} "
      if x % 3 == 0
        puts "\n"
      end
    end
  end

end

class Player
  attr_reader :mark

  def initialize(mark)
    @mark = mark
  end

  def make_move(board,spot)
    board.set_board(spot, @mark)
  end
end

class Game
  def initialize
    @player_1 = Player.new("X")
    @player_2 = Player.new("O")
    @board = Board.new
  end
  private
  def winner?
    check_arry = Array.new
    possibilities_arry = Array[[1,2,3],[4,5,6],[7,8,9],[1,5,9],[3,5,7],[1,4,7],[2,5,8],[3,6,9]]

    possibilities_arry.each do |arr|
      arr.each do |key|
        check_arry << @board.get_board(key)
      end
      if check_arry.all? {|x| x == check_arry[0]}
        return true
      else
        check_arry.clear
      end
    end
    false
  end

  def turns
    turn = 0
    while turn < 9
      if turn % 2 == 0
        take_turn(@player_1)
      else
        take_turn(@player_2)
      end
      @board.display_board
      if winner?
        puts "We have a winner! The winner is Player #{winner_is(turn)}"
        end_game
      end
      turn += 1
    end
    if turn == 9
      puts "We have a draw!"
      end_game
    end
  end

  def winner_is(turn_number)
    if turn_number % 2 == 0
      @player_1.mark
    else
      @player_2.mark
    end
  end
  public
  def take_turn(player)
    puts "Player #{player.mark}'s turn..."
    spot = gets.chomp.to_i

    while ((1..9).include?(spot) == false) || (@board.get_board(spot) == "X" || @board.get_board(spot) == "O")
      puts "Incorrect input. Spot already taken or number 1-9 not selected."
      spot= gets.chomp.to_i
    end
    player.make_move(@board,spot)
  end

  def begin_game
    puts "\n Input the number of the grid location you want to mark."

    @board.display_board

    turns
  end

  def end_game
    puts "Would you like to play again? [Y/N]"
    play_again = gets.chomp.upcase

    until (play_again == "Y") || (play_again == "N")
      puts "Error: I only accept Y or N"
      play_again = gets.chomp.upcase
    end

    if play_again == "Y"
      game2 = Game.new
      game2.begin_game
    else
      puts "Well goodbye then!"
      exit
    end
  end
end

puts "Would you like to play a game of tic tac toe? [Y/N]"
new_game = gets.chomp.upcase

until (new_game == "Y") || (new_game == "N")
  puts "Error: I only accept Y or N"
  new_game = gets.chomp.upcase
end

if new_game == "Y"
  puts "Welcome to Tic Tac Toe. This game consists of a 3 X 3 grid using X's and O's representing each of the two players.  A winner is determined by the first individual to get their symbol (X or O), 3 in a row."
  game1 = Game.new
  game1.begin_game

elsif new_game == "N"
puts "Well goodbye then!"
exit
end
