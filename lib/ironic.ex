defmodule Openstack.Ironic do

  import Openstack, only: :macros

  defresource "chassis", "baremetal", "/v1/chassis", {nil, "chassis"}
  defresource "chassis_node", "baremetal", "/v1/chassis/:id/nodes", "node", only: [:list]
  defresource "driver", "baremetal", "/v1/drivers", {nil, "drivers"}
  defresource "node", "baremetal", "/v1/nodes", {nil, "nodes"},
    states: {"get", "/:id/states"},
    console: {"get", "/:id/states/console"}
  defresource "ironic_port", "baremetal", "/v1/ports", {nil, "port"}

  defresource "node_power", "baremetal", "/v1/nodes/:id/states/power", nil

end
