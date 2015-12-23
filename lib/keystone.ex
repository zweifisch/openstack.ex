defmodule Openstack.Keystone do

  import Openstack, only: :macros
  import Maybe

  defresource "user", "identity", "/users", "user"
  defresource "project", "identity", "/projects", "project"
  defresource "domain", "identity", "/domains", "domain"
  defresource "region", "identity", "/regions", "region"
  defresource "credential", "identity", "/credentials", "credential"
  defresource "role_assignment", "identity", "/role_assignments", "roll_assignment", only: [:list]
  defresource "role", "identity", "/roles", "role"

  def token_info(token, region, id, params \\ %{}) do
    Openstack.request(token, region, "identity", :get, "/auth/tokens", "" , params, [{"X-Subject-Token", id}])
      |> ok(fn(%{"token"=> token})-> token end)
  end

end
