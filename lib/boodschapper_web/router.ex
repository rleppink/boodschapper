defmodule BoodschapperWeb.Router do
  use BoodschapperWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {BoodschapperWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BoodschapperWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    live("/groceries", GroceryLive.Index, :index)
    live("/groceries/new", GroceryLive.Index, :new)
    live("/groceries/:id/edit", GroceryLive.Index, :edit)

    live("/groceries/:id", GroceryLive.Show, :show)
    live("/groceries/:id/show/edit", GroceryLive.Show, :edit)
  end

  # Other scopes may use custom stacks.
  # scope "/api", BoodschapperWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:boodschapper, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: BoodschapperWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
