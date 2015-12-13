defmodule Openstack.Cinder do

  import Openstack, only: :macros

  defresource "volume", "volumev2", "/volumes", "volume"
  defresource "volume_detail", "volumev2", "/volumes/detail", "volume", [:list]
  defresource "snapshot", "volumev2", "/snapshots", "snapshot"

end
