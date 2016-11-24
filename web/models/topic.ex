defmodule Discuss.Topic do
  use Discuss.Web, :model

  # model schema for db relation (tell phoenix where this maps to in the db)
  schema "topics" do
    field :title, :string
    belongs_to :user, Discuss.User # each topic belong to one user
    has_many :comments, Discuss.Comment
  end

  # add validation (\\ sets default if params == nil)
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end