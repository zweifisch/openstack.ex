defmodule Openstack.Manila do

  import Openstack, only: :macros

  defresource "share", "sharev2", "/shares", "share"
  defresource "share_detail", "sharev2", "/shares/detail", "share", only: [:list]
  defresource "share_metadata", "sharev2", "/shares/:share_id/metadata", "metadata"
  defresource "share_action", "sharev2", "/shares/:share_id/action", nil, only: [:create]

  defresource "share_limit", "sharev2", "/limits", "limit", only: [:list]
  defresource "share_quota", "sharev2", "/os-quota-sets/:project_id", nil

  defresource "share_network", "sharev2", "/share-networks", "share_network"
  defresource "share_network_detail", "sharev2", "/share-networks/detail", "share_network"

  defresource "share_type", "sharev2", "/types", "share_type", list_default: {:get, "/default"}

  defresource "share_server", "sharev2", "/share-servers", "share_server"

  def share_extend(token, region, id, params \\ []) do
    size = Dict.get(params, :size)
    share_action_create(token, region, id, %{"os-extend": %{"new_size": is_integer(size) && size || String.to_integer(size)}})
  end

  def share_shrink(token, region, id, params \\ []) do
    size = Dict.get(params, :size)
    share_action_create(token, region, id, %{"os-shrink": %{"new_size": size}})
  end

  def share_grant_access(token, region, id, params \\ []) do
    share_action_create(token, region, id, %{"os-allow_access":
                                             %{"access_level": Dict.get(params, :level, "rw"),
                                               "access_type": Dict.get(params, :type),
                                               "access_to": Dict.get(params, :to)}})
  end

  def share_revoke_access(token, region, id, access_id) do
    share_action_create(token, region, id, %{"os-deny_access": %{"access_id": access_id}})
  end

  def share_list_access(token, region, id, params \\ []) do
    with {:ok, result} <- share_action_create(token, region, id, %{"os-access_list": nil}),
        do: {:ok, Dict.get(result, :access_list)}
  end

end
