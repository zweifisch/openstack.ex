defmodule Openstack.Glance do

  import Openstack, only: :macros

  defresource "image", "image", "/v2/images", "image", tag_add: ["put", "/:id/tags/:tag"]

end
