defmodule Openstack.Keystone do

  import Openstack, only: :macros

  defresource "user", "identity", "/users", "user"
  defresource "project", "identity", "/projects", "project"
  defresource "domain", "identity", "/domains", "domain"
  defresource "region", "identity", "/regions", "region"
  defresource "credential", "identity", "/credentials", "credential"
  defresource "role_assignment", "identity", "/role_assignments", "roll_assignment", [:list]
  defresource "role", "identity", "/roles", "role"

end
