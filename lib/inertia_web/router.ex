defmodule InertiaWeb.Router do
  use InertiaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug InertiaWeb.Plugs.InertiaShare
    plug InertiaPhoenix.Plug
  end

  scope "/", InertiaWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end
end
