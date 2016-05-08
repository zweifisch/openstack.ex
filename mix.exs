defmodule Openstack.Mixfile do
  use Mix.Project

  def package do
    [maintainers: ["Feng Zhou"],
     licenses: ["MIT"],
     description: "Openstack Client",
     links: %{"GitHub" => "https://github.com/zweifisch/openstack.ex"}]
  end

  def project do
    [app: :openstack,
     version: "0.0.4",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  def application do
    [applications: [:logger, :httpoison, :poison]]
  end

  defp deps do
    [{:httpoison, "~> 0.8.0"},
     {:poison, "~> 1.5"},
     {:maybe, "~> 0.0.1"}]
  end
end
