defmodule ExSanity.AssetBuilder do
  def file_base, do: ExSanity.config()[:file_base]
  def project_id, do: ExSanity.config()[:project_id]
  def dataset, do: ExSanity.config()[:dataset]

  def image_url(image_asset_or_url), do: build_url(image_asset_or_url, fn asset -> build_image_url(asset) end)
  def file_url(file_asset_or_url), do: build_url(file_asset_or_url, fn asset -> build_file_url(asset) end)

  def build_url(asset_or_url, build_url_fn) do
    if (String.contains?(asset_or_url, file_base())) do
      asset_or_url
    else
      build_url_fn.(asset_or_url)
    end
  end

  def build_image_url(asset) do
    %{
      id: id,
      width: width,
      height: height,
      format: format
    } = parse_image_asset(asset)

    filename = "#{id}-#{width}x#{height}.#{format}"

    "#{file_base()}/images/#{project_id()}/#{dataset()}/#{filename}"
  end

  def build_file_url(asset) do
    %{
      id: id,
      format: format
    } = parse_file_asset(asset)

    filename = "#{id}.#{format}"

    "#{file_base()}/files/#{project_id()}/#{dataset()}/#{filename}"
  end

  defp parse_image_asset(image_asset) do
    asset_id = image_asset["_ref"]

    [_type, id, width_x_height, format] = String.split(asset_id, "-")

    [width, height] = String.split(width_x_height, "x")

    %{
      id: id,
      width: width,
      height: height,
      format: format
    }
  end

  defp parse_file_asset(file_asset) do
    asset_id = file_asset["_ref"]

    [_type, id, format] = String.split(asset_id, "-")

    %{
      id: id,
      format: format
    }
  end
end
