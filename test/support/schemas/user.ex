defmodule Anka.Ecto.Schemas.User do

	use Anka.Ecto.Schema,
		model: Anka.Ecto.Models.User

	alias Anka.Ecto.Contexts.Users

	def put_password_hash(changeset) do
		case changeset do
			%Ecto.Changeset{
				valid?: true,
				changes: %{
					password: password,
				},
			} ->
				changeset
				|> put_change(:password_hash, Comeonin.Pbkdf2.hashpwsalt(password))
			_ ->
				changeset
		end
	end

	def check_password(username, password)
	when is_bitstring(username)
	do
		user = Users.get_user_by_username(username)
		__MODULE__.check_password(user, password)
	end

	def check_password(%__MODULE__{} = user, password) do
		case Comeonin.Pbkdf2.checkpw(password, user.password_hash) do
			true ->
				{true, user}
			false ->
				{false, nil}
		end
	end

	def check_password(nil = _user, _password) do
		{false, nil}
	end

end
