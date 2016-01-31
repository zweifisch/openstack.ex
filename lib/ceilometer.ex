defmodule Openstack.Ceilometer do

  import Openstack, only: :macros

  defresource "alarm", "metering", "/v2/alarms", nil

end
