defmodule InertiaWeb.Utils do
  @moduledoc false
  def errors_from_changeset(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def pagination_links(%{total_pages: total_pages} = page, path) when total_pages > 1 do
    for n <- 1..total_pages do
      %{active: page.page_number == n, label: n, url: page_url(page, n, path)}
    end
  end

  def pagination_links(_page, _path), do: []

  defp page_url(current_page, n, _) when current_page == n, do: nil
  defp page_url(_current_page, n, path), do: "#{path}?page=#{n}"
end