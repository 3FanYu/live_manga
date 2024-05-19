# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :crawly,
  closespider_timeout: :disabled,
  concurrent_requests_per_domain: 8,
  closespider_itemcount: 100,
  fetcher: {Crawly.Fetchers.CrawlyRenderServer, [base_url: "http://localhost:3001/render"]},

  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot", "Google"]},
    {Crawly.Middlewares.RequestOptions, [timeout: :infinity, recv_timeout: :infinity]}
  ],
  pipelines: [
    # An item is expected to have all fields defined in the fields list
    {Crawly.Pipelines.Validate, fields: [:url]},

    # Use the following field as an item uniq identifier (pipeline) drops
    # items with the same urls
    {Crawly.Pipelines.DuplicatesFilter, item_id: :url},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "./tmp"}
  ]


config :live_manga,
  ecto_repos: [LiveManga.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :live_manga, LiveMangaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LiveMangaWeb.ErrorHTML, json: LiveMangaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LiveManga.PubSub,
  live_view: [signing_salt: "GRm8Ey69"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :live_manga, LiveManga.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  live_manga: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  live_manga: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
