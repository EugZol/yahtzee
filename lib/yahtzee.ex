defmodule Yahtzee do
  @moduledoc """
    Implements Yahtzee game
  """

  @doc """
  Counts score for "x of a kind" (3, 4, 5) with given dice combination

  ## Examples

      iex> Yahtzee.count_combination_x_of_a_kind([1, 1, 1, 2, 3], 3)
      8

      iex> Yahtzee.count_combination_x_of_a_kind([1, 1, 1, 2, 3], 4)
      0

      iex> Yahtzee.count_combination_x_of_a_kind([3, 3, 3, 3, 3], 5) # This is Yahtzee
      50

  """
  def count_combination_x_of_a_kind(dice, x) when x in (3..5) do
    available = dice
      |> Enum.group_by(&(&1))
      |> Enum.map(fn {_, v} -> length(v) >= x end)
      |> Enum.any?
    if available do
      if x == 5 do
        50
      else
        Enum.sum(dice)
      end
    else
      0
    end
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
    Enum.filter(dice, &(&1 == x)) |> Enum.sum
  end

  def count_combination(dice, :ones), do: count_combination(dice, 1)
  def count_combination(dice, :twos), do: count_combination(dice, 2)
  def count_combination(dice, :threes), do: count_combination(dice, 3)
  def count_combination(dice, :fours), do: count_combination(dice, 4)
  def count_combination(dice, :fives), do: count_combination(dice, 5)
  def count_combination(dice, :sixes), do: count_combination(dice, 6)

  def count_combination(dice, :three_of_a_kind), do: count_combination_x_of_a_kind(dice, 3)
  def count_combination(dice, :four_of_a_kind), do: count_combination_x_of_a_kind(dice, 4)
  def count_combination(dice, :yahtzee), do: count_combination_x_of_a_kind(dice, 5)

  def count_combination(dice, :full_house) do
    group_lengths = dice
      |> Enum.group_by(&(&1))
      |> Enum.map(fn {_, v} -> length(v) end)
      |> Enum.sort
    if group_lengths == [2, 3] do
      25
    else
      0
    end
  end

  def count_combination(dice, :small_straight) do
    leftovers = [1, 2, 3, 4, 5, 6] -- dice
    if Enum.member?([[1, 2], [1, 6], [5, 6]], leftovers) do
      30
    else
      0
    end
  end

  def count_combination(dice, :large_straight) do
    leftovers = [1, 2, 3, 4, 5, 6] -- dice
    if Enum.member?([[1], [6]], leftovers) do
      40
    else
      0
    end
  end

  def count_combination(dice, :chance), do: Enum.sum(dice)
end
