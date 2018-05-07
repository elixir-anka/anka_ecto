defmodule Anka.Ecto.Processors.UserContextProcessor do

	alias Anka.Ecto.Schemas.User

	def is_password_required?(%User{} = user, %{} = _attrs) do
		is_nil(user.password_hash)
	end

	def is_password_required?(%Ecto.Changeset{} = changeset, %{} = attrs) do
		__MODULE__.is_password_required?(changeset.data, attrs)
	end

	def pre_create(%Ecto.Changeset{} = changeset, %{} = attrs, opts \\ []) do
		changeset = changeset
			|> User.put_password_hash()
		{:cont, {changeset, attrs, opts}}
	end

	def post_create(%User{} = user, %{} = attrs, opts \\ []) do
		{:cont, {user, attrs, opts}}
	end

end
