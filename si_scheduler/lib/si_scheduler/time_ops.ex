defmodule SIScheduler.TimeOps do
  # Converts a list of maps with string time ranges to a list of maps with Time structs
  # Example input: [%{mon: [["10:00", "10:50"]], ...}]
  # Example output: [%{mon: [{~T[10:00:00], ~T[10:50:00]}], ...}]
  # Each time range is converted from a string format to a Time struct format
  def strTimesToTime(timeList) do
    # Parse the time strings in the nested map structure
    Enum.map(timeList, fn day_map ->
      day_map
      |> Enum.map(fn {day, times} ->
        {day,
         Enum.map(times, fn [start_time, end_time] ->
           {
             normalize_time(start_time) |> Time.from_iso8601!(),
             normalize_time(end_time) |> Time.from_iso8601!()
           }
         end)}
      end)
      # Convert to map
      |> Enum.into(%{})
    end)
  end

  defp normalize_time(time_str) do
    # Append ":00" for seconds
    if String.length(time_str) == 5 do
      time_str <> ":00"
    else
      time_str
    end
  end

  # Checks if two time ranges overlap
  # Example input: {~T[10:00:00], ~T[11:00:00]}, {~T[10:30:00], ~T[11:30:00]}
  # Example output: true (they overlap)
  def overlap({s1, e1}, {s2, e2}) do
    # Compare two time struct tuples to check for overlap
    not (Time.compare(e1, s2) == :lt or Time.compare(s1, e2) == :gt)
  end
end
