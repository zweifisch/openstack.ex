defmodule Openstack.Neutron do

  import Openstack, only: :macros

  defresource "network", "network", "/v2.0/networks", "network"
  defresource "subnet", "network", "/v2.0/subnets", "subnet"
  defresource "port", "network", "/v2.0/ports", "port"
  defresource "lb_vip", "network", "/v2.0/lb/vips", "vip"
  defresource "lb_pool", "network", "/v2.0/lb/pools", "pool"
  defresource "floatingip", "network", "/v2.0/floatingips", "floatingip"
  defresource "firewall", "network", "/v2.0/fw/firewalls", "firewall"
  defresource "router", "network", "/v2.0/routers", "router"

end
