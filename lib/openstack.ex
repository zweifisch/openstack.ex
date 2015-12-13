defmodule Openstack do

  @doc """
  the base of all authenticate functions
  """
  def authenticate(url, body) when is_map(body) do
    case HTTPoison.post("#{url}/auth/tokens", Poison.encode!(body), [{"Content-Type", "application/json"}], proxy: System.get_env("http_proxy")) do
      {:ok, %HTTPoison.Response{status_code: 201, headers: headers, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"token" => token}} -> {:ok, Dict.put_new(token, "token", Enum.into(headers, %{})["X-Subject-Token"])}
        end
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        case Poison.decode(body) do
          {:ok, decoded} -> {:error, %{code: code, body: decoded}}
          _ -> {:error, %{code: code, body: body}}
        end
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
      body = put_in(body, [:auth, :identity, :scope], scope)
    end
    authenticate(url, body)
  end

  @doc """
  password auth with project scope

      authenticate("http://127.0.0.1:5000/v3", "admin", "secret", "admin")
  """
  def authenticate(url, name, password, project) do
    authenticate(url, %{name: name, password: password}, %{project: %{name: project}})
  end

  @doc """
  password auth with project scope

      authenticate("http://127.0.0.1:5000/v3", "admin", "secret", "services", "Default")
  """
  def authenticate(url, name, password, project, user_domain) do
    authenticate(url, %{name: name, password: password, domain: %{name: user_domain}},
                 %{project: %{name: project}})
  end

  def endpoint(token, type) do
    Enum.find token["catalog"], fn (x)-> x["type"] == type end
  end

  def endpoint(token, type, interface, region) do
    %{"url" => url} = Enum.find endpoint(token, type)["endpoints"], fn x->
      x["interface"] == interface && x["region"] == region
    end
    case type do
      "identity" -> String.replace(url, "v2.0", "v3")
      _ -> url
    end
  end

  def request(token, region, service, method, path, body \\ "", params \\ []) do
    url = Openstack.endpoint(token, service, "public", region) <> path
    case HTTPoison.request(method, url, body && Poison.encode!(body) || "",
                           [{"X-Auth-Token", token["token"]},
                            {"Content-Type", "application/json"}],
                           [params: params, proxy: System.get_env("http_proxy")]) do
      {:ok, %HTTPoison.Response{body: body, status_code: code}} ->
        case Poison.decode(body) do
          {:ok, decoded} ->
            cond do
              code < 400 -> {:ok, decoded}
              true -> {:error, decoded}
            end
          x -> x
        end
      x -> x
    end
  end

  defmacro defresource(name, service, path, singular, actions \\ [:list, :create, :show, :delete]) do
    predef = [
      [:list, :get, ""],
      [:create, :post, ""],
      [:show, :get, "/:id"],
      [:delete, :delete, "/:id"],
    ]
    cond do
      is_tuple(singular) ->
        {singular, plural} = singular
      true -> plural = "#{singular}s"
    end
    actions = Enum.map actions, fn
      action when is_list(action) -> action
      action -> Enum.find predef, fn [x,_,_]-> x == action end
    end
    Enum.map actions, fn [action, method, segment] ->
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
                                 unquote((quote do: body) in args && (quote do: body)), params) do
            {:ok, body} ->
              case unquote(action) do
                :list ->
                  {:ok, Dict.get(body, unquote(plural))}
                _ ->
                  {:ok, Dict.get(body, unquote(singular))}
              end
            x -> x
          end
        end
      end
    end
  end

end
