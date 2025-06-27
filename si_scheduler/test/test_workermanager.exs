defmodule SIScheduler.WorkerManagerTest do
  use ExUnit.Case, async: true

  alias SIScheduler.WorkerManager
  alias SIScheduler.Worker

  describe "processJsonConcurrent/0" do
    test "processes JSON files concurrently and returns a list of worker structs" do
      workers = WorkerManager.processJsonConcurrent()
      assert is_list(workers)
      assert Enum.all?(workers, fn worker -> is_struct(worker, Worker) end)
    end

    test "handles empty directory gracefully" do
      File.mkdir_p!("data/workers")
      File.rm_rf!("data/workers/*")
      workers = WorkerManager.processJsonConcurrent()
      assert workers == []
    end

    test "handles missing files gracefully" do
      # Ensure directory doesn't exist
      File.rm_rf!("data/workers")
      assert_raise File.Error, fn -> WorkerManager.processJsonConcurrent() end
    end

    test "handles invalid JSON structure" do
      File.mkdir_p!("data/workers")
      # Missing "unavailable" key
      File.write!("data/workers/invalid.json", ~s({"name": "worker1"}))
      workers = WorkerManager.processJsonConcurrent()
      assert workers == []
    end
  end

  describe "processJsonSeq/0" do
    test "processes JSON files sequentially and returns a list of worker structs" do
      workers = WorkerManager.processJsonSeq()
      assert is_list(workers)
      assert Enum.all?(workers, fn worker -> is_struct(worker, Worker) end)
    end

    test "handles invalid JSON files gracefully" do
      File.mkdir_p!("data/workers")
      File.write!("data/workers/invalid.json", "{invalid_json}")
      workers = WorkerManager.processJsonSeq()
      assert workers == []
    end

    test "handles missing files gracefully" do
      # Ensure directory doesn't exist
      File.rm_rf!("data/workers")
      assert_raise File.Error, fn -> WorkerManager.processJsonSeq() end
    end

    test "handles partially valid JSON files" do
      File.mkdir_p!("data/workers")
      File.write!("data/workers/valid.json", ~s({"name": "worker1", "unavailable": {"mon": []}}))
      File.write!("data/workers/invalid.json", "{invalid_json}")
      workers = WorkerManager.processJsonSeq()
      assert length(workers) == 1
      assert workers |> hd() |> Map.get(:name) == "worker1"
    end
  end

  describe "convertToStructs/2" do
    test "converts JSON data into worker structs" do
      keys = ["mon", "tues", "wed"]

      json_data = [
        %{
          "name" => "worker1",
          "unavailable" => %{"mon" => [], "tues" => [], "wed" => []}
        }
      ]

      workers = WorkerManager.send(:convertToStructs, keys, json_data)
      assert length(workers) == 1
      assert workers |> hd() |> Map.get(:name) == "worker1"
    end

    test "handles empty JSON data" do
      keys = ["mon", "tues", "wed"]
      workers = WorkerManager.send(:convertToStructs, keys, [])
      assert workers == []
    end
  end

  describe "isUnavailable/3" do
    setup do
      worker = %Worker{
        name: "test_worker",
        unavailable: %{
          mon: [%{start: ~T[09:00:00], end: ~T[11:00:00]}],
          tues: []
        },
        scheduled: %{},
        preferences: []
      }

      %{worker: worker}
    end

    test "returns true if the worker is unavailable at the given time", %{worker: worker} do
      assert WorkerManager.isUnavailable(worker, :mon, %{start: ~T[10:00:00], end: ~T[10:30:00]})
    end

    test "returns false if the worker is available at the given time", %{worker: worker} do
      refute WorkerManager.isUnavailable(worker, :mon, %{start: ~T[12:00:00], end: ~T[13:00:00]})
    end

    test "returns false if the worker has no unavailability for the given day", %{worker: worker} do
      refute WorkerManager.isUnavailable(worker, :tues, %{start: ~T[09:00:00], end: ~T[10:00:00]})
    end

    test "handles invalid time ranges gracefully", %{worker: worker} do
      refute WorkerManager.isUnavailable(worker, :mon, %{start: ~T[11:30:00], end: ~T[10:30:00]})
    end

    test "returns false for empty unavailable map" do
      worker = %Worker{name: "worker1", unavailable: %{}, scheduled: %{}, preferences: []}
      refute WorkerManager.isUnavailable(worker, :mon, %{start: ~T[09:00:00], end: ~T[10:00:00]})
    end

    test "handles overlapping time ranges" do
      worker = %Worker{
        name: "worker1",
        unavailable: %{
          mon: [%{start: ~T[09:00:00], end: ~T[11:00:00]}]
        },
        scheduled: %{},
        preferences: []
      }

      assert WorkerManager.isUnavailable(worker, :mon, %{start: ~T[10:30:00], end: ~T[12:00:00]})
    end
  end
end
