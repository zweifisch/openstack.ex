defmodule Openstack.Nova do

  import Openstack, only: :macros

  defresource "server", "compute", "/servers", "server", [:list, :create, :show, :delete, [:action, :post, "/:id/action"]]

  defresource "server_detail", "compute", "/servers/detail", "server", [:list]

  def server_vnc_console(token, region, id, params \\ []) do
    case server_action!(token, region, id, %{"os-getVNCConsole": %{type: Dict.get(params, :type, "novnc")}}) do
      {:ok, result} -> {:ok, Dict.get(result, "console")}
      x -> x
    end
  end

  defresource "flavor", "compute", "/flavors", "flavor"
  defresource "flavor_detail", "compute", "/flavors/detail", "flavor"

end
