Anka.Ecto.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Anka.Ecto.Repo, :manual)


defmodule Anka.Ecto.TestCase do

	use ExUnit.CaseTemplate

	using opts do
		quote do

			use ExUnit.Case,
				unquote(opts)

			alias Anka.Ecto.Repo

			import Ecto.Query
		
		end
	end

	setup do
		:ok = Ecto.Adapters.SQL.Sandbox.checkout(Anka.Ecto.Repo)
	end

end


ExUnit.start()
