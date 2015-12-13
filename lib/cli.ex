defmodule Openstack.Cli do

  @fields %{
    user: ~w(name id enabled domain_id email),
    role: ~w(name id),
    server: ~w(name id),
    "server-detail": ~w(id name OS-EXT-SRV-ATTR:host status tenant_id),
    network: ~w(name id status provider:network_type tenant_id),
    subnet: ~w(name id status cider tenant_id gateway_ip network_id),
  }

  def main(args) do
    keys = [:os_username, :os_password, :os_user_domain_name, :os_auth_url, :os_region]
    env = [
      os_username: System.get_env("OS_USERNAME"),
      os_password: System.get_env("OS_PASSWORD"),
      os_project_name: System.get_env("OS_PROJECT_NAME"),
      os_user_domain_name: System.get_env("OS_USER_DOMAIN_NAME") || "Default",
      os_auth_url: String.replace(System.get_env("OS_AUTH_URL"), "v2.0", "v3"),
      os_region: System.get_env("OS_REGION") || "RegionOne"
    ]

    {options, argv, _} = OptionParser.parse(args)

    case argv do
      [] ->
        %URI{host: host, port: port} = URI.parse env[:os_auth_url]
        repl(env, "(#{env[:os_username]}@#{host}:#{port}) ")
      [resource, action] -> try_exec(resource, action, Keyword.merge(env, options), Keyword.drop(options, keys))
        |> pretty(Dict.get(@fields, String.to_atom(resource)))
      [resource, action, id] -> try_exec(resource, action, id, Keyword.merge(env, options), Keyword.drop(options, keys))
        |> pretty(Dict.get(@fields, String.to_atom(resource)))
      _ -> IO.puts "usage: openstack server list"
    end
  end

  def try_exec(resource, action, id \\ nil, options, params) do
    method = String.to_atom("#{String.replace(resource, "-", "_")}_#{String.replace(action, "-", "_")}")
    module = Enum.find [Openstack.Keystone,
                        Openstack.Neutron,
                        Openstack.Nova,
                        Openstack.Cinder,
                        Openstack.Ceilometer,
                         Openstack.Glance], fn (x)->
      Keyword.has_key?(x.__info__(:functions), method) end
    if module do
      user = %{name: options[:os_username], password: options[:os_password]}
      if options[:os_user_domain_name] do
        user = Dict.put user, :domain, %{name: options[:os_user_domain_name]}
      end
      scope = nil
      if options[:os_project_name] do
        scope = %{project: %{name: options[:os_project_name]}}
      end
      case Openstack.authenticate(options[:os_auth_url], user, scope) do
        {:ok, token} ->
          case id do
            nil -> apply(module, method, [token, options[:os_region], params])
            x -> apply(module, method, [token, options[:os_region], x, params])
          end
        x -> x
      end
    else
      {:error, "command not found"}
    end
  end

  def pretty(result, fields) do
    case result do
      {:ok, result} ->
        cond do
          fields && is_list(result) -> IO.puts Table.table(Enum.map(result, &(Dict.take(&1, fields))), :unicode)
          fields && is_map(result) -> IO.puts Table.table(Dict.take(result, fields), :unicode)
          true -> IO.puts Table.table(result, :unicode)
        end
      {:error, %HTTPoison.Error{reason: reason}} -> IO.puts reason
      {:error, error} -> IO.inspect error
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
          [resource, action] -> try_exec(resource, action, env, options)
            |> pretty(Dict.get(@fields, String.to_atom(resource)))
          [resource, action, id] -> try_exec(resource, action, id, env, options)
            |> pretty(Dict.get(@fields, String.to_atom(resource)))
          _ -> ""
        end
        repl(env, prompt)
    end
  end
end
