defmodule Anka.Ecto.Models.User do

	use Anka.Model, [
		meta: [
			singular: :user,
			plural: :users,
		],
		ecto: [
			schema: [
				module: Anka.Ecto.Schemas.User,
			],
			repo: [
				module: Anka.Ecto.Repo,
			],
			source: [
				type: :schema,
				table_name: "users",
				primary_key: [
					type: :binary_id,
					name: :id,
					opts: [
						autogenerate: true,
					],
				],
				fields: [
					username: [
						binder: &Ecto.Schema.__field__/4,
						type: :string,
						name: :username,
						opts: [
							required: {true, [message: "can’t be blank", trim: true]},
							unique: true,
						],
					],
					password: [
						binder: &Ecto.Schema.__field__/4,
						type: :string,
						name: :password,
						opts: [
							virtual: true,
							required: &Anka.Ecto.Processors.UserContextProcessor.is_password_required?/2,
						],
					],
					password_hash: [
						binder: &Ecto.Schema.__field__/4,
						type: :string,
						name: :password_hash,
						opts: [],
					],
				],
				casting_opts: [],
				assocs: [
					posts: [
						binder: &Ecto.Schema.__has_many__/4,
						type: Anka.Ecto.Schemas.Post,
						name: :posts,
						opts: [],
					],
				],
				timestamps: [
					type: :utc_datetime,
					inserted_at: :inserted_at,
					updated_at: :updated_at,
				],
			],
			context: [
				functions: [
					create: [
						processors: [
							pre: [
								&Anka.Ecto.Processors.UserContextProcessor.pre_create/3,
							],
						],
					],
					create!: [
						processors: [
							pre: [
								&Anka.Ecto.Processors.UserContextProcessor.pre_create/3,
							],
						],
					],
					get: [
						processors: [],
					],
					get!: [
						processors: [],
					],
					get_by: [
						processors: [],
					],
					get_by!: [
						processors: [],
					],
					update: [
						processors: [],
					],
					update!: [
						processors: [],
					],
					delete: [
						processors: [],
					],
					delete!: [
						processors: [],
					],
					list: [
						processors: [],
					],
					list!: [
						processors: [],
					],
				],
			],
		],
	]

end
