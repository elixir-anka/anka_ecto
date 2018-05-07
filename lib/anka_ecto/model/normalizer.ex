defmodule Anka.Ecto.Model.Normalizer do
	@moduledoc """
	Helps to normalize Ecto opts of `Anka.Model` based models.
	"""

	alias Anka.Ecto.Model.Interpreter


	@doc false
	@since "0.1.0"
	def normalize_initial({key, value}, acc)
	when is_list(acc)
	do
		acc
		|> Keyword.put(key, __MODULE__.normalize_initial(value))
	end


	@doc false
	@since "0.1.0"
	def normalize_initial(value, acc)
	when is_list(acc)
	do
		acc
		++
		[
			__MODULE__.normalize_initial(value),
		]
	end


	@doc false
	@since "0.1.0"
	def normalize_initial(value)
	when is_list(value)
	do
		value
		|> Enum.reduce([], &(__MODULE__.normalize_initial(&1, &2)))
	end


	@doc false
	@since "0.1.0"
	def normalize_initial(value)
	when is_function(value)
	do
		value
		|> Macro.expand(__ENV__)
	end


	@doc false
	@since "0.1.0"
	def normalize_initial(value) do
		value
	end


	@doc false
	@since "0.1.0"
	def normalize_field({_field_id, field}) do
		field
		|> __MODULE__.normalize_field()
	end


	@doc false
	@since "0.1.0"
	def normalize_field(field) do
		field
		|> __MODULE__.normalize_field_opt(:opts)
	end


	@doc false
	@since "0.1.0"
	def normalize_field_opt({_field_id, field}, :opts) do
		field
		|> __MODULE__.normalize_field_opt(:opts)
	end


	@doc false
	@since "0.1.0"
	def normalize_field_opt(field, :opts) do
		initial_opts = Interpreter.get_opt(field, :opts, default: false)
		field
		|> Keyword.update(:opts, initial_opts, fn opts ->
			opts
			|> Keyword.put(:required, __MODULE__.normalize_field_opt(field, :"opts.required"))
			|> Keyword.put(:unique, __MODULE__.normalize_field_opt(field, :"opts.unique"))
		end)
	end


	@doc false
	@since "0.1.0"
	def normalize_field_opt({_field_id, field}, :"opts.required" = opt_key) do
		field
		|> __MODULE__.normalize_field_opt(opt_key)
	end


	@doc false
	@since "0.1.0"
	def normalize_field_opt(field, :"opts.required" = opt_key) do
		required_opt = Interpreter.get_opt(field, opt_key, default: false)
		case required_opt do
			{is_required?, validation_opts} ->
				{is_required?, validation_opts}
			_ ->
				{required_opt, []}
		end
	end


	@doc false
	@since "0.1.0"
	def normalize_field_opt({_field_id, field}, :"opts.unique" = opt_key) do
		field
		|> __MODULE__.normalize_field_opt(opt_key)
	end


	@doc false
	@since "0.1.0"
	def normalize_field_opt(field, :"opts.unique" = opt_key) do
		unique_opt = Interpreter.get_opt(field, opt_key, default: false)
		case unique_opt do
			{is_unique?, validation_opts} ->
				{is_unique?, validation_opts}
			_ ->
				{unique_opt, []}
		end
	end

end
