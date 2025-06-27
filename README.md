# 📅 SI Scheduler

A scheduling system built with Elixir to assign Supplemental Instruction (SI) sessions to workers based on availability, preferences, and room constraints.

---

## 📁 File & Module Structure

**`sischeduler/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;**`room_manager/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Struct: `Room` <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Module: `RoomManager` <br>
&nbsp;&nbsp;&nbsp;&nbsp;**`worker_manager/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Struct: `Worker` <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Module: `WorkerManager` <br>
&nbsp;&nbsp;&nbsp;&nbsp;**`scheduler/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Struct: `Schedule` <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Module: `Scheduler` <br>
&nbsp;&nbsp;&nbsp;&nbsp;**`time_ops/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Module: `TimeOps` <br>
&nbsp;&nbsp;&nbsp;&nbsp;**`sort/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Module: `Sort` <br>
&nbsp;&nbsp;&nbsp;&nbsp;**`export/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• Module: `Exporter` <br>
**`test/`** <br>

**`data/`** <br>
&nbsp;&nbsp;&nbsp;&nbsp;• `workers/` <br>
&nbsp;&nbsp;&nbsp;&nbsp;• `rooms/` <br>

---

## 📦 Dependencies

This project uses [`jason`](https://hex.pm/packages/jason) for JSON parsing.
This project uses [`elixlsx`(https://hex.pm/packages/elixlsx) for Excel output

### In `mix.exs`:

```elixir```
defp deps do
  [
    {:jason, "~> 1.4"}
    {:elixlsx, "~> 0.4.2"}
  ]
end
---

## Run Code:
To run the code, ensure you're in the correct directory, i.e., the si_scheduler folder in the repo <br>
Run `mix deps.get` to install the dependencies for the program. Type in the command `mix` in the terminal <br>
and the program should run as advertised!


