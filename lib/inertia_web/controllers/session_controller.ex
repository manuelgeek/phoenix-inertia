defmodule InertiaWeb.SessionController do
  use InertiaWeb, :controller

  import InertiaWeb.Authorize

  alias Phauxth.Login
  alias Inertia.{Sessions, Sessions.Session}

  plug :guest_check when action in [:new, :create]

  def new(conn, _) do
    render_inertia(conn, "Auth/Login")
  end

  def create(conn, %{"session" => params}) do
    case Login.verify(params) do
      {:ok, user} ->
        conn
        |> add_session(user, params)
        |> put_flash(:info, "User successfully logged in.")
        |> redirect(to: get_session(conn, :request_path) || Routes.page_path(conn, :index))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, %{"id" => session_id}) do
    case Sessions.get_session(session_id) do
      %Session{user_id: ^user_id} = session ->
        Sessions.delete_session(session)
        conn
        |> delete_session(:phauxth_session_id)
        |> put_flash(:success, "User successfully logged out.")
        |> redirect(to: Routes.session_path(conn, :new))

      _ ->
        conn
        |> put_flash(:error, "Unauthorized")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  defp add_session(conn, user, _params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end
end
