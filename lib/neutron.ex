defmodule Openstack.Neutron do

  import Openstack, only: :macros

  defresource "network", "network", "/v2.0/networks", "network", update: {:put, "/:id"}
  defresource "subnet", "network", "/v2.0/subnets", "subnet", update: {:put, "/:id"}

  defresource "port", "network", "/v2.0/ports", "port", update: {:put, "/:id"}
  defresource "floatingip", "network", "/v2.0/floatingips", "floatingip", update: {:put, "/:id"}
  defresource "router", "network", "/v2.0/routers", "router", update: {:put, "/:id"}
  defresource "router_interface", "network", "/v2.0/routers/:id/add_router_interface", nil, only: [:create], create: {:put, ""}

  defresource "security_group", "network", "/v2.0/security-groups", "security_group", update: {:put, "/:id"}
  defresource "security_group_rule", "network", "/v2.0/security-group-rules", "security_group_rule", update: {:put, "/:id"}

  defresource "lb_vip", "network", "/v2.0/lb/vips", "vip", update: {:put, "/:id"}
  defresource "lb_pool", "network", "/v2.0/lb/pools", "pool", update: {:put, "/:id"}
  defresource "lb_health_monitor", "network", "/v2.0/lb/health_monitors", "health_monitor", update: {:put, "/:id"}
  defresource "lb_member", "network", "/v2.0/lb/members", "member", update: {:put, ":/id"}

  defresource "lb", "network", "/v2.0/lbaas/loadbalancers", "loadbalancer", update: {:put, "/:id"}

  defresource "firewall", "network", "/v2.0/fw/firewalls", "firewall", update: {:put, "/:id"}
  defresource "firewall_policy", "network", "/v2.0/fw/firewall_policies", {"firewall_policy", "firewall_policies"}, update: {:put, "/:id"}
  defresource "firewall_rule", "network", "/v2.0/fw/firewall_rules", "firewall_rule", update: {:put, "/:id"}

  defresource "vpn_service", "network", "/v2.0/vpn/vpnservices", "vpnservice", update: {:put, "/:id"}
  defresource "vpn_ikepolicy", "network", "/v2.0/vpn/ikepolicies", {"ikepolicy", "ikepolicies"}, update: {:put, "/:id"}
  defresource "vpn_ipsecpolicy", "network", "/v2.0/vpn/ipsecpolicies", {"ipsecpolicy", "ipsecpolicies"}, update: {:put, "/:id"}
  defresource "vpn_ipsec_site_connection", "network", "/v2.0/vpn/ipsec-site-connections", "ipsec_site_connection", update: {:put, "/:id"}

  defresource "network_quota", "network", "/v2.0/quotas", "quota", only: [:list]

  defresource "qos_policy", "network", "/v2.0/qos/policies", {"policy", "policies"},
    update: {:put, "/:id"},
    bandwidth_limit_rule: {:post, "/:id/bandwidth_limit_rules"}

  defresource "qos_rule_type", "network", "/v2.0/qos/rule-types", "rule_type", only: [:list]

  defresource "bandwidth_limit_rule", "network",
    "/v2.0/qos/policies/:policy_id/bandwidth_limit_rules", "bandwidth_limit_rule", update: {:put, "/:id"}

end
