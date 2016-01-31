defmodule Openstack.Heat do

  import Openstack, only: :macros

  defresource "stack", "orchestration", "/stacks", "stack"

  defresource "event", "orchestration", "/stacks/:stack_name/events", "event", only: [:list]

end
