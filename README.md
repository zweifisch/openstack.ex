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

## CLI

To build a executable cli application, run following command after
cloning this repo:

    $ mix escript.build

Usage:

    $ ./openstack
        --os-auth-url http://keystone/v3 \
        --os-username admin \
        --os-password password \
        --os-project-name admin \
        --os-domain-name Default \
        network list --limit 2

Or using environment variables:

    export OS_AUTH_URL=http://keystone/v3
    export OS_PROJECT_NAME=admin
    export OS_DOMAIN_NAME=Default
    export OS_USERNAME=admin
    export OS_PASSWORD=password
    export OS_REGION=RegionOne
    export OS_DOMAIN_NAME=Default # optional

### Interactive shell

    $ ./openstack
    > network list --limit 1
    ...
    > network show <id>

### more examples

    floatingip create --floating-network-id <id>

    user update <id> --password <new password>

    volume list --all-tenants

    server update <id> --name <new name>

    network create --name net-1
    subnet create --network-id <id> --ip-version 4 --cidr 192.168.200.0/24

    firewall-policy create --name plicy
    firewall create --firewall-policy-id <id>

    lb-pool create --name asdf --lb-method ROUND_ROBIN --protocol TCP --subnet-id <id>

[hex-image]: https://img.shields.io/hexpm/v/openstack.svg?style=flat
[hex-url]: https://hex.pm/packages/openstack
