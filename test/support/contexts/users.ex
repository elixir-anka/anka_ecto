defmodule Anka.Ecto.Contexts.Users do

	use Anka.Ecto.Context,
		model: Anka.Ecto.Models.User

	def get_user_by_username(username, opts \\ [])
	when is_bitstring(username)
	do
		__MODULE__.get_user_by([username: username], opts)
	end

end
