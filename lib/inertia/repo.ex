defmodule Inertia.Repo do
  use Ecto.Repo,
    otp_app: :inertia,
    adapter: Ecto.Adapters.Postgres
end
