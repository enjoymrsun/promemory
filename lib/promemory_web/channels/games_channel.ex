defmodule PromemoryWeb.GamesChannel do
  use PromemoryWeb, :channel

  alias Promemory.Game

  def join("games:" <> name, payload, socket) do
    game = Promemory.GameBackup.load(name) || Game.new
    socket = socket
    |> assign(:game, game)
    |> assign(:name, name)

    if authorized?(payload) do
      {:ok, %{"view" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("click", %{"tilepos" => pos}, socket) do
    game0 = socket.assigns[:game]
    game1 = Game.handle_click(game0, pos)
    Promemory.GameBackup.save(socket.assigns[:name], game1)
    socket = assign(socket, :game, game1)
    {:reply, {:ok, %{ "view" => Game.client_view(game1)}}, socket}
  end

  def handle_in("compare", %{}, socket) do
    game0 = socket.assigns[:game]
    game1 = Game.compare_tiles(game0)
    Promemory.GameBackup.save(socket.assigns[:name], game1)
    socket = assign(socket, :game, game1)
    {:reply, {:ok, %{ "view" => Game.client_view(game1)}}, socket}
  end

  def handle_in("reset", %{}, socket) do
    game0 = Game.new
    Promemory.GameBackup.save(socket.assigns[:name], game0)
    socket = assign(socket, :game, game0)
    {:reply, {:ok, %{ "view" => Game.client_view(game0)}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
