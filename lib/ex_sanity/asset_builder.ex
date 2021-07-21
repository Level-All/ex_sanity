defmodule ExSanity.AssetBuilder do
  def file_base, do: ExSanity.Config.resolve(:file_base)
  def project_id, do: ExSanity.Config.resolve(:project_id)
  def dataset, do: ExSanity.Config.resolve(:dataset)

  def image_url(image_ref_or_url), do: build_url(image_ref_or_url, fn asset -> build_image_url(asset) end)
  def file_url(file_ref_or_url), do: build_url(file_ref_or_url, fn asset -> build_file_url(asset) end)

  def build_url(image_ref_or_url, build_url_fn) do
    if (String.contains?(image_ref_or_url, file_base())) do
      image_ref_or_url
    else
      build_url_fn.(image_ref_or_url)
    end
  end

  def build_image_url(image_ref) do
    %{
      id: id,
      width: width,
      height: height,
      format: format
    } = parse_image_asset(image_ref)

    filename = "#{id}-#{width}x#{height}.#{format}"

    "#{file_base()}/images/#{project_id()}/#{dataset()}/#{filename}"
  end

  def build_file_url(file_ref) do
    %{
      id: id,
      format: format
    } = parse_file_asset(file_ref)

    filename = "#{id}.#{format}"

    "#{file_base()}/files/#{project_id()}/#{dataset()}/#{filename}"
  end

  defp parse_image_asset(image_ref) do
    [_type, id, width_x_height, format] = String.split(image_ref, "-")

    [width, height] = String.split(width_x_height, "x")

    %{
      id: id,
      width: width,
      height: height,
      format: format
    }
  end

  defp parse_file_asset(file_ref) do
    [_type, id, format] = String.split(file_ref, "-")

    %{
      id: id,
      format: format
    }
  end
end
