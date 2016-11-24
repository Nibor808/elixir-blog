defmodule Discuss.Plugs.SetUser do
  import Plug.Conn # contains helper functions for working with conn object
  #import Phoenix.Controller # gives us get_session function

  alias Discuss.Repo
  alias Discuss.User

  def init(_params) do # no initial setup to do, if we needed records from DB or something else do it here

  end

  def call(conn, _params) do # _params is the return value from init(), we have nothing returned
    user_id = get_session(conn, :user_id)
    cond do # first condition that evaluates to true will be executed
      user = user_id && Repo.get(User, user_id) -> # second value (user struct)is assigned to 'user' if it is true
        assign(conn, :user, user) # now conn.assigns.user => user struct
      true -> # true is always executed if it is last and nothing else was true
        assign(conn, :user, nil) # if no user_id assign nil to conn.assigns.user
    end
  end

end