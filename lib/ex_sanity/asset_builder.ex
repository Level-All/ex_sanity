defmodule ExSanity.AssetBuilder do
  def file_base, do: ExSanity.Config.resolve(:file_base)
  def project_id, do: ExSanity.Config.resolve(:project_id)
  def dataset, do: ExSanity.Config.resolve(:dataset)

  def image_url(image, opts \\ nil)

  def image_url(image = %{"asset" => _asset}, opts) do
    options = make_options(image, opts)
    apply_options(image["asset"]["url"], options)
  end

  def image_url(image_ref_or_url, opts) do
    if String.contains?(image_ref_or_url, file_base()) do
      image_ref_or_url
    else
      build_image_url(image_ref_or_url)
    end
    |> apply_options(opts)
  end

  def file_url(file_ref_or_url) do
    if String.contains?(file_ref_or_url, file_base()) do
      file_ref_or_url
    else
      build_file_url(file_ref_or_url)
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

  @spec_name_to_url_name_mapping %{
    width: "w",
    height: "h",
    format: "fm",
    download: "dl",
    blur: "blur",
    sharpen: "sharpen",
    invert: "invert",
    orientation: "or",
    min_height: "min-h",
    max_height: "max-h",
    min_width: "min-w",
    max_width: "max-w",
    quality: "q",
    fit: "fit",
    crop: "crop",
    saturation: "sat",
    auto: "auto",
    dpr: "dpr",
    pad: "pad"
  }

  def make_options(_image, opts) do
    # TODO: Handle crops and hotspots like:
    # https://github.com/sanity-io/image-url/blob/main/src/urlForImage.ts
    opts
  end

  def apply_options(url, nil), do: url

  def apply_options(url, opts), do: "#{url}?#{build_url_params_from_opts(opts)}"

  def build_url_params_from_opts(opts) do
    Enum.reduce(@spec_name_to_url_name_mapping, %{}, fn {opt_key, url_key}, map ->
      if opts[opt_key] do
        Map.put(map, url_key, opts[opt_key])
      else
        map
      end
    end)
    |> URI.encode_query()
  end
end
