defmodule MensagemWeb.Router do
  use MensagemWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug MensagemWeb.AuthPlug
  end

  scope "/api", MensagemWeb do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
  end

  scope "/api", MensagemWeb do
    pipe_through [:api, :authenticated]

    get "/me", AuthController, :me

    get "/contacts", ContactController, :index
    post "/contacts", ContactController, :create
    delete "/contacts/:id", ContactController, :delete

    get "/conversations", ConversationController, :index
    post "/conversations", ConversationController, :create
    get "/conversations/:id", ConversationController, :show

    get "/conversations/:conversation_id/messages",
        MessageController,
        :index

    post "/conversations/:conversation_id/messages",
         MessageController,
         :create

    get "/users/available", ContactController, :available

    get "/groups", GroupController, :index
    post "/groups", GroupController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mensagem, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: MensagemWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
