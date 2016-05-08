# Openstack

[![hex][hex-image]][hex-url]

Openstack Client for Elixir

## Installation

First, add openstack to your dependencies in `mix.exs`:

    def deps do
        [{:openstack, "~> 0.0.3"}]
    end

Then, update your dependencies:

    $ mix deps.get

## Usage

    result = Openstack.authenticate("http://keystone/v3",
                                    "admin", "password", "admin", "Default")
    case result do
      {:ok, token} -> Neutron.network_list(token, "RegionOne", limit: 2)
    end

## Macro

    defmodule Mymodule do

        import Openstack, only: :macros

        defresource "server", "compute", "/servers", "server"

        defresource "server", "compute", "/servers",
            {"server", "servers"},
            only: [:list, :show],
            action: {:post, "/:id/action"}
    end

[hex-image]: https://img.shields.io/hexpm/v/openstack.svg?style=flat
[hex-url]: https://hex.pm/packages/openstack
