defmodule Yahtzee do
  @moduledoc "Implements Yahtzee game"

  @combinations [
    ones:            {"1", "Ones"},
    twos:            {"2", "Twos"},
    threes:          {"3", "Threes"},
    fours:           {"4", "Fours"},
    fives:           {"5", "Fives"},
    sixes:           {"6", "Sixes"},
    three_of_a_kind: {"t", "Three Of A Kind"},
    four_of_a_kind:  {"f", "Four Of A Kind"},
    yahtzee:         {"y", "Yahtzee"},
    full_house:      {"f", "Full House"},
    small_straight:  {"s", "Small Straight"},
    large_straight:  {"l", "Large Straight"},
    chance:          {"?", "Chance"}
  ]
  def combinations, do: @combinations

  @combination_symbols (for {k, _} <- @combinations, do: k)
  def combination_symbols, do: @combinations

  @number_of_rolls 3

  def x_of_a_kind_available(dice, x) do
    dice
    |> Enum.group_by(&(&1))
    |> Enum.map(fn {_, v} -> length(v) >= x end)
    |> Enum.any?
  end

  @doc """
  Counts score for "x of a kind" (3, 4, 5) with given dice combination

  ## Examples

      iex> Yahtzee.count_combination_x_of_a_kind([1, 1, 1, 2, 3], 3)
      8

      iex> Yahtzee.count_combination_x_of_a_kind([1, 1, 1, 2, 3], 4)
      0

  """
  def count_combination_x_of_a_kind(dice, x) when x in (3..4) do
    if x_of_a_kind_available(dice, x), do: Enum.sum(dice), else: 0
  end

  @doc """
  Counts score for the named combination with given dice combination

  ## Examples

  ### Upper section — return sum of dice with given number

      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], 1)
      3
      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], :ones)
      3

      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], 2)
      2
      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], :twos)
      2

      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], 3)
      3
      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], :threes)
      3

      iex> Yahtzee.count_combination([5, 1, 1, 2, 3], 4)
      0
      iex> Yahtzee.count_combination([5, 1, 1, 2, 3], :fours)
      0

      iex> Yahtzee.count_combination([5, 1, 1, 2, 3], 5)
      5
      iex> Yahtzee.count_combination([5, 1, 1, 2, 3], :fives)
      5

  ### Lower section

  Three of a kind — returns sum of all dice if there are 3 of a kind, or 0 otherwise

      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], :three_of_a_kind)
      8
      iex> Yahtzee.count_combination([1, 2, 3, 4, 5], :three_of_a_kind)
      0

  Four of a kind — returns sum of all dice if there are 4 of a kind, or 0 otherwise

      iex> Yahtzee.count_combination([3, 3, 3, 2, 3], :four_of_a_kind)
      14
      iex> Yahtzee.count_combination([3, 3, 3, 2, 4], :four_of_a_kind)
      0

  Yahtzee — returns 50 if there are 5 of a kind, or 0 otherwise

      iex> Yahtzee.count_combination([1, 1, 1, 1, 1], :yahtzee)
      50
      iex> Yahtzee.count_combination([1, 1, 1, 1, 2], :yahtzee)
      0

  Full house — returns 25 if there are three of one number and two of another, otherwise 0

      iex> Yahtzee.count_combination([1, 1, 1, 2, 2], :full_house)
      25
      iex> Yahtzee.count_combination([1, 1, 1, 2, 3], :full_house)
      0

  Small straight — returns 30 if there are four sequential dice, otherwise 0

      iex> Yahtzee.count_combination([2, 1, 3, 4, 4], :small_straight)
      30
      iex> Yahtzee.count_combination([3, 1, 3, 4, 4], :small_straight)
      0

  Large straight — returns 40 if there are five sequential dice, otherwise 0

      iex> Yahtzee.count_combination([2, 1, 3, 4, 5], :large_straight)
      40
      iex> Yahtzee.count_combination([2, 1, 3, 4, 1], :large_straight)
      0

  Chance — returns the sum of all dice

      iex> Yahtzee.count_combination([2, 1, 3, 4, 5], :chance)
      15

  """
  def count_combination(dice, x) when x in (1..6) do
    dice
    |> Enum.filter(&(&1 == x))
    |> Enum.sum
  end

  def count_combination(dice, :ones), do: count_combination(dice, 1)
  def count_combination(dice, :twos), do: count_combination(dice, 2)
  def count_combination(dice, :threes), do: count_combination(dice, 3)
  def count_combination(dice, :fours), do: count_combination(dice, 4)
  def count_combination(dice, :fives), do: count_combination(dice, 5)
  def count_combination(dice, :sixes), do: count_combination(dice, 6)

  def count_combination(dice, :three_of_a_kind), do: count_combination_x_of_a_kind(dice, 3)
  def count_combination(dice, :four_of_a_kind), do: count_combination_x_of_a_kind(dice, 4)

  def count_combination(dice, :yahtzee) do
    if x_of_a_kind_available(dice, 5), do: 50, else: 0
  end

  def count_combination(dice, :full_house) do
    group_lengths =
      dice
      |> Enum.group_by(&(&1))
      |> Enum.map(fn {_, v} -> length(v) end)
      |> Enum.sort

    if group_lengths == [2, 3], do: 25, else: 0
  end

  def count_combination(dice, :small_straight) do
    leftovers = [1, 2, 3, 4, 5, 6] -- dice
    if leftovers in [[1, 2], [1, 6], [5, 6]], do: 30, else: 0
  end

  def count_combination(dice, :large_straight) do
    leftovers = [1, 2, 3, 4, 5, 6] -- dice
    if leftovers in [[1], [6]], do: 40, else: 0
  end

  def count_combination(dice, :chance), do: Enum.sum(dice)

  def roll_die, do: :rand.uniform(6)

  @doc """
  Merges into state number of points for given combination

  ## Examples

      iex> Yahtzee.update_state(%{}, [1, 1, 1, 2, 3], :ones)
      %{ones: 3}

      iex> Yahtzee.update_state(%{twos: 2}, [1, 1, 1, 2, 3], :ones)
      %{ones: 3, twos: 2}
  """
  def update_state(state, dice, combination) do
    Map.merge(state, %{combination => count_combination(dice, combination)})
  end

  @doc """
  Returns if the state contains all combinations

  ## Examples

      iex> Yahtzee.game_over?(%{ones: 1})
      false

  """
  def game_over?(state) do
    @combination_symbols -- Map.keys(state) == []
  end

  def next_round(state) do
    cond do
      game_over?(state) ->
        Yahtzee.Interactor.print_end_result(state)
      true ->
        state = next_roll(state, @number_of_rolls, Enum.to_list((0..4)), Enum.to_list((0..4)))
    end
  end

  def next_roll(state, throws_left, dice, to_reroll) when length(to_reroll) > 0 do
    # dice: [1, 2, 2, 3, 4]
    # to_reroll: [1, 2]
    # result: [rand, rand, 2, 3, 4]

    dice =
      dice
      |> Stream.with_index
      |> Enum.reduce([],
        fn({x, i}, list) ->
          element = if i in to_reroll, do: roll_die, else: x
          list ++ [element]
        end
      )
    next_roll(state, throws_left - 1, dice, [])
  end

  def next_roll(state, 0, dice, []) do
    combination = Yahtzee.Interactor.ask_combination(state, dice)
    next_round(update_state(state, dice, combination))
  end

  def next_roll(state, throws_left, dice, []) do
    # interactor should:
    # 1. Show current roll
    # 2. Show available combinations
    # 3. Ask which dice to reroll
    # 4. Return array of dice which weren't rerolled
    to_reroll = Yahtzee.Interactor.ask_which_to_reroll(state, throws_left, dice)

    next_roll(state, throws_left, dice, to_reroll)
  end

  @doc "Starts the game"
  def start do
    next_round %{}
  end
end
