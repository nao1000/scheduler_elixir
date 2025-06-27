defmodule SIScheduler.Worker do
  # name: name of worker
  # unavailable: fixed unavailability for worker
  # scheduled: new times for worker
  # preferences: preferred times and location if possible

  defstruct [:name, :unavailable, :scheduled, :preferences]
end

defmodule SIScheduler.WorkerManager do
  # WorkerManager is the processor for the Worker structs
  alias SIScheduler.TimeOps

  # concurrent version of JSON processing
  def processJsonConcurrent do
    keys = ["mon", "tues", "wed", "thur", "fri", "sat", "sun"]

    # Get list of file paths
    paths =
      "data/workers"
      |> File.ls!()
      |> Enum.map(&Path.join("data/workers", &1))

    # Concurrently read and decode JSON files
    read_jsons =
      paths

      # different processes read in the files
      |> Task.async_stream(
        fn path ->
          # IO is to demonstrate the different processes
          IO.puts("[#{inspect(self())}] Starting #{path}")

          with {:ok, body} <- File.read(path),
               {:ok, worker} <- Jason.decode(body) do
            worker
          else
            error -> IO.inspect(error, label: "Error reading #{path}")
          end
        end,
        max_concurrency: System.schedulers_online(),
        timeout: 5000
      )
      |> Enum.filter(fn
        {:ok, _worker} -> true
        _ -> false
      end)
      |> Enum.map(fn {:ok, worker} -> worker end)

    # converts the opened JSONs into the worker structs
    convertToStructs(keys, read_jsons)
  end

  # helper function that converts a list of json contents into a list of worker structs
  defp convertToStructs(keys, read_jsons) do
    Enum.map(read_jsons, fn worker ->
      %SIScheduler.Worker{
        name: worker["name"],
        unavailable:
          Enum.reduce(keys, %{}, fn day, acc ->
            Map.put(acc, String.to_atom(day), worker["unavailable"][day])
          end),
        scheduled:
          Enum.reduce(keys, %{}, fn day, acc ->
            Map.put(acc, String.to_atom(day), [])
          end),
        preferences: []
      }
    end)
  end

  # Sequential Version of the processing -- unusused
  # def processJsonSeq do
  #   # processJson reads in a set of JSON files from directory converting each
  #   # worker json file into a worker struct for the program to use

  #   # feed in directory string to ls command
  #   read_jsons =
  #     "data/workers"
  #     |> File.ls!()

  #     # map takes each JSON, opening it up, and saving its content to the list
  #     |> Enum.map(fn filename ->
  #       path = Path.join("data/workers", filename)
  #       IO.puts("[#{inspect(self())}] Starting #{path}")

  #       with {:ok, body} <- File.read(path),
  #            {:ok, worker} <- Jason.decode(body) do
  #         worker
  #       else
  #         error -> IO.inspect(error, label: "Error reading #{filename}")
  #       end
  #     end)

  #   # strings of the days (keys) -- will be converted to atoms
  #   keys = ["mon", "tues", "wed", "thur", "fri", "sat", "sun"]

  #   # for each worker in the jsons list, create the worker struct
  #   workers_list =
  #     for worker <- read_jsons,
  #         do: %SIScheduler.Worker{
  #           name: worker["name"],
  #           # like SMLs List.map
  #           # "iterate" through the keys, creating a map of their unavailability
  #           unavailable:
  #             Enum.reduce(keys, %{}, fn day, acc ->
  #               Map.put(acc, String.to_atom(day), worker["unavailable"][day])
  #             end),

  #           # creates empty lists for scheduled as well
  #           scheduled:
  #             Enum.reduce(keys, %{}, fn day, acc -> Map.put(acc, String.to_atom(day), []) end),
  #           preferences: []
  #         }

  #   workers_list
  # end

  def isUnavailable(worker, day, time) do
    # This function determines if the worker is available or not on a given day at a given time

    Enum.any?(worker.unavailable[day], fn u_time -> TimeOps.overlap(u_time, time) end)
  end
end
