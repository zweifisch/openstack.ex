defmodule Openstack.Swift do

  import Maybe

  def request(token, region, method, path, params, body \\ "") do
    Openstack.request(token, region, "object-store", method, path, body, Dict.merge(params, format: "json"))
  end

  def bucket_list(token, region, params \\ []) do
    request(token, region, :get, "/", params)
  end

  def bucket_show(token, region, id, params \\ []) do
    request(token, region, :get, "/" <> id, params)
  end

  def bucket_create(token, region, params \\ %{}) do
    case params do
      %{name: name} ->
        request(token, region, :put, "/" <> name, params)
      _ -> {:error, "name is required"}
    end
  end

  def bucket_delete(token, region, id, params \\ %{}) do
    request(token, region, :delete, "/" <> id, params)
  end

  def bucket_info(token, region, id, params \\ %{}) do
    Openstack.request!(token, region, "object-store", :head, "/" <> id, "", params)
      |> ok(fn (%{headers: headers, status_code: _}) ->
        headers
          |> Enum.filter(fn({key, _})-> String.starts_with?(key , "X") end)
          |> Enum.into(%{})
      end)
  end

  def bucket_upload(token, region, path, file, params \\ %{}) do
    File.read(Path.expand(file))
      |> ok(fn(file)-> Openstack.request!(token, region, "object-store", :put, "/" <> path, file, params) end)
      |> ok(fn(%{headers: headers})-> Enum.into(headers, %{}) end)
  end

  def object_delete(token, region, path, params \\ %{}) do
    request(token, region, :delete, "/" <> path, params)
  end

end
