defmodule SIScheduler.Room do
  @moduledoc """

  room: atom/string of the location
  scheduled: list of booked times for the room
  available: fixed availibilty for the room (notice it insn't unavailibility like the workers;
  this allows us to allocate times)
  """
  defstruct [:room, :scheduled, :available]
end

defmodule SIScheduler.RoomManager do
  @moduledoc """

  RoomManager is the processor for the Room structs
  """
  def processJson do
    IO.puts("Hello")
    # feed in dir string to ls command
    read_jsons =
      "data/rooms"
      |> File.ls!()

      # map takes each JSON, opening it up, and saving its contents
      |> Enum.map(fn filename ->
        path = Path.join("data/rooms", filename)

        with {:ok, body} <- File.read(path),
             {:ok, room} <- Jason.decode(body) do
          room
        else
          error -> IO.inspect(error, label: "Error reading #{filename}")
        end
      end)

    # strings of the days (keys) -- will be converted to atoms
    keys = ["mon", "tues", "wed", "thur", "fri", "sat", "sun"]

    # for each room in the jsons list, create the room struct
    convertToStructs(read_jsons, keys)
  end

  # convert the json content into room structs
  defp convertToStructs(read_jsons, keys) do
    # alt version to using Enum.map like in worker
    rooms_list =
      for room <- read_jsons,
          do: %SIScheduler.Room{
            room: room["room"],
            scheduled:
              Enum.reduce(keys, %{}, fn day, acc -> Map.put(acc, String.to_atom(day), []) end),
            # "iterate" through the keys, creating a map of their unavailability
            available:
              Enum.reduce(keys, %{}, fn day, acc ->
                Map.put(acc, String.to_atom(day), room["available"][day])
              end)
          }

    rooms_list
  end
end
