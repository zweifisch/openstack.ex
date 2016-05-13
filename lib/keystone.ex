defmodule Openstack.Keystone do

  import Openstack, only: :macros
  import Maybe

  defresource "user", "identity", "/users", "user"
  defresource "project", "identity", "/projects", "project"

  defresource "project_user_role", "identity", "/projects/:id/users/:user_id/roles/:role_id", nil,
    grant: ["put"],
    revoke: ["delete"]

  defresource "domain", "identity", "/domains", "domain"
  defresource "region", "identity", "/regions", "region"
  defresource "credential", "identity", "/credentials", "credential"
  defresource "role_assignment", "identity", "/role_assignments", "role_assignment", only: [:list]
  defresource "role", "identity", "/roles", "role"
  defresource "endpoint", "identity", "/endpoints", "endpoint"
  defresource "service", "identity", "/services", "service"

  defresource "project_endpoint", "identity", "/OS-EP-FILTER/projects/:project_id/endpoints", "endpoint",
    create: ["put", "/:id"]
  defresource "endpoint_project", "identity", "/OS-EP-FILTER/endpoints/:endpoint_id/projects", "project", only: [:list]
  defresource "endpoint_group", "identity", "/OS-EP-FILTER/endpoint_groups", "endpoint_group"
  defresource "service_provider_group", "identity", "/OS-EP-FILTER/service_providers_groups", "service_provider"

  def token_info(token, region, id, params \\ %{}) do
    Openstack.request(token, region, "identity", :get, "/auth/tokens", "" , params, [{"X-Subject-Token", id}])
      |> ok(fn(%{"token"=> token})-> token end)
  end

  def endpoint_list_by_type(token, region, type, params \\ []) do
    with {:ok, services} <- service_list(token, region, type: type), {:ok, endpoints} <- endpoint_list(token, region) do
      ids = Enum.map(services, fn(x)-> Dict.get(x, "id") end) |> MapSet.new
      {:ok, Enum.filter(endpoints, &(MapSet.member?(ids, Dict.get(&1, "service_id"))))}
    end
  end

end
