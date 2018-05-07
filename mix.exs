defmodule Anka.Ecto.MixProject do

    use Mix.Project

    @version "0.1.0"

	@github_url "https://github.com/elixir-anka/anka_ecto"

    def project() do
        [
            app: :anka_ecto,
            version: @version,
			description: """
			Anka.Ecto helps to create Ecto schemas and their context functions with optionally definable pre/post processors that prepare CRUDL resources from models based on Anka.Model.
			"""
			|> String.trim(),
			package: __MODULE__.package(),
            elixir: "~> 1.6",
			elixirc_paths: __MODULE__.elixirc_paths(Mix.env()),
            start_permanent: Mix.env() == :prod,
            deps: deps(),
			aliases: __MODULE__.aliases(),
        ]
		|> Keyword.put(:docs, __MODULE__.docs())
    end

	def package() do
		[
			maintainers: [
				"Ertuğrul Keremoğlu <ertugkeremoglu@gmail.com>",
			],
			licenses: [
				"MIT",
			],
			files: [
				"lib",
				".formatter.exs",
				"mix.exs",
				"logo.png",
				"banner.png",
				"README.md",
				"LICENSE.txt",
			],
			links: %{
				"GitHub" => @github_url,
			},
		]
	end

	def docs() do
		[
			name: "Anka.Ecto",
			logo: "logo.png",
            source_ref: "v#{@version}",
			source_url: @github_url,
			main: "Anka.Ecto",
		]
	end

    # Run "mix help compile.app" to learn about applications.
    def application() do
        [
            mod: {Anka.Ecto.Application, []},
            extra_applications: __MODULE__.extra_applications(Mix.env()),
        ]
    end

	def extra_applications() do
		[
			:logger,
			:altstd,
			:anka,
			:ecto,
		]
	end

	def extra_applications(:test) do
		__MODULE__.extra_applications()
		++
		[
			:ecto,
			:mariaex,
		]
	end

	def extra_applications(_env) do
		__MODULE__.extra_applications()
	end

	def elixirc_paths() do
		[
			"lib",
		]
	end

	def elixirc_paths(:test) do
		__MODULE__.elixirc_paths()
		++
		[
			"test/support",
		]
	end

	def elixirc_paths(_env) do
		__MODULE__.elixirc_paths()
	end

	def aliases() do
		[
			"anka.ecto.reset": [
				"ecto.drop",
				"ecto.create",
				"ecto.migrate",
			],
			"test": [
				"anka.ecto.reset",
				"test",
			],
		]
	end

    # Run "mix help deps" to learn about dependencies.
    defp deps() do
        [
			{:altstd, "~> 0.0.1"},
			{:anka, "~> 0.1.0"},
            {:ecto, "~> 2.2"},
			{:mariaex, "~> 0.8", only: [:dev, :test]},
			{:comeonin, "~> 4.1", only: [:dev, :test]},
			{:pbkdf2_elixir, "~> 0.12.0", only: [:dev, :test]},
			{:ex_doc, "~> 0.16", only: :dev, runtime: false},
        ]
    end

end
