defmodule Openstack.Nova do

  import Openstack, only: :macros

  defresource "server", "compute", "/servers", "server", [:list, :create, :show, :delete, [:action, :post, "/:id/action"]]

  defresource "server_detail", "compute", "/servers/detail", "server", [:list]

  def server_vnc_console(token, region, id, type \\ "novnc") do
    server_action(token, region, id, %{"os-getVNCConsole": %{type: type}})
  end

end
