defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  alias Discuss.User
  plug Ueberauth

  # callback is the name that must be used, expected by ueberauth, we pass the conn.assigns property, we can use it to assign data to the conn object
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider} = _params) do # pattern match from the conn and params objects
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: provider}
    changeset = User.changeset(%User{}, user_params)
    signin(conn, changeset)
  end

  # helper to check session for previous sign ins
  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome Back")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: topic_path(conn, :index))
    end
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true) # remove all traces of the user on the session, could have used put_session(:user_id, nil) however for future proofing this will remove all session data
    |> redirect(to: topic_path(conn, :index))
  end

  # helper function to check if the user already exists in the db, defp = private function - can only be used by this module
  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do # check by passing the model and the email prop on changeset.changes
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end

end