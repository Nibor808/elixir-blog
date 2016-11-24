defmodule Discuss.Router do
  use Discuss.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Discuss.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Discuss do
    pipe_through :browser # Use the default browser stack

    # route accessing functions in the TopicController
    # get "/", TopicController, :index
    # post "/topics", TopicController, :create
    # get "/topics/new", TopicController, :new
    # get "/topics/:id/edit", TopicController, :edit
    # put "/topics/:id", TopicController, :update
    # delete "/topics/:id", TopicController, :delete
    # get "/topics/:id", TopicController, :show
    resources "/", TopicController # if we follow RESTful conventions as above, the resources helper will automagically create the routes for us
  end

  scope "/auth", Discuss do
    pipe_through :browser
    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request # request is defined by the ueberauth module, :provider is taken from the params object "facebook, github, google,..."
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", Discuss do
  #   pipe_through :api
  # end
end
