defmodule Openstack.Cli do

  import Maybe

  @fields %{
    user: ~w(name id enabled domain_id email),
    project: ~w(name id enabled domain_id),
    role: ~w(name id),
    server: ~w(name id),
    server_detail: ~w(name id OS-EXT-SRV-ATTR:host status tenant_id),
    network: ~w(name id status provider:network_type tenant_id),
    subnet: ~w(name id status cider tenant_id gateway_ip network_id),
    flavor: ~w(name id),
    image: ~w(name id status visibility owner),
    flavor_detail: ~w(name id vcpus ram swap disk),
    floatingip: ~w(floating_ip_address id tenant_id status),
    domain: ~w(name id enabled),
    volume: ~w(name id),
    volume_detail: ~w(name id size user_id),
    router: ~w(name id status tenant_id),
    firewall_rule: ~w(name id action firewall_policy_id tenant_id),
    firewall_policy: ~w(name id action tenant_id),
    vpn_ipsecpolicy: ~w(id tenant_id encapsulation_mode encryption_algorithm),
    vpn_ikepolicy: ~w(id auth_algorithm description encryption_algorithm),
    security_group: ~w(id name tenant_id),
    security_group_rule: ~w(id direction security_group_id tenant_id),
    port: ~w(id device_id device_owner tenatn_id),
  }

  def main(args) do
    keys = [:os_username, :os_password, :os_user_domain_name, :os_auth_url, :os_region]
    env = [
      os_username: System.get_env("OS_USERNAME"),
      os_password: System.get_env("OS_PASSWORD"),
      os_project_name: System.get_env("OS_PROJECT_NAME") || System.get_env("OS_TENANT_NAME"),
      os_domain_name: System.get_env("OS_DOMAIN_NAME") || System.get_env("OS_USER_DOMAIN_NAME") || "Default",
      os_user_domain_name: System.get_env("OS_USER_DOMAIN_NAME") || "Default",
      os_auth_url: String.replace(System.get_env("OS_AUTH_URL"), "v2.0", "v3"),
      os_region: System.get_env("OS_REGION") || "RegionOne"
    ]

    {options, argv, _} = OptionParser.parse(args)

    case argv do
      [] ->
        %URI{host: host, port: port} = URI.parse env[:os_auth_url]
        repl(env, "(#{env[:os_username]}@#{host}:#{port}) ")
      [resource, action | args] ->
        try_exec(resource, action, args, Keyword.merge(env, options), Keyword.drop(options, keys)) |> pretty(resource)
      _ ->
        IO.puts "usage: openstack server list"
    end
  end

  def get_fields(resource) do
    Dict.get(@fields, resource |> String.replace("-", "_") |> String.to_atom)
  end

  def try_exec(resource, action, args, options, params) do
    params = Enum.into(params, %{})
    method = String.to_atom("#{String.replace(resource, "-", "_")}_#{String.replace(action, "-", "_")}")
    module = Enum.find [Openstack.Keystone,
                        Openstack.Neutron,
                        Openstack.Nova,
                        Openstack.Cinder,
                        Openstack.Ceilometer,
                        Openstack.Glance,
                        Openstack.Swift], fn (x)->
      Keyword.has_key?(x.__info__(:functions), method) end
    if module do
      user = %{name: options[:os_username], password: options[:os_password]}
      if options[:os_user_domain_name] do
        user = Dict.put user, :domain, %{name: options[:os_user_domain_name]}
      end
      scope = nil
      if options[:os_project_name] do
        scope = %{project: %{name: options[:os_project_name], domain: %{name: options[:os_domain_name]}}}
      end
      Openstack.authenticate(options[:os_auth_url], user, scope)
        |> ok(fn(token)-> apply(module, method, [token, options[:os_region]] ++ args ++ [params]) end)
    else
      {:error, "command not found"}
    end
  end

  def pretty(result, resource) do
    fields = get_fields(resource)
    case result do
      {:ok, result} ->
        cond do
          fields && is_list(result) -> IO.puts Table.table(Enum.map(result, &(Dict.take(&1, fields))), :unicode)
          true -> IO.puts Table.table(result, :unicode)
        end
      {:error, %HTTPoison.Error{reason: reason}} -> IO.puts reason
      {:error, error} when is_bitstring error -> IO.puts error
      {:error, error} -> IO.inspect error
      x -> IO.inspect x
    end
  end

  def repl(env, prompt) do
    IO.write prompt
    case IO.read :line do
      :eof -> IO.puts "quit"
      x ->
        input = String.strip x, ?\n
        {options, argv, _} = OptionParser.parse(OptionParser.split input)
        case argv do
          [resource, action | args] ->
            try_exec(resource, action, args, env, options) |> pretty(resource)
          _ -> IO.puts "usage: server list"
        end
        repl(env, prompt)
    end
  end
end
