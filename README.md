# Openstack

Openstack Client for Elixir

## Installation

First, add openstack to your dependencies in `mix.exs`:

    def deps do
        [{:openstack, "~> 0.0.1"}]
    end

Then, update your dependencies:

    $ mix deps.get

## Usage

    result = Openstack.authenticate("http://keystone/v3",
                                    "admin", "password", "admin")
    case result do
      {:ok, token} -> Neutron.network_list(token, "RegionOne", limit: 2)
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
        network list --limit 2

Or using environment variables:

    export OS_AUTH_URL=http://keystone/v3
    export OS_PROJECT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=password
    export OS_REGION=RegionOne
    export OS_DOMAIN_NAME=Default # optional

### Interactive shell

    $ ./openstack
    > network list --limit 1
    ...
    > network show <id>
