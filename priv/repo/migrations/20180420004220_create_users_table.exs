defmodule Anka.Ecto.Repo.Migrations.CreateUsersTable do

	use Ecto.Migration

	def change() do
		create table(:users, primary_key: false) do
			add :id, :binary_id, primary_key: true
			add :username, :string
			add :password_hash, :string
			timestamps([
				type: :utc_datetime,
			])
		end

		create unique_index(:users, [:username])
	end

end
