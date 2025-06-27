defmodule SIScheduler.Schedule do
  # This struct is for the overall schedule. It has fields for each day of the week
  defstruct [:mon, :tues, :wed, :thur, :fri, :sat, :sun]
end

defmodule SIScheduler.Booking do
  # This struct is for a specific booking

  # day: the day of the session
  # room: the location of the session
  # time: when the session is

  defstruct [:day, :room, :time]
end

defmodule SIScheduler.Scheduler do
  # This module houses the logic for the scheduling to occur
  alias SIScheduler.WorkerManager
  alias SIScheduler.Room

  def schedule(workers, rooms) do
    # workers - list of worker structs
    # rooms - list of room structs

    # initialize the schedule to be empty
    initial_schedule = %SIScheduler.Schedule{
      mon: %{},
      tues: %{},
      wed: %{},
      thur: %{},
      fri: %{},
      sat: %{},
      sun: %{}
    }

    # create a list of all of the room names
    room_names = Enum.map(rooms, & &1.room)

    # actual scheduling logic
    # iterate through the workers keeping the schedule and the list of rooms as an accumalator
    {final_schedule, _final_rooms} =
      Enum.reduce(workers, {initial_schedule, rooms}, fn worker, {schedule_acc, rooms_acc} ->
        # to maintain only three sessions per worker
        count = 0

        # iterate through the room names, same accs but with count as well
        {worker_sched, _worker_count, updated_rooms} =
          Enum.reduce(room_names, {schedule_acc, count, rooms_acc}, fn room_name,
                                                                       {sched, cnt, room_list} ->
            # find the room struct in the list
            room = Enum.find(room_list, fn r -> r.room == room_name end)

            # iterate through the days
            {sched_out, cnt_out, room_list_out} =
              Enum.reduce(Map.keys(room.available), {sched, cnt, room_list}, fn day,
                                                                                {s_acc, c_acc,
                                                                                 r_acc} ->
                # if count is 3, we are done
                if c_acc == 3 do
                  {s_acc, c_acc, r_acc}
                else
                  # Fetch the freshest version of the room at this point
                  current_room = Enum.find(r_acc, fn r -> r.room == room_name end)
                  times = Map.get(current_room.available, day, [])

                  # now iterate through the room's available times for that day
                  Enum.reduce(times, {s_acc, c_acc, r_acc}, fn time,
                                                               {s_day_acc, c_day_acc, r_day_acc} ->
                    # elixir's beautifal if-elif-elif.... syntax
                    cond do
                      # if we have scheduled three sessions, skip
                      c_day_acc == 3 ->
                        {s_day_acc, c_day_acc, r_day_acc}

                      # if the worker is available AND not already working that day, schedule the session
                      not WorkerManager.isUnavailable(worker, day, time) and
                          not Map.has_key?(Map.get(s_day_acc, day), worker.name) ->
                        # new map for the day and time on the schedule
                        updated_day =
                          Map.put(
                            # get the map from the schdule and create the booking with the name as a key
                            Map.get(s_day_acc, day),
                            worker.name,
                            %SIScheduler.Booking{day: day, room: current_room.room, time: time}
                          )

                        # put the updated day's schedule back onto the schedule
                        new_sched = Map.put(s_day_acc, day, updated_day)

                        # Remove the time from the room’s availability
                        new_times = List.delete(current_room.available[day], time)
                        new_available = Map.put(current_room.available, day, new_times)
                        updated_room = %Room{current_room | available: new_available}

                        # Update room list
                        new_room_list =
                          [
                            updated_room
                            | Enum.reject(r_day_acc, fn r -> r.room == current_room.room end)
                          ]

                        {new_sched, c_day_acc + 1, new_room_list}

                      # otherise, just continue
                      true ->
                        {s_day_acc, c_day_acc, r_day_acc}
                    end
                  end)
                end
              end)

            {sched_out, cnt_out, room_list_out}
          end)

        {worker_sched, updated_rooms}
      end)

    final_schedule
  end

  def build_schedule_table(schedule, rooms) do
    # This function converts the schedule struct into a list of rows to be
    # written to an excel file

    # schedule - a filled out schedule struct
    # rooms - list of room names

    # days and times, basically creating the 9-5 for each day of the week
    days = [:mon, :tues, :wed, :thur, :fri, :sat, :sun]
    # 8:00, 9:00, ..., 5:00 PM
    times = for hour <- 8..17, do: {hour, 0}

    # for each day and time
    for day <- days, {hour, minute} <- times do
      # create the hour blocks
      time_start = ~T[00:00:00] |> Time.add(hour * 3600 + minute * 60)

      # for each room
      row_rooms =
        Enum.reduce(rooms, %{}, fn room_name, acc ->
          # find the booking for that time if it exists
          worker =
            schedule
            |> Map.get(day, %{})
            |> Enum.find(fn {_worker_name, booking} ->
              booking.room == room_name and booking.time |> elem(0) == time_start
            end)
            |> case do
              {worker_name, _booking} -> worker_name
              nil -> ""
            end

          # set it the room to a worker or ""
          Map.put(acc, room_name, worker)
        end)

      # a row
      %{
        day: day,
        time: time_start,
        rooms: row_rooms
      }
    end
  end
end
