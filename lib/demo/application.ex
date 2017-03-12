defmodule Demo.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Demo.Worker.start_link(arg1, arg2, arg3)
      # worker(Demo.Worker, [arg1, arg2, arg3]),
      worker(__MODULE__, [], function: :start_cowboy),
      supervisor(Phoenix.PubSub.PG2, [:chat_pubsub, []]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # cowboyの起動処理
  def start_cowboy do
    dispatch = :cowboy_router.compile([
      {:_, [
        {"/",             Demo.HelloHandler, []},
        {"/greet/:name",  Demo.GreetHandler, []},
        {"/websocket",    Demo.WebSocketHandler, []},
        {"/static/[...]", :cowboy_static, {:priv_dir, :demo, "static_files"}}
      ]}
    ])
    env = %{dispatch: dispatch}

    # TCP待ち受け開始
    {:ok, _pid} = :cowboy.start_clear(
      :http,           # Listener名
      10,              # 同時コネクション数
      [{:port, 4000}], # トランスポートオプション
      %{env: env}      # コンパイルしたルーティングなど
    )
  end
end
