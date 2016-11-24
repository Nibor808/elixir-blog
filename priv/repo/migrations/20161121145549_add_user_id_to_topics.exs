defmodule Discuss.Repo.Migrations.AddUserIdToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :user_id, references(:users) # need to add an association to models topic and user to tell Phoenix what to do with this
    end
  end
end
