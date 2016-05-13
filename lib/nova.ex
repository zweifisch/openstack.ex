defmodule Openstack.Nova do

  import Openstack, only: :macros

  defresource "server", "compute", "/servers", "server", update: [:put, "/:id"]
  defresource "server_action", "compute", "/servers/:id/action", nil, only: [:create]

  defresource "server_detail", "compute", "/servers/detail", "server", only: [:list]

  def server_vnc_console(token, region, id, params \\ []) do
    case server_action_create(token, region, id, %{"os-getVNCConsole": %{type: Dict.get(params, :type, "novnc")}}) do
      {:ok, result} -> {:ok, Dict.get(result, "console")}
      x -> x
    end
  end

  def server_reset_state(token, region, id, state) do
    server_action_create(token, region, id, %{"os-resetState": %{state: state}})
  end

  def server_create_image(token, region, id, params) do
    server_action_create(token, region, id, %{"createImage": params})
  end

  defresource "flavor", "compute", "/flavors", "flavor", update: [:put, "/:id"]
  defresource "flavor_detail", "compute", "/flavors/detail", "flavor", only: [:list]

  defresource "server_metadata", "compute", "/servers/:server_id/metadata", "metadata", update: [:put]

  defresource "hypervisor", "compute", "/os-hypervisors", "hypervisor",
    list_detail: [:get, "/detail", "hypervisors"],
    uptime: [:get, "/:id/uptime"],
    statistics: [:get, "/statistics", "hypervisor_statistics"]

  defresource "aggregate", "compute", "/os-aggregates", "aggregate"

end
