defmodule Openstack.Glance do

  import Openstack, only: :macros

  defresource "image", "image", "/v2/images", {nil, "images"},
    tag_add: ["put", "/:id/tags/:tag"]

  def image_upload(token, region, id, path, params \\ []) do
    with {:ok, %{"file" => file}} = image_show token, region, id do
      Openstack.request(token, region, "image", :put, file, {:file, path}, params, [{"Content-Type", "application/octet-stream"}])
    end
  end

end
