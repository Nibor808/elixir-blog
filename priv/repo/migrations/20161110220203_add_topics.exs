defmodule Discuss.Repo.Migrations.AddTopics do
  use Ecto.Migration

  def change do
    # create a new table called topics with a title column taking string values
    create table(:topics) do
      add :title, :string
    end
  end
end
