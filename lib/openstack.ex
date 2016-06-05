defmodule Openstack do

  import Maybe

  @doc """
  the base of all authenticate functions
  """
  def authenticate(url, body) when is_map(body) do
    case HTTPoison.post("#{url}/auth/tokens", Poison.encode!(body), [{"Content-Type", "application/json"}], proxy: System.get_env("http_proxy")) do
      {:ok, %HTTPoison.Response{status_code: 201, headers: headers, body: body}} ->
        Poison.decode(body)
          |> ok(fn(%{"token" => token})-> Dict.put_new(token, "token", Enum.into(headers, %{})["X-Subject-Token"]) end)
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        Poison.decode(body)
          |> ok(fn(decoded) -> {:error, %{code: code, body: decoded}} end)
          |> error(fn(_) -> %{code: code, body: body} end)
      x -> x
    end
  end

  @doc """
  password auth with scope
  """
  def authenticate(url, user, scope) do
    body = %{auth:
             %{identity:
               %{methods: ["password"],
                 password: %{user: user}}}}
    if scope do
      body = put_in(body, [:auth, :scope], scope)
    end
    authenticate(url, body)
  end

  @doc """
  password auth with project scope

      authenticate("http://127.0.0.1:5000/v3", "admin", "secret", "admin", "Default")
  """
  def authenticate(url, name, password, project, domain) do
    authenticate(url, %{name: name, password: password},
                 %{project: %{name: project, domain: %{name: domain}}})
  end

  @doc """
  password auth with project scope

      authenticate("http://127.0.0.1:5000/v3", "admin", "secret", "services", "Default", "Default")
  """
  def authenticate(url, name, password, project, domain, user_domain) do
    authenticate(url, %{name: name, password: password, domain: %{name: user_domain}},
                 %{project: %{name: project, domain: %{name: domain}}})
  end

  def endpoint(token, type) do
    case Enum.find(token["catalog"], &(&1["type"] == type)) do
      %{"endpoints" => endpoints} -> {:ok, endpoints}
      nil -> {:error, "endpoint for #{type} not found"}
    end
  end

  def endpoint(token, type, interface, region) do
    with {:ok, endpoints} <- endpoint(token, type) do
      case Enum.find endpoints, &(&1["interface"] == interface and &1["region"] == region) do
        %{"url" => url} ->
          case type do
            "identity" -> {:ok, String.replace(url, "v2.0", "v3")}
            _ -> {:ok, url}
          end
        nil -> {:error, "#{interface} endpoint for #{type} not found in region #{region}"}
      end
    end
  end

  def request!(token, region, service, method, path, body \\ "", params \\ [], headers \\ []) do
    with {:ok, url} <- Openstack.endpoint(token, service, "public", region) do
      HTTPoison.request method, "#{url}#{path}", body || "", [{"X-Auth-Token", token["token"]}] ++ headers,
        params: params,
        proxy: System.get_env("http_proxy"),
        follow_redirect: true,
        max_redirect: 3,
        recv_timeout: 60000
    end
  end

  defp encode(nil), do: {:ok, nil}
  defp encode(false), do: {:ok, nil}
  defp encode({:file, path}), do: {:ok, {:file, path}}
  defp encode(body), do: Poison.encode(body)

  defp format_error(body, code) do
    with {:ok, body} <- Poison.decode(body) do
      case body do
        %{"error" => %{"message" => message}} -> {:error, message, code}
        %{"itemNotFound" => %{"message" => message}} -> {:error, message, code}
        _ -> {:error, body}
      end
    end
  end

  def request(token, region, service, method, path, body \\ nil, params \\ [], headers \\ []) do
    with {:ok, encoded} <- encode(body),
         {:ok, %{body: body, status_code: code}} <- request!(token, region, service, method, path, encoded, params,
           [{"Content-Type", "application/json"}] ++ headers) do
      cond do
        body == "" and code < 400 -> %{}
        code < 400 -> Poison.decode(body)
        true -> format_error(body, code)
      end
    end
  end

  defp extract_params(path) do
    Regex.scan(~r/:([^\:\/]+)/, path, capture: :all_but_first) |> List.flatten
  end

  defp normalize_actions(actions, singular) do
    {singular, plural} =
      case singular do
        {s, p} -> {s, p}
        nil -> {nil, nil}
        s when is_binary(s) -> {s, "#{singular}s"}
      end
    predef = [
      list: [:get, "", plural],
      create: [:post, "", singular],
      update: [:patch, "/:id", singular],
      show: [:get, "/:id", singular],
      delete: [:delete, "/:id", singular],
    ]
    actions = case Keyword.pop(actions, :only) do
      {nil, actions} -> Keyword.merge(predef, actions)
      {only, actions} -> Keyword.merge(Keyword.take(predef, only), actions)
    end

    Enum.map actions, fn
      {action, [method]} -> {action, method, "", singular}
      {action, [method, segment]} -> {action, method, segment, singular}
      {action, [method, segment, key]} -> {action, method, segment, key}
    end
  end

  defmacro defresource(name, service, path, singular, actions \\ []) do
    actions = normalize_actions actions, singular

    Enum.map actions, fn {action, method, segment, body_key} ->
      full_path = path <> segment
      path_params = extract_params full_path
      args = Enum.map path_params, &Macro.var(String.to_atom(&1), nil)
      if method in [:post, :patch, :put] do
        args = args ++ [quote do: body]
      end
      quote do
        def unquote(:"#{name}_#{action}")(token, region, unquote_splicing(args), params \\ []) do

          path =
            unquote(
              Enum.reduce path_params, full_path, fn(param, acc)->
                quote do: String.replace(unquote(acc), ":#{unquote(param)}", unquote(Macro.var(String.to_atom(param), nil)))
              end)

          with {:ok, body} <- Openstack.request(token, region, unquote(service), unquote(method), path,
                    unquote((quote do: body) in args && (quote do: unquote(body_key) && %{unquote(:"#{body_key}") => body} || body)),
                    params) do
            case unquote(action) do
              :delete -> {:ok, body}
              _ when is_list(body) -> {:ok, body}
              _ -> {:ok, Dict.get(body, unquote(body_key), body)}
            end
          end
        end
      end
    end
  end

end
