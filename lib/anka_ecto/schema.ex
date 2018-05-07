defmodule Anka.Ecto.Schema do

	defmacro __using__(opts \\ []) do

		{model, opts} = Keyword.pop(opts, :model, nil)

		quote do

			require Anka.Ecto.Generators.SchemaGenerator

			Anka.Ecto.Generators.SchemaGenerator.generate_from_model(unquote(model), unquote(opts))
			
		end

	end

end
