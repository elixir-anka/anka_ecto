defmodule Anka.Ecto.QueryTest do

	use Anka.Ecto.TestCase

	alias Anka.Ecto.Model.Interpreter

	alias Anka.Ecto.Contexts.{
		Users,
		Posts,
	}

	test "inserting an user" do
		result = Users.create_user(%{username: "jack", password: "12345"})
		assert {:ok, user} = result
		assert is_nil(user.id) == false
	end

	test "hashing password on create an user by using processor" do
		result = Users.create_user(%{username: "jill", password: "12345"})
		assert {:ok, user} = result
		assert is_nil(user.password_hash) == false
	end

	test "inserting a post" do
		assert {:ok, author} = Users.create_user(%{username: "jimmy", password: "12345"})
		assert {:ok, post} = Posts.create_post(
			%{
				title: "First Post",
				body: "Hello, world!",
				user_id: author.id,
			},
			processors: [
				post: [
					(&(fn result, attrs, opts ->
						repo = Interpreter.get_opt(Anka.Ecto.Models.Post, :"ecto.repo.module")
						with {:ok, post} <- result do
							{
								:cont,
								{
									{
										:ok,
										repo.preload(post, :user),
									},
									attrs,
									opts,
								}
							}
						else
							any ->
								{:cont, any}
						end
					end).(&1, &2, &3))
				],
			]
		)
		assert is_nil(post.id) == false
		assert post.user.id == author.id
	end

end
