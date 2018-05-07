defmodule Anka.Ecto.Generators.ContextGenerator do

	use Anka.Generator

	alias Anka.Ecto.Model.{
		Interpreter,
		Normalizer,
	}


	@doc ~S"""
	Generates CRUDL functions for Ecto schemas from `Anka.Model` based models.
	"""
	@since "0.1.0"
	@impl Anka.Generator
	defmacro generate_from_model(model, opts \\ []) do

		model_expanded = Macro.expand(model, __CALLER__)
			|> Normalizer.normalize_initial()

		singular	  = Interpreter.get_opt(model_expanded, :"meta.singular", default: :"")
		plural		  = Interpreter.get_opt(model_expanded, :"meta.plural", default: :"")
		schema_module = Interpreter.get_opt(model_expanded, :"ecto.schema.module")
		repo_module   = Interpreter.get_opt(model_expanded, :"ecto.repo.module")
		functions 	  = Interpreter.get_opt(model_expanded, :"ecto.context.functions", default: [])


		quote do

			import Ecto.{
				Query,
				Changeset,
			}


			@model unquote(model)

			@opts  unquote(opts)


			unquote do
				create_function = Interpreter.get_opt(functions, :create, default: [])
				case create_function do
					false ->
						:ok
					_ ->
						default_create_function_name = case singular do
							:"" ->
								:create
							singular ->
								Enum.join(
									[
										:create,
										singular,
									],
									"_"
								)
								|> String.to_atom()
						end
						create_function_name = Interpreter.get_opt(
							create_function,
							:name,
							[
								default: default_create_function_name,
							]
						)
						processors = Interpreter.get_opt(create_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(create_function_name)(attrs \\ %{}, opts \\ []) do
								changeset = %unquote(schema_module){}
									|> unquote(schema_module).changeset(attrs)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({changeset, attrs, opts}, fn pre_processor, {changeset, attrs, opts} ->
										apply(pre_processor, [changeset, attrs, opts])
									end)
								case preproc_acc do
									{:error, changeset, attrs, opts} ->
										{:error, changeset, attrs, opts}
									{changeset, attrs, opts} ->
										result = changeset
											|> unquote(repo_module).insert(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|>Enum.reduce_while({result, attrs, opts}, fn post_processor, {result, attrs, opts} ->
												acc = apply(post_processor, [result, attrs, opts])
											end)
										case postproc_acc do
											{:error, result, attrs, opts} ->
												{:error, result, attrs, opts}
											{result, _attrs, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				create_raises_function = Interpreter.get_opt(functions, :create, default: [])
				case create_raises_function do
					false ->
						:ok
					_ ->
						default_create_raises_function_name = case singular do
							:"" ->
								:create!
							singular ->
								Enum.join(
									[
										:create,
										Enum.join(
											[
												singular,
												:!,
											]
										),
									],
									"_"
								)
								|> String.to_atom()
						end
						create_raises_function_name = Interpreter.get_opt(
							create_raises_function,
							:name,
							[
								default: default_create_raises_function_name,
							]
						)
						processors = Interpreter.get_opt(create_raises_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(create_raises_function_name)(attrs \\ %{}, opts \\ []) do
								changeset = %unquote(schema_module){}
									|> unquote(schema_module).changeset(attrs)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({changeset, attrs, opts}, fn pre_processor, {changeset, attrs, opts} ->
										apply(pre_processor, [changeset, attrs, opts])
									end)
								case preproc_acc do
									{:error, changeset, attrs, opts} ->
										{:error, changeset, attrs, opts}
									{changeset, attrs, opts} ->
										result = changeset
											|> unquote(repo_module).insert!(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, attrs, opts}, fn post_processor, {result, attrs, opts} ->
												apply(post_processor, [result, attrs, opts])
											end)
										case postproc_acc do
											{:error, result, attrs, opts} ->
												{:error, result, attrs, opts}
											{result, _attrs, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				get_function = Interpreter.get_opt(functions, :get, default: [])
				case get_function do
					false ->
						:ok
					_ ->
						default_get_function_name = case singular do
							:"" ->
								:get
							singular ->
								Enum.join(
									[
										:get,
										singular,
									],
									"_"
								)
								|> String.to_atom()
						end
						get_function_name = Interpreter.get_opt(
							get_function,
							:name,
							[
								default: default_get_function_name,
							]
						)
						processors = Interpreter.get_opt(get_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(get_function_name)(id, opts \\ []) do
								case is_nil(id) do
									true ->
										nil
									false ->
										query = from r in unquote(schema_module),
											where: r.id == ^id
										preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
											|> Enum.reduce_while({query, id, opts}, fn pre_processor, {query, id, opts} ->
												apply(pre_processor, [query, id, opts])
											end)
										case preproc_acc do
											{:error, reason} ->
												{:error, reason}
											{query, id, opts} ->
												result = query
													|> unquote(repo_module).one()
												postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
													|> Enum.reduce_while({result, opts}, fn post_processor, {result, opts} ->
														apply(post_processor, [result, opts])
													end)
												case postproc_acc do
													{:error, reason} ->
														{:error, reason}
													{result, _opts} ->
														result
												end
											any ->
												any
										end
								end
									
							end
						end
				end
			end


			unquote do
				get_raises_function = Interpreter.get_opt(functions, :get!, default: [])
				case get_raises_function do
					false ->
						:ok
					_ ->
						default_get_raises_function_name = case singular do
							:"" ->
								:get!
							singular ->
								Enum.join(
									[
										:get,
										Enum.join(
											[
												singular,
												:!,
											]
										),
									],
									"_"
								)
								|> String.to_atom()
						end
						get_raises_function_name = Interpreter.get_opt(
							get_raises_function,
							:name,
							[
								default: default_get_raises_function_name,
							]
						)
						processors = Interpreter.get_opt(get_raises_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(get_raises_function_name)(id, opts \\ []) do
								case is_nil(id) do
									true ->
										nil
									false ->
										query = from r in unquote(schema_module),
											where: r.id == ^id
										preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
											|> Enum.reduce_while({query, id, opts}, fn pre_processor, {query, id, opts} ->
												apply(pre_processor, [query, id, opts])
											end)
										case preproc_acc do
											{:error, reason} ->
												{:error, reason}
											{query, id, opts} ->
												result = query
													|> unquote(repo_module).one!()
												postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
													|> Enum.reduce_while({result, opts}, fn post_processor, {result, opts} ->
														apply(post_processor, [result, opts])
													end)
												case postproc_acc do
													{:error, reason} ->
														{:error, reason}
													{result, _opts} ->
														result
												end
											any ->
												any
										end
								end
							end
						end
				end
			end


			unquote do
				get_by_function = Interpreter.get_opt(functions, :get_by, default: [])
				case get_by_function do
					false ->
						:ok
					_ ->
						default_get_by_function_name = case singular do
							:"" ->
								:get_by
							singular ->
								Enum.join(
									[
										:get,
										singular,
										:by,
									],
									"_"
								)
								|> String.to_atom()
						end
						get_by_function_name = Interpreter.get_opt(
							get_by_function,
							:name,
							[
								default: default_get_by_function_name,
							]
						)
						processors = Interpreter.get_opt(get_by_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(get_by_function_name)(clauses, opts \\ []) do
								query = from r in unquote(schema_module)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({query, clauses, opts}, fn pre_processor, {query, clauses, opts} ->
										apply(pre_processor, [query, clauses, opts])
									end)
								case preproc_acc do
									{:error, reason} ->
										{:error, reason}
									{query, clauses, opts} ->
										result = query
											|> unquote(repo_module).get_by(clauses, opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, clauses, opts}, fn post_processor, {result, clauses, opts} ->
												apply(post_processor, [result, clauses, opts])
											end)
										case postproc_acc do
											{:error, reason} ->
												{:error, reason}
											{result, _clauses, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				get_by_raises_function = Interpreter.get_opt(functions, :get_by!, default: [])
				case get_by_raises_function do
					false ->
						:ok
					_ ->
						default_get_by_raises_function_name = case singular do
							:"" ->
								:get_by!
							singular ->
								Enum.join(
									[
										:get,
										singular,
										:by!,
									],
									"_"
								)
								|> String.to_atom()
						end
						get_by_raises_function_name = Interpreter.get_opt(
							get_by_raises_function,
							:name,
							[
								default: default_get_by_raises_function_name,
							]
						)
						processors = Interpreter.get_opt(get_by_raises_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(get_by_raises_function_name)(clauses, opts \\ []) do
								query = from r in unquote(schema_module)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({query, clauses, opts}, fn pre_processor, {query, clauses, opts} ->
										apply(pre_processor, [query, clauses, opts])
									end)
								case preproc_acc do
									{:error, reason} ->
										{:error, reason}
									{query, clauses, opts} ->
										result = query
											|> unquote(repo_module).get_by!(clauses, opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, clauses, opts}, fn post_processor, {result, clauses, opts} ->
												apply(post_processor, [result, clauses, opts])
											end)
										case postproc_acc do
											{:error, reason} ->
												{:error, reason}
											{result, _clauses, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				update_function = Interpreter.get_opt(functions, :update, default: [])
				case update_function do
					false ->
						:ok
					_ ->
						default_update_function_name = case singular do
							:"" ->
								:update
							singular ->
								Enum.join(
									[
										:update,
										singular,
									],
									"_"
								)
								|> String.to_atom()
						end
						update_function_name = Interpreter.get_opt(
							update_function,
							:name,
							[
								default: default_update_function_name,
							]
						)
						processors = Interpreter.get_opt(update_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(update_function_name)(%unquote(schema_module){} = row, attrs \\ %{}, opts \\ []) do
								changeset = row
									|> unquote(schema_module).changeset(attrs)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({changeset, attrs, opts}, fn pre_processor, {changeset, attrs, opts} ->
										apply(pre_processor, [changeset, attrs, opts])
									end)
								case preproc_acc do
									{:error, changeset} ->
										{:error, changeset}
									{changeset, attrs, opts} ->
										result = changeset
											|> unquote(repo_module).update(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, attrs, opts}, fn post_processor, {result, attrs, opts} ->
												apply(post_processor, [result, attrs, opts])
											end)
										case postproc_acc do
											{:error, changeset} ->
												{:error, changeset}
											{result, _attrs, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				update_raises_function = Interpreter.get_opt(functions, :update!, default: [])
				case update_raises_function do
					false ->
						:ok
					_ ->
						default_update_raises_function_name = case singular do
							:"" ->
								:update!
							singular ->
								Enum.join(
									[
										:update,
										Enum.join(
											[
												singular,
												:!,
											]
										),
									],
									"_"
								)
								|> String.to_atom()
						end
						update_raises_function_name = Interpreter.get_opt(
							update_raises_function,
							:name,
							[
								default: default_update_raises_function_name,
							]
						)
						processors = Interpreter.get_opt(update_raises_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(update_raises_function_name)(%unquote(schema_module){} = row, attrs \\ %{}, opts \\ []) do
								changeset = row
									|> unquote(schema_module).changeset(attrs)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({changeset, attrs, opts}, fn pre_processor, {changeset, attrs, opts} ->
										apply(pre_processor, [changeset, attrs, opts])
									end)
								case preproc_acc do
									{:error, changeset} ->
										{:error, changeset}
									{changeset, attrs, opts} ->
										result = changeset
											|> unquote(repo_module).update!(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, attrs, opts}, fn post_processor, {result, attrs, opts} ->
												apply(post_processor, [result, attrs, opts])
											end)
										case postproc_acc do
											{:error, changeset} ->
												{:error, changeset}
											{result, _attrs, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				delete_function = Interpreter.get_opt(functions, :delete, default: [])
				case delete_function do
					false ->
						:ok
					_ ->
						default_delete_function_name = case singular do
							:"" ->
								:delete
							singular ->
								Enum.join(
									[
										:delete,
										singular,
									],
									"_"
								)
								|> String.to_atom()
						end
						delete_function_name = Interpreter.get_opt(
							delete_function,
							:name,
							[
								default: default_delete_function_name,
							]
						)
						processors = Interpreter.get_opt(delete_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(delete_function_name)(%unquote(schema_module){} = row, opts \\ []) do
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({row, opts}, fn pre_processor, {row, opts} ->
										apply(pre_processor, [row, opts])
									end)
								case preproc_acc do
									{:error, changeset} ->
										{:error, changeset}
									{row, opts} ->
										result = row
											|> unquote(repo_module).delete(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, opts}, fn post_processor, {result, opts} ->
												apply(post_processor, [result, opts])
											end)
										case postproc_acc do
											{:error, changeset} ->
												{:error, changeset}
											{result, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				delete_raises_function = Interpreter.get_opt(functions, :delete!, default: [])
				case delete_raises_function do
					false ->
						:ok
					_ ->
						default_delete_raises_function_name = case singular do
							:"" ->
								:delete!
							singular ->
								Enum.join(
									[
										:delete,
										Enum.join(
											[
												singular,
												:!,
											]
										),
									],
									"_"
								)
								|> String.to_atom()
						end
						delete_raises_function_name = Interpreter.get_opt(
							delete_raises_function,
							:name,
							[
								default: default_delete_raises_function_name,
							]
						)
						processors = Interpreter.get_opt(delete_raises_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(delete_raises_function_name)(%unquote(schema_module){} = row, opts \\ []) do
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({row, opts}, fn pre_processor, {row, opts} ->
										apply(pre_processor, [row, opts])
									end)
								case preproc_acc do
									{:error, changeset} ->
										{:error, changeset}
									{row, opts} ->
										result = row
											|> unquote(repo_module).delete!(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, opts}, fn post_processor, {result, opts} ->
												apply(post_processor, [result, opts])
											end)
										case postproc_acc do
											{:error, changeset} ->
												{:error, changeset}
											{result, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				list_function = Interpreter.get_opt(functions, :list, default: [])
				case list_function do
					false ->
						:ok
					_ ->
						default_list_function_name = case plural do
							:"" ->
								:list
							plural ->
								Enum.join(
									[
										:list,
										plural,
									],
									"_"
								)
								|> String.to_atom()
						end
						list_function_name = Interpreter.get_opt(
							list_function,
							:name,
							[
								default: default_list_function_name,
							]
						)
						processors = Interpreter.get_opt(list_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(list_function_name)(opts \\ []) do
								query = from r in unquote(schema_module)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({query, opts}, fn pre_processor, {query, opts} ->
										apply(pre_processor, [query, opts])
									end)
								case preproc_acc do
									{:error, reason} ->
										{:error, reason}
									{query, opts} ->
										result = query
											|> unquote(repo_module).all(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, opts}, fn post_processor, {result, opts} ->
												apply(post_processor, [result, opts])
											end)
										case postproc_acc do
											{:error, reason} ->
												{:error, reason}
											{result, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				list_raises_function = Interpreter.get_opt(functions, :list!, default: [])
				case list_raises_function do
					false ->
						:ok
					_ ->
						default_list_raises_function_name = case plural do
							:"" ->
								:list!
							plural ->
								Enum.join(
									[
										:list,
										Enum.join(
											[
												plural,
												:!,
											]
										),
									],
									"_"
								)
								|> String.to_atom()
						end
						list_raises_function_name = Interpreter.get_opt(
							list_raises_function,
							:name,
							[
								default: default_list_raises_function_name,
							]
						)
						processors = Interpreter.get_opt(list_raises_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(list_raises_function_name)(opts \\ []) do
								query = from r in unquote(schema_module)
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({query, opts}, fn pre_processor, {query, opts} ->
										apply(pre_processor, [query, opts])
									end)
								case preproc_acc do
									{:error, reason} ->
										{:error, reason}
									{query, opts} ->
										result = query
											|> unquote(repo_module).all(opts)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({result, opts}, fn post_processor, {result, opts} ->
												apply(post_processor, [result, opts])
											end)
										case postproc_acc do
											{:error, reason} ->
												{:error, reason}
											{result, _opts} ->
												result
										end
									any ->
										any
								end
							end
						end
				end
			end


			unquote do
				change_function = Interpreter.get_opt(functions, :change, default: [])
				case change_function do
					false ->
						:ok
					_ ->
						default_change_function_name = case singular do
							:"" ->
								:change
							singular ->
								Enum.join(
									[
										:change,
										singular,
									],
									"_"
								)
								|> String.to_atom()
						end
						change_function_name = Interpreter.get_opt(
							change_function,
							:name,
							[
								default: default_change_function_name,
							]
						)
						processors = Interpreter.get_opt(change_function, :processors, default: [])
						pre_processors = Interpreter.get_opt(processors, :pre, default: [])
						post_processors = Interpreter.get_opt(processors, :post, default: [])
						quote do
							def unquote(change_function_name)(%unquote(schema_module){} = row, attrs \\ %{}, opts \\ []) do
								preproc_acc = unquote(pre_processors) ++ Interpreter.get_opt(opts, :"processors.pre", default: [])
									|> Enum.reduce_while({row, attrs, opts}, fn pre_processor, {row, attrs, opts} ->
										apply(pre_processor, [row, attrs, opts])
									end)
								case preproc_acc do
									{:error, reason} ->
										{:error, reason}
									{row, attrs, opts} ->
										changeset = row
											|> unquote(schema_module).changeset(attrs)
										postproc_acc = unquote(post_processors) ++ Interpreter.get_opt(opts, :"processors.post", default: [])
											|> Enum.reduce_while({changeset, attrs, opts}, fn post_processor, {changeset, attrs, opts} ->
												apply(post_processor, [changeset, attrs, opts])
											end)
										case postproc_acc do
											{:error, reason} ->
												{:error, reason}
											{changeset, _attrs, _opts} ->
												changeset
										end
									any ->
										any
								end
							end
						end
				end
			end


		end

	end

end
