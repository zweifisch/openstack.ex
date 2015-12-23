defmodule Openstack do

  import Maybe

  @doc """
  the base of all authenticate functions
  """
  def authenticate(url, body) when is_map(body) do
    case HTTPoison.post("#{url}/auth/tokens", Poison.encode!(body), [{"Content-Type", "application/json"}], proxy: System.get_env("http_proxy")) do
      {:ok, %HTTPoison.Response{status_code: 201, headers: headers, body: body}} ->
        Poison.decode(body)
          |> ok fn(%{"token" => token})-> Dict.put_new(token, "token", Enum.into(headers, %{})["X-Subject-Token"]) end
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
    endpoint(token, type)
      |> ok fn(endpoints) ->
        case Enum.find endpoints, &(&1["interface"] == interface && &1["region"] == region) do
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
    Openstack.endpoint(token, service, "public", region)
      |> ok fn(url)->
        HTTPoison.request(method, "#{url}#{path}", body || "",
                          [{"X-Auth-Token", token["token"]}] ++ headers,
                          [params: params, proxy: System.get_env("http_proxy")])
      end
  end

  def request(token, region, service, method, path, body \\ "", params \\ [], headers \\ []) do
    Poison.encode(body)
      |> ok(fn(encoded)->
        request!(token, region, service, method, path,
                 encoded, params, [{"Content-Type", "application/json"}] ++ headers) end)
      |> ok(fn(%{body: body, status_code: code})->
          cond do
            body == "" && code < 400 -> "{}"
            code < 400 -> body
            true -> {:error, body}
          end
        end)
      |> ok(&Poison.decode/1)
  end

  defmacro defresource(name, service, path, singular, actions \\ []) do
    predef = [
      list: {:get, ""},
      create: {:post, ""},
      update: {:patch, "/:id"},
      show: {:get, "/:id"},
      delete: {:delete, "/:id"},
    ]
    cond do
      is_tuple(singular) ->
        {singular, plural} = singular
      true -> plural = "#{singular}s"
    end
    case Keyword.pop(actions, :only) do
      {nil, actions} -> actions = Keyword.merge(predef, actions)
      {only, actions} -> actions = Keyword.merge(Keyword.take(predef, only), actions)
    end
    Enum.map actions, fn {action, {method, segment}} ->
      args = []
      if segment =~ ~r/:id/ do
        args = [quote do: id]
      end
      if method in [:post, :patch, :put] do
        args = args ++ [quote do: body]
      end
      quote do
        def unquote(:"#{name}_#{action}")(token, region, unquote_splicing(args), params \\ []) do
          case Openstack.request(token, region, unquote(service), unquote(method),
                                 unquote(path) <> unquote((quote do: id) in args
                                                          && (quote do: (String.replace(unquote(segment), ":id", id)))
                                                          || segment),
                                 unquote((quote do: body) in args && (quote do: %{unquote(:"#{singular}") => body})),
                                 params) do
            {:ok, body} ->
              case unquote(action) do
                :list ->
                  {:ok, Dict.get(body, unquote(plural), body)}
                :delete -> {:ok, body}
                _ ->
                  {:ok, Dict.get(body, unquote(singular), body)}
              end
            x -> x
          end
        end
        def unquote(:"#{name}_#{action}!")(token, region, unquote_splicing(args), params \\ []) do
          Openstack.request(token, region, unquote(service), unquote(method),
                                 unquote(path) <> unquote((quote do: id) in args
                                                          && (quote do: (String.replace(unquote(segment), ":id", id)))
                                                          || segment),
                                 unquote((quote do: body) in args && (quote do: body)), params)
        end
      end
    end
  end

end
