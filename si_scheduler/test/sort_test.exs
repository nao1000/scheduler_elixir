defmodule SchedulerSortTest do
  use ExUnit.Case, async: true

  alias SIScheduler.{Worker, Sort}

  defp make_worker(name, slots_per_day) do
    # build an unavailable map from a count
    keys = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]

    unavailable =
      keys
      |> Enum.map(fn day ->
        count = slots_per_day[day] || 0
        # duplicates exactly `count` entries; returns [] when count == 0
        slots = List.duplicate(["00:00", "00:30"], count)
        {day, slots}
      end)
      |> Enum.into(%{})

    %Worker{name: name, unavailable: unavailable}
  end

  describe "compare/2" do
    test "returns 1, 0, or -1 based on unavailable‑slot counts" do
      w_a = make_worker("A", %{mon: 1})
      w_b = make_worker("B", %{mon: 2})
      assert Sort.compare(w_a, w_b) == -1
      assert Sort.compare(w_b, w_a) == 1
      assert Sort.compare(w_a, w_a) == 0
    end
  end

  describe "sort/1" do
    test "orders workers descending by unavailable slots" do
      w1 = make_worker("Least", %{mon: 0})
      w2 = make_worker("Middle", %{mon: 1})
      w3 = make_worker("Most", %{mon: 3})

      sorted = Sort.sort([w2, w3, w1])
      assert Enum.map(sorted, & &1.name) == ["Most", "Middle", "Least"]
    end
  end
end
