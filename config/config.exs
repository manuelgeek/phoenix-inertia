# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :inertia,
  ecto_repos: [Inertia.Repo]

# Configures the endpoint
config :inertia, InertiaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AFafYzxSMfDFQ8kG/WacGxWtnOTvIQwN8ZdF1pxIQ24UanIuDztqoZPapsn0vv7J",
  render_errors: [view: InertiaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Inertia.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  user_context: Inertia.Accounts,
  crypto_module: Argon2,
  token_module: InertiaWeb.Auth.Token

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
config :inertia_phoenix,
  assets_version: 1,          # default 1
  inertia_layout: "app.html"  # default app.html