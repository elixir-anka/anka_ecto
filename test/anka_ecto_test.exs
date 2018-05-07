defmodule Anka.Ecto.Test do

	use ExUnit.Case,
		async: true

	doctest Anka.Ecto.Model
	doctest Anka.Ecto.Model.Interpreter
	doctest Anka.Ecto.Model.Normalizer
	doctest Anka.Ecto.Schema
	doctest Anka.Ecto.Generators.SchemaGenerator
	doctest Anka.Ecto.Context
	doctest Anka.Ecto.Generators.ContextGenerator

end
