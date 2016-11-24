defmodule Discuss.TopicController do
  use Discuss.Web, :controller # gives us a bunch of functionality including Ecto module -> Repo, schema, changeset, query, build_assoc
  alias Discuss.Topic # allows for Discuss.Topic to be replaced with Topic

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete] # bring in our require_auth function but only for these routes
  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    # return all topics from DB
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id)
    render conn, "show.html", topic: topic
  end

  def new(conn, _params) do
    # create a changeset using struct = %Topic{} and params = %{}
    changeset = Topic.changeset(%Topic{}, %{})
    # render the correct html page and pass changeset as a defined variable
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"topic" => topic}) do # pattern match topic to the params
    changeset = conn.assigns[:user] # get current user and pass to build_assoc
      |> build_assoc(:topics) # produces a Topic struct that is passed to Topic.changeset (conn is always the first arg)
      |> Topic.changeset(topic) # changeset now includes the user_id of the user that created the topic

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id) # get topic with id from DB
    changeset = Topic.changeset(topic) # create changeset out of topic from DB
    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do # get id and topic title
    old_topic = Repo.get(Topic, topic_id) # get the topic with the id
    changeset = Topic.changeset(old_topic, topic)  # create the changeset and pass the new values from topic
    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
   end
  end

  def delete(conn, %{"id" => topic_id}) do
    # use "!" (bang) to return a phoenix generated error for the action instead of assigning 'nil'
    # useful when we don't want to give the user another chance due to error
    # like saying "NO, you just can't do that"
    Repo.get!(Topic, topic_id) |> Repo.delete! # if error show bang error message
    # if success show flash and redirect
    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  defp check_topic_owner(conn, _params) do # create a function plug as we only expect to use this in this module, no need for module level plug
    %{params: %{"id" => topic_id}} = conn
    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do # get topic from db and compare it's user_id prop to the conn.assigns user_id
      conn
    else
      conn
      |> put_flash(:error, "You Cannot Edit That")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end

end