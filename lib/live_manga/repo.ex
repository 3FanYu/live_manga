defmodule LiveManga.Repo do
  use Ecto.Repo,
    otp_app: :live_manga,
    adapter: Ecto.Adapters.Postgres
end
