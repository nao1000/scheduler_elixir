# This module has the logic of writing out the schedule to an excel file

defmodule SIScheduler.Exporter do
  alias Elixlsx.{Workbook, Sheet}

  # This function takes the converted rows and list of room names
  # and using the Elixlsx dependency, creates an excel file

  def export_real_xlsx(rows, room_names) do
    headers = ["Day", "Time" | room_names]

    # fitting each row to the row of the excel sheet and the respective columns
    content =
      [headers] ++
        Enum.map(rows, fn %{day: day, time: time, rooms: rooms} ->
          [
            Atom.to_string(day),
            Time.to_string(time)
            | Enum.map(room_names, fn room -> Map.get(rooms, room, "") end)
          ]
        end)

    sheet = %Sheet{name: "Schedule", rows: content}
    workbook = %Workbook{sheets: [sheet]}

    Elixlsx.write_to(
      workbook,
      "../schedule.xlsx"
    )
  end
end
