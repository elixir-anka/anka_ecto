defmodule Anka.Ecto.Models.Post do

	use Anka.Model, [
		meta: [
			singular: :post,
			plural: :posts,
		],
		ecto: [
			schema: [
				module: Anka.Ecto.Schemas.Post,
			],
			repo: [
				module: Anka.Ecto.Repo,
			],
			source: [
				type: :schema,
				table_name: "posts",
				primary_key: [
					type: :binary_id,
					name: :id,
					opts: [
						autogenerate: true,
					],
				],
				fields: [
					user_id: [
						binder: nil,
						type: :binary_id,
						name: :user_id,
						opts: [
							required: true,
						],
					],
					title: [
						binder: &Ecto.Schema.__field__/4,
						type: :string,
						name: :title,
						opts: [
							required: true,
						],
					],
					body: [
						binder: &Ecto.Schema.__field__/4,
						type: :string,
						name: :body,
						opts: [
							required: true,
						],
					],
				],
				casting_opts: [],
				assocs: [
					user: [
						binder: &Ecto.Schema.__belongs_to__/4,
						type: Anka.Ecto.Schemas.User,
						name: :user,
						opts: [
							foreign_key: :user_id,
						],
					],
				],
				timestamps: [
					type: :utc_datetime,
					inserted_at: :inserted_at,
					updated_at: :updated_at,
				],
			],
		],
	]

end
