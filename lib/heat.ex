defmodule Openstack.Heat do

  import Openstack, only: :macros

  defresource "stack", "orchestration", "/stacks", "stack"

end
