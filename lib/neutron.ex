defmodule Openstack.Neutron.Helper do
  import Openstack, only: :macros

  defmacro defres(name, segment, singular, options \\ []) do
    options = options ++ [update: [:put]]
    quote do
      defresource unquote(name), "network", unquote(segment), unquote(singular), unquote(options)
    end
  end

end

defmodule Openstack.Neutron do
  import Openstack.Neutron.Helper, only: :macros

  defres "network", "/v2.0/networks", "network"
  defres "subnet", "/v2.0/subnets", "subnet"

  defres "port", "/v2.0/ports", "port"
  defres "floatingip", "/v2.0/floatingips", "floatingip"
  defres "router", "/v2.0/routers", "router"
  defres "router_interface", "/v2.0/routers/:id/add_router_interface", nil,
    only: [:create],
    create: [:put, ""]

  defres "security_group", "/v2.0/security-groups", "security_group"
  defres "security_group_rule", "/v2.0/security-group-rules", "security_group_rule"

  defres "lb_vip", "/v2.0/lb/vips", "vip"
  defres "lb_health_monitor", "/v2.0/lb/health_monitors", "health_monitor"
  defres "lb_member", "/v2.0/lb/members", "member"

  defres "lb", "/v2.0/lbaas/loadbalancers", "loadbalancer"
  defres "lb_pool", "/v2.0/lbaas/pools", "pool"
  defres "lb_listener", "/v2.0/lbaas/listeners", "loadbalancer"
  defres "lb_pool_member", "/v2.0/lbaas/pools/:pool_id/members", "member"
  defres "lb_status", "/v2.0/lbaas/loadbalancers/:id/statuses", {nil, "statuses"},
    only: [:list]

  defres "firewall", "/v2.0/fw/firewalls", "firewall"
  defres "firewall_policy", "/v2.0/fw/firewall_policies", {"firewall_policy", "firewall_policies"}
  defres "firewall_rule", "/v2.0/fw/firewall_rules", "firewall_rule"

  defres "vpn_service", "/v2.0/vpn/vpnservices", "vpnservice"
  defres "vpn_ikepolicy", "/v2.0/vpn/ikepolicies", {"ikepolicy", "ikepolicies"}
  defres "vpn_ipsecpolicy", "/v2.0/vpn/ipsecpolicies", {"ipsecpolicy", "ipsecpolicies"}
  defres "vpn_ipsec_site_connection", "/v2.0/vpn/ipsec-site-connections", "ipsec_site_connection"

  defres "network_quota", "/v2.0/quotas", "quota", only: [:list]

  defres "qos_policy", "/v2.0/qos/policies", {"policy", "policies"},
    bandwidth_limit_rule: [:post, "/:id/bandwidth_limit_rules"]

  defres "qos_rule_type", "/v2.0/qos/rule-types", "rule_type", only: [:list]

  defres "bandwidth_limit_rule", "/v2.0/qos/policies/:policy_id/bandwidth_limit_rules", "bandwidth_limit_rule"

  defres "gbp_policy_action", "/v2.0/grouppolicy/policy_actions", "policy_action"

  defres "gbp_policy_classifier", "/v2.0/grouppolicy/policy_classifiers", "policy_classifier"

  defres "gbp_policy_rule", "/v2.0/grouppolicy/policy_rules", "policy_rule"

  defres "gbp_policy_rule_set", "/v2.0/grouppolicy/policy_rule_sets", "policy_rule_set"

end
