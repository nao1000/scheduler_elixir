defmodule TimeOpsTest do
  use ExUnit.Case
  alias SIScheduler.TimeOps

  describe "strTimesToTime/1" do
    test "converts string times to Time structs" do
      input = [
        %{
          mon: [["10:00", "10:50"]],
          tues: [["13:00", "13:50"]],
          wed: [["09:00", "09:50"]],
          thur: [["12:00", "12:50"]],
          fri: [["14:00", "14:50"]],
          sat: [["08:00", "08:50"]],
          sun: []
        }
      ]

      expected = [
        %{
          mon: [{~T[10:00:00], ~T[10:50:00]}],
          tues: [{~T[13:00:00], ~T[13:50:00]}],
          wed: [{~T[09:00:00], ~T[09:50:00]}],
          thur: [{~T[12:00:00], ~T[12:50:00]}],
          fri: [{~T[14:00:00], ~T[14:50:00]}],
          sat: [{~T[08:00:00], ~T[08:50:00]}],
          sun: []
        }
      ]

      assert TimeOps.strTimesToTime(input) == expected
    end

    test "handles empty unavailable times" do
      input = []
      assert TimeOps.strTimesToTime(input) == []
    end

    test "handles a mix of empty and non-empty days" do
      input = [%{mon: [["10:00", "11:00"]], tues: [], wed: [["09:00", "10:00"]]}]

      expected = [
        %{mon: [{~T[10:00:00], ~T[11:00:00]}], tues: [], wed: [{~T[09:00:00], ~T[10:00:00]}]}
      ]

      assert TimeOps.strTimesToTime(input) == expected
    end

    test "raises an error for invalid time strings" do
      input = [%{mon: [["invalid", "11:00"]]}]
      assert_raise ArgumentError, fn -> TimeOps.strTimesToTime(input) end
    end

    test "handles an empty map" do
      input = []
      assert TimeOps.strTimesToTime(input) == []
    end
  end

  describe "overlap/1" do
    test "returns true for overlapping time ranges" do
      range1 = {~T[10:00:00], ~T[11:00:00]}
      range2 = {~T[10:30:00], ~T[11:30:00]}
      assert TimeOps.overlap(range1, range2) == true
    end

    test "returns false for non-overlapping time ranges" do
      range1 = {~T[10:00:00], ~T[11:00:00]}
      range2 = {~T[11:01:00], ~T[12:00:00]}
      assert TimeOps.overlap(range1, range2) == false
    end

    test "returns true for touching time ranges" do
      range1 = {~T[10:00:00], ~T[11:00:00]}
      range2 = {~T[11:00:00], ~T[12:00:00]}
      assert TimeOps.overlap(range1, range2) == true
    end
  end

  describe "overlap/2" do
    test "returns true for identical time ranges" do
      range1 = {~T[10:00:00], ~T[11:00:00]}
      range2 = {~T[10:00:00], ~T[11:00:00]}
      assert TimeOps.overlap(range1, range2) == true
    end

    test "returns false for completely disjoint time ranges" do
      range1 = {~T[08:00:00], ~T[09:00:00]}
      range2 = {~T[10:00:00], ~T[11:00:00]}
      assert TimeOps.overlap(range1, range2) == false
    end

    test "returns true when one range is fully contained within another" do
      range1 = {~T[09:00:00], ~T[12:00:00]}
      range2 = {~T[10:00:00], ~T[11:00:00]}
      assert TimeOps.overlap(range1, range2) == true
    end

    test "handles invalid input gracefully" do
      assert_raise FunctionClauseError, fn ->
        # gives a type error if you just pass in nil, has to conform with spec
        TimeOps.overlap({nil, nil}, {~T[10:00:00], ~T[11:00:00]})
      end
    end
  end
end
