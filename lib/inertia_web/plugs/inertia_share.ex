defmodule InertiaWeb.Plugs.InertiaShare do
  @moduledoc false
  def init(default), do: default
  alias Inertia.Accounts.User
  import Plug.Conn
  import Phoenix.Controller

  def call(conn, _) do
    conn
    |> InertiaPhoenix.share(:auth, build_auth_map(conn))
    |> InertiaPhoenix.share(:errors, errors_from_session(conn))
    |> InertiaPhoenix.share(:success, get_flash(conn, :success))
    |> InertiaPhoenix.share(:error, get_flash(conn, :error))
    |> delete_session(:errors)
    |> delete_session(:success)
    |> delete_session(:error)
  end

  defp build_auth_map(conn) do
    case %Plug.Conn{assigns: %{current_user: _current_user}} = conn do
      %User{} = current_user ->
        %{
          user: %{
            id: current_user.id,
            name: current_user.name,
            email: current_user.email,
            avatar: current_user.avatar
          }
        }

      _ ->
        %{}
    end
  end

  defp errors_from_session(conn) do
    errors = get_session(conn, :errors)

    if is_map(errors) and map_size(errors) > 0 do
      errors
    else
      %{}
    end
  end
end
