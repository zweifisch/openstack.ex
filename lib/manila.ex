defmodule Openstack.Manila do

  import Openstack, only: :macros

  defresource "share", "sharev2", "/shares", "share"
  defresource "share_detail", "sharev2", "/shares/detail", "share", only: [:list]
  defresource "share_metadata", "sharev2", "/shares/:share_id/metadata", "metadata"
  defresource "share_action", "sharev2", "/shares/:share_id/action", nil, only: [:post]

  defresource "share_network", "sharev2", "/share-networks", "share_network"

end
