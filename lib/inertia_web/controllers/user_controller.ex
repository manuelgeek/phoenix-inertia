defmodule InertiaWeb.UserController do
  use InertiaWeb, :controller

  import InertiaWeb.Authorize
  import InertiaWeb.Utils
  alias Inertia.Sessions

  alias Phauxth.Log
  alias Inertia.{Accounts, Accounts.User}


  # the following plugs are defined in the controllers/authorize.ex file
#   plug :user_check when action in [:index, :show]

  def new(conn, _) do
    render_inertia(conn, "Auth/Register")
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})


        conn
        |> put_flash(:sucess, "User created successfully.")
        |> redirect(to: Routes.page_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_session(:errors, errors_from_changeset(changeset))
        |> redirect(to: Routes.user_path(conn, :new))
    end
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> add_session(user, user)
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp add_session(conn, user, _params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end
end
