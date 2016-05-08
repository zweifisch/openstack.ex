defmodule Openstack.Gnocchi do

  import Openstack, only: :macros

  defresource "metric", "metric", "/v1/metric", nil
  defresource "measure", "metric", "/v1/metric/:metric_id/measures", nil
  defresource "archive_policy", "metric", "/v1/archive_policy", nil
  defresource "archive_policy_rule", "metric", "/v1/archive_policy_rule", nil
  defresource "resource", "metric", "/v1/resource/:type", nil, history: {:get, "/:id/history"}
  defresource "capability", "metric", "/v1/capabilities", nil, only: [:list]

  defresource "aggregation_resource_metric", "metric", "/v1/aggregation/resource/:resource_type/metric/:metric_type", nil

end
