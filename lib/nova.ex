defmodule Openstack.Nova do

  import Openstack, only: :macros

  defresource "server", "compute", "/servers", "server", action: {:post, "/:id/action"}, update: {:put, "/:id"}

  defresource "server_detail", "compute", "/servers/detail", "server", only: [:list]

  def server_vnc_console(token, region, id, params \\ []) do
    case server_action!(token, region, id, %{"os-getVNCConsole": %{type: Dict.get(params, :type, "novnc")}}) do
      {:ok, result} -> {:ok, Dict.get(result, "console")}
      x -> x
    end
  end

  def server_create_image(token, region, id, params) do
    server_action!(token, region, id, %{"createImage": params})
  end

  defresource "flavor", "compute", "/flavors", "flavor", update: {:put, "/:id"}
  defresource "flavor_detail", "compute", "/flavors/detail", "flavor", only: [:list]

end
