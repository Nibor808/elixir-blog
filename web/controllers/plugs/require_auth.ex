defmodule Discuss.Plugs.RequireAuth do

  import Plug.Conn # gives halt()
  import Phoenix.Controller # gives redirect() and put_flash()
  alias Discuss.Router.Helpers # gives topic_path()

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do # if conn.assigns has a user
      conn # if there's a user and we want to let them proceed just return the conn object
    else
      conn
      |> put_flash(:error, "You Must Be Logged In")
      |> redirect(to: Helpers.topic_path(conn, :index)) # Helpers.topic_path because we are not doing 'use Discuss.Web :controller'
      |> halt() # tell Phoenix not to send the conn on to the next plug, only used inside plugs
    end
  end
end