defmodule Anka.Ecto.Repo.Migrations.CreatePostsTable do

	use Ecto.Migration

	def change() do
		create table(:posts, primary_key: false) do
			add :id, :binary_id, primary_key: true
			add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
			add :title, :string
			add :body, :string
			timestamps([
				type: :utc_datetime,
			])
		end
	end

end
