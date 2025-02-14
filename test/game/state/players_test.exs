defmodule Game.State.PlayersTest do
  use Game.DataCase, async: true

  alias Game.State.Players
  alias Game.State.Players.Player

  @id1 "random-id-1"
  @name1 "lorem ipsum 1"
  @id2 "random-id-2"
  @name2 "lorem ipsum 2"

  describe "players Agent is automatically started" do
    test "has a pid and is running" do
      pid = Process.whereis(Players)

      refute pid === nil

      assert Process.alive?(pid) === true
    end
  end

  describe "players state" do
    test "can list players" do
      Players.add(@id1, %{name: @name1})
      Players.add(@id2, %{name: @name2})

      player_list = Players.list()

      assert is_list(player_list)
      assert player_list |> Enum.find(&(&1.id === @id1))
      assert player_list |> Enum.find(&(&1.id === @id2))
    end

    test "add player returns added player" do
      assert %Player{id: @id1, name: @name1} = Players.add(@id1, %{name: @name1})
    end

    test "can set & unset action" do
      Players.add(@id1, %{name: @name1})

      Players.set_action(@id1, :up, true)
      assert %Player{actions: %{up: true}} = Players.get(@id1)

      Players.set_action(@id1, :up, false)
      assert %Player{actions: %{up: false}} = Players.get(@id1)
    end
  end

  describe "players tick" do
    test "update player positions" do
      Players.add(@id1, %{name: @name1})
      %{speed: speed} = Players.add(@id2, %{name: @name2})

      Players.set_action(@id2, :down, true)

      Players.tick([])

      assert %Player{x: 0, y: 0} = Players.get(@id1)
      assert %Player{x: 0, y: ^speed} = Players.get(@id2)
    end

    test "don't move if obstacle is in the way" do
      Players.add(@id1, %{name: @name1, y: 40})
      Players.add(@id2, %{name: @name2})

      Players.set_action(@id2, :down, true)

      Players.tick(Players.list())
      assert %Player{x: 0, y: 40} = Players.get(@id1)
      assert %Player{x: 0, y: 0} = Players.get(@id2)
    end

    test "moving away from obstacle is fine" do
      Players.add(@id1, %{name: @name1, y: 40})
      %{speed: speed} = Players.add(@id2, %{name: @name2})

      Players.set_action(@id2, :up, true)
      speed = speed * -1
      Players.tick(Players.list())
      assert %Player{x: 0, y: 40} = Players.get(@id1)
      assert %Player{x: 0, y: ^speed} = Players.get(@id2)
    end

    test "can move away when stuck in an object" do
      Players.add(@id1, %{name: @name1, y: 20})
      %{speed: speed} = Players.add(@id2, %{name: @name2})

      Players.set_action(@id2, :up, true)
      speed = speed * -1
      Players.tick(Players.list())
      assert %Player{x: 0, y: 20} = Players.get(@id1)
      assert %Player{x: 0, y: ^speed} = Players.get(@id2)
    end
  end
end
