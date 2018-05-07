defmodule Anka.Ecto.Generators.SchemaGenerator do

	use Anka.Generator

	alias Anka.Ecto.Model.{
		Interpreter,
		Normalizer,
	}


	@default_primary_key [
		type: :id,
		name: :id,
		opts: [
			autogenerate: true,
		],
	]


	@doc """
	Generates Ecto schema from `Anka.Model` based model.
	"""
	@impl Anka.Generator
	defmacro generate_from_model(model, opts \\ []) do
		
		model_expanded = Macro.expand(model, __ENV__)
			|> Normalizer.normalize_initial()

		ecto 		 = Interpreter.get_opt(model_expanded, :"ecto", default: [])
		repo 		 = Interpreter.get_opt(model_expanded, :"ecto.repo", default: [])
		source 		 = Interpreter.get_opt(model_expanded, :"ecto.source", default: [])
		casting_opts = Interpreter.get_opt(model_expanded, :"ecto.source.casting_opts", default: [])
		table_name 	 = Interpreter.get_opt(model_expanded, :"ecto.source.table_name")
		primary_key  = Interpreter.get_opt(model_expanded, :"ecto.source.primary_key", default: @default_primary_key)
		fields 		 = Interpreter.get_opt(model_expanded, :"ecto.source.fields", default: [])
		assocs 		 = Interpreter.get_opt(model_expanded, :"ecto.source.assocs", default: [])

		field_names  = Enum.map(Keyword.values(fields), &Interpreter.get_opt(&1, :name))
		assoc_names  = Enum.map(Keyword.values(assocs), &Interpreter.get_opt(&1, :name))

		timestamps 	 = Interpreter.get_opt(model_expanded, :"ecto.source.timestamps", default: [])


		quote do

			use Ecto.Schema
			
			import Ecto.{
				Query,
				Changeset,
			}


			@before_compile unquote(__MODULE__)

			@model 			unquote(model)

			@opts 			unquote(opts)

			@ecto 			unquote(ecto)

			@repo 			unquote(repo)

			@source 		unquote(source)

			@casting_opts 	unquote(casting_opts)

			@table_name 	unquote(table_name)

			@fields 		unquote(fields)

			@field_names 	unquote(field_names)

			@timestamps		unquote(timestamps)

			@assocs 		unquote(assocs)

			@assoc_names 	unquote(assoc_names)


			unquote do
				cond do
					is_list(primary_key) ->
						quote do
							@primary_key 		{unquote(primary_key[:name]), unquote(primary_key[:type]), unquote(primary_key[:opts])}

							@foreign_key_type 	unquote(primary_key[:type])
						end
					primary_key == false ->
						quote do
							@primary_key 		false
						end
					true ->
						quote do
							@primary_key 		{:id, :id, autogenerate: true}

							@foreign_key_type 	:id
						end
				end
			end


			schema @table_name do
				@fields
				|> Enum.map(fn {field_id, field} ->
					initial_opts = Interpreter.get_opt(field, :opts, default: false)
					{
						field_id,
						Normalizer.normalize_field(field)
						|> Keyword.update(:opts, initial_opts, fn opts ->
							opts
							|> Keyword.put(
								:required,
								case Interpreter.get_opt(field, :"opts.required") do
									{is_required?, validation_opts} ->
										{
											is_function(is_required?) == false && is_required?,
											validation_opts,
										}
									required_opt ->
										required_opt
								end
							)
						end),
					}
				end)
				|> Enum.map(fn {_field_id, field} ->
					case Interpreter.get_opt(field, :binder, default: &Ecto.Schema.__field__/4) do
						nil ->
							:no_action
						binder ->
							apply(
								binder,
								[
									__MODULE__,
									Interpreter.get_opt(field, :name),
									Interpreter.get_opt(field, :type),
									Interpreter.get_opt(field, :opts),
								]
							)
					end
				end)
				timestamps(@timestamps)
				@assocs
				|> Enum.map(fn {_assoc_id, assoc} ->
					case Interpreter.get_opt(assoc, :binder, default: nil) do
						nil ->
							:no_action
						binder ->
							apply(
								binder,
								[
									__MODULE__,
									Interpreter.get_opt(assoc, :name),
									Interpreter.get_opt(assoc, :type),
									Interpreter.get_opt(assoc, :opts),
								]
							)
					end
				end)
			end


			def cast_fields(%__MODULE__{} = instance, attrs) do
				instance
				|> cast(attrs, @field_names, @casting_opts)
			end

			def cast_assocs(%Ecto.Changeset{} = changeset, _attrs) do
				@assocs
				|> Enum.reduce(changeset, fn {_assoc_id, assoc}, acc ->
					acc
					|> cast_assoc(
						Interpreter.get_opt(assoc, :name),
						Interpreter.get_opt(assoc, :opts, default: [])
					)
				end)
			end

			def validate_required_fields(%Ecto.Changeset{} = changeset, attrs) do
				@fields
				|> Enum.reduce(changeset, fn {_field_id, field}, acc ->
					field = Normalizer.normalize_field(field)
					{is_required?, validation_opts} = Interpreter.get_opt(field, :"opts.required", default: {false, []})
					is_required? = case is_function(is_required?) do
						true ->
							apply(is_required?, [changeset, attrs])
						false ->
							is_required?
					end
					case is_required? do
						true ->
							acc
							|> validate_required(
								Interpreter.get_opt(field, :name),
								validation_opts
							)
						false ->
							acc
					end
				end)
			end

			def validate_unique_fields(%Ecto.Changeset{} = changeset, attrs) do
				@fields
				|> Enum.reduce(changeset, fn {_field_id, field}, acc ->
					field = Normalizer.normalize_field(field)
					{is_unique?, validation_opts} = Interpreter.get_opt(field, :"opts.unique", default: {false, []})
					is_unique? = case is_function(is_unique?) do
						true ->
							apply(is_unique?, [changeset, attrs])
						false ->
							is_unique?
					end
					case is_unique? do
						true ->
							acc
							|> unique_constraint(
								Interpreter.get_opt(field, :name),
								validation_opts
							)
						false ->
							acc
					end
				end)
			end

			def changeset(%__MODULE__{} = instance, attrs) do
				instance
				|> __MODULE__.cast_fields(attrs)
				|> __MODULE__.cast_assocs(attrs)
				|> __MODULE__.validate_required_fields(attrs)
				|> __MODULE__.validate_unique_fields(attrs)
			end
			
		end

	end

	defmacro __before_compile__(
		%Macro.Env{
			module: _module,
		}
	)
	do
		quote do
			defoverridable [
				cast_fields: 2,
				cast_assocs: 2,
				validate_required_fields: 2,
				validate_unique_fields: 2,
				changeset: 2,
			]
		end
	end

end
