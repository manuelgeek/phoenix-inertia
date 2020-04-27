defmodule InertiaWeb.PageController do
  use InertiaWeb, :controller
  import InertiaWeb.Authorize

  plug :user_check when action in [:index]

  def index(conn, _params) do
    render_inertia(conn, "Home")
  end
end
