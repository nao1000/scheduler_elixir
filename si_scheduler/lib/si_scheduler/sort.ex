defmodule SIScheduler.Sort do
  @moduledoc """
  Provides functions to compare and sort workers by the number of unavailable slots.
  """

  alias SIScheduler.Worker

  @doc """
  Compare two %Worker{} structs by their total unavailable slots.

  Returns:
    - `1` if worker a has more unavailable slots than worker b
    - `-1` if worker a has fewer unavailable slots than worker b
    - `0` if both have the same number of unavailable slots
  """
  def compare(%Worker{unavailable: ua}, %Worker{unavailable: ub}) do
    count_a = count_slots(ua)
    count_b = count_slots(ub)

    cond do
      count_a > count_b -> 1
      count_a < count_b -> -1
      true -> 0
    end
  end

  # Helper: count all unavailable time slots across all days
  defp count_slots(unavailable) do
    unavailable
    |> Map.values()
    |> Enum.flat_map(& &1)
    |> length()
  end

  @doc """
  Sort a list of %Worker{} structs in descending order of unavailable slots.
  Uses Elixir's built-in Enum.sort/2 with the compare/2 function.
  """
  def sort(workers) when is_list(workers) do
    Enum.sort(workers, fn a, b ->
      # If compare returns 1, a has more slots and should come before b
      compare(a, b) == 1
    end)
  end
end
