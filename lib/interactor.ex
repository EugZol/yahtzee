defmodule Yahtzee.Interactor do
  @one """
  |   |
  | o |
  |   |
  """

  @two """
  |o  |
  |   |
  |  o|
  """

  @three """
  |o  |
  | o |
  |  o|
  """

  @four """
  |o o|
  |   |
  |o o|
  """

  @five """
  |o o|
  | o |
  |o o|
  """

  @six """
  |o o|
  |o o|
  |o o|
  """

  @dice [@one, @two, @three, @four, @five, @six]
    |> Enum.map(fn(x) -> String.split(x, "\n") end)

  def ask_which_to_reroll(state, throws_left, dice) do
    IO.ANSI.clear
    print_result(state)
    IO.puts dice_to_string(dice)

    IO.puts "#{throws_left} throws left"
    IO.gets("Write dice numbers to reroll, separated by space\n")
      |> String.strip
      |> String.split(" ")
      |> Enum.map(fn(x) ->
          if x == "" do
            nil
          else
            String.to_integer(x) - 1
          end
        end)
      |> Enum.filter(&(&1))
  end

  def ask_combination(state, dice) do
    # TODO: add shortcuts
    # {"1" => :ones, "2" => :twos, "3" => :threes,
    # "4" => :fours, "5" => :fives, "6" => :sixes,
    # "s" => :small_straight, "l" => :large_straight,
    # "t" => :three_of_a_kind, "f" => :four_of_a_kind,
    # "h" => :full_house, "y" => :yahtzee, "?" => :chance}

    print_result(state)
    IO.puts dice_to_string(dice)
    result = IO.gets("Select combination\n")
      |> String.strip
      |> String.to_atom
    cond do
      !Enum.member?(Yahtzee.combinations, result) ->
        IO.puts "Wrong combination name!"
        ask_combination(state, dice)
      state[result] ->
        IO.puts "Combination is already taken"
      true ->
        result
    end
  end

  def print_result(state) do
    IO.puts "Current score:"
    Yahtzee.combinations
      |> Enum.map(
        fn(x) ->
          "#{x}\t\t#{state[x]}"
        end
      )
      |> Enum.join("\n")
      |> IO.puts
  end

  def print_end_result(state) do
    IO.puts "Game over"
    print_result(state)
  end

  @doc """
  Returns string representation of dice

  ## Examples

      iex> Yahtzee.Interactor.dice_to_string([1, 2, 1, 2, 1])
      ~s\"\"\"
       ---   ---   ---   ---   ---
      |   | |o  | |   | |o  | |   |
      | o | |   | | o | |   | | o |
      |   | |  o| |   | |  o| |   |
       ---   ---   ---   ---   ---
        1     2     3     4     5
      \"\"\"

  """
  def dice_to_string(dice) do
    result =
      (0..2)
      |> Enum.map(
        fn(i) ->
          dice
            |> Enum.map(fn(x) ->
                 (@dice |> Enum.at(x-1) |> Enum.at(i))
               end)
            |> Enum.join(" ")
        end
      )
      |> Enum.join("\n")

    border = " ---   ---   ---   ---   ---\n"
    dice_numbers = "  1     2     3     4     5\n"
    border <> result <> "\n" <> border <> dice_numbers
  end
end
