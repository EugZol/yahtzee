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

  @border " ---   ---   ---   ---   ---\n"
  @dice_numbers "  1     2     3     4     5\n"

  @dice [@one, @two, @three, @four, @five, @six]
        |> Enum.map(fn(x) -> String.split(x, "\n") end)

  @combination_strings (for {k, v} <- Yahtzee.combinations, into: [] do
                          {k, "(#{elem(v, 0)}) #{elem(v, 1)}"}
                        end)

  @combination_selections (for {k, v} <- Yahtzee.combinations, into: %{} do
                             {elem(v, 0), k}
                           end)

  def ask_which_to_reroll(state, throws_left, dice) do
    print_result(state)
    IO.puts dice_to_string(dice)
    IO.puts "#{throws_left} throws left"
    IO.puts "'=' to save all"

    reroll_input
  end

  @doc """
    Returns die as integer from string if that string is valid; otherwise nil

    ## Examples

        iex> Yahtzee.Interactor.parse_die_number("1")
        1

        iex> Yahtzee.Interactor.parse_die_number("")
        nil

        iex> Yahtzee.Interactor.parse_die_number("6")
        nil

        iex> Yahtzee.Interactor.parse_die_number("1asdf")
        1

  """
  def parse_die_number(die) do
    die = Integer.parse(die)
    case die do
      :error -> nil
      {i, _} -> if i in (1..5), do: i, else: nil
    end
  end

  def reroll_input do
    IO.gets("Write dice numbers to reroll, separated by space\n")
    |> reroll_input
  end

  def reroll_input("=" <> _), do: []

  def reroll_input(input) do
    # Homework:
    #   — Validate that numbers are unique
    #   — Parse two (or more) sequential spaces
    #   — Parse input without spaces, e.g. "123"

    parsed_numbers =
      input
      |> String.strip
      |> String.split(" ")
      |> Enum.map(&parse_die_number/1)

    if parsed_numbers |> Enum.all?(&(&1)) do
      parsed_numbers |> Enum.map(&(&1-1))
    else
      IO.puts("Wrong input. Try again")
      reroll_input
    end
  end

  def ask_combination(state, dice) do
    print_result(state)
    IO.puts dice_to_string(dice)

    input =
      IO.gets("Select combination\n")
      |> String.strip

    selected = @combination_selections[input]

    cond do
      !selected ->
        IO.puts "Wrong combination name!"
        ask_combination(state, dice)
      state[selected] ->
        IO.puts "Combination is already taken"
        ask_combination(state, dice)
      true ->
        selected
    end
  end

  def make_aligned_string(s, alignment) do
    "#{s}#{String.duplicate " ", alignment - String.length(s)}"
  end

  def print_result(state) do
    # Homework:
    #   — Print how many points for each combination user could get with given dice

    IO.puts String.duplicate("=", 26)
    IO.puts "Current score:"
    IO.puts String.duplicate("-", 26)

    make_score_string =
      fn {k, v} ->
        make_aligned_string(v, 20) <> "#{state[k]}"
      end


    @combination_strings
    |> Enum.map(make_score_string)
    |> Enum.join("\n")
    |> IO.puts

    IO.puts String.duplicate("-", 26)
    IO.puts make_aligned_string("Upper bonus:", 20) <> "#{state[:upper_bonus]}"
    IO.puts String.duplicate("-", 26)
    IO.puts make_aligned_string("Total:", 20) <> "#{state[:total]}"
    IO.puts String.duplicate("=", 26)
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
    draw_ith_string =
      fn i ->
        dice
        |> Enum.map(&(@dice |> Enum.at(&1-1) |> Enum.at(i)))
        |> Enum.join(" ")
      end

    result =
      (0..2)
      |> Enum.map(draw_ith_string)
      |> Enum.join("\n")

    @border <> result <> "\n" <> @border <> @dice_numbers
  end
end
