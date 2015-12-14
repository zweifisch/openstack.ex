defmodule Openstack.Neutron do

  import Openstack, only: :macros

  defresource "network", "network", "/v2.0/networks", "network", update: {:put, "/:id"}
  defresource "subnet", "network", "/v2.0/subnets", "subnet", update: {:put, "/:id"}
  defresource "port", "network", "/v2.0/ports", "port", update: {:put, "/:id"}
  defresource "lb_vip", "network", "/v2.0/lb/vips", "vip", update: {:put, "/:id"}
  defresource "lb_pool", "network", "/v2.0/lb/pools", "pool", update: {:put, "/:id"}
  defresource "lb", "network", "/v2.0/lbaas/loadbalancers", "loadbalancer", update: {:put, "/:id"}
  defresource "floatingip", "network", "/v2.0/floatingips", "floatingip", update: {:put, "/:id"}
  defresource "firewall", "network", "/v2.0/fw/firewalls", "firewall", update: {:put, "/:id"}
  defresource "firewall_policy", "network", "/v2.0/fw/firewall_policies", {"firewall_policy", "firewall_policies"}, update: {:put, "/:id"}
  defresource "router", "network", "/v2.0/routers", "router", update: {:put, "/:id"}, add_router_interface: {:post, "/:id/add_router_interface"}

  def router_add_interface(token, region, id, params) do
    router_add_router_interface!(token, region, id, params)
  end

end
