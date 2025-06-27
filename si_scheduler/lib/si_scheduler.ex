defmodule SIScheduler do
  @moduledoc """
  The central hub for the scheduling app. Is what gets ran
  when the program begins. Has one function called start that intiates the scheduling
  """
  use Application
  alias SIScheduler.WorkerManager
  alias SIScheduler.RoomManager
  alias SIScheduler.TimeOps
  alias SIScheduler.Sort
  alias SIScheduler.Scheduler
  alias SIScheduler.Exporter

  def start(_type, _args) do
    # produce lists of worker and room structs
    workers = WorkerManager.processJsonConcurrent()
    rooms = RoomManager.processJson()

    # Extract unavailable times from all workers
    unavailable_times_workers = Enum.map(workers, fn worker -> worker.unavailable end)
    available_times_rooms = Enum.map(rooms, fn room -> room.available end)

    # Convert unavailable worker times and available room times to time structs
    timeWorker = TimeOps.strTimesToTime(unavailable_times_workers)
    timeRoom = TimeOps.strTimesToTime(available_times_rooms)

    # update the different workers and rooms with the new format of times
    # "iterate" through the workers and the respective times
    updated_workers =
      Enum.zip(workers, timeWorker)

      # map each worker with its updated time format
      |> Enum.map(fn {worker, new_unavail} ->
        %SIScheduler.Worker{
          worker
          | unavailable: new_unavail
        }
      end)

    # same as above
    updated_rooms =
      Enum.zip(rooms, timeRoom)
      |> Enum.map(fn {room, new_avail} ->
        %SIScheduler.Room{
          room
          | available: new_avail
        }
      end)

    # sort workers (based on most restrictive)
    sorted_workers = Sort.sort(updated_workers)

    # get a list of all of the room names
    room_names = Enum.reduce(updated_rooms, [], fn room, acc -> [room.room | acc] end)

    # build the schedule
    schedule = Scheduler.schedule(sorted_workers, updated_rooms)

    # covert schedule into a list of row for an excel file and write the excel file
    rows = Scheduler.build_schedule_table(schedule, room_names)
    Exporter.export_real_xlsx(rows, room_names)

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
