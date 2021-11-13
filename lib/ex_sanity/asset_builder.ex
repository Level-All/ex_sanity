defmodule ExSanity.AssetBuilder do
  @spec_name_to_url_name_mapping [
    {:width, "w"},
    {:height, "h"},
    {:format, "fm"},
    {:download, "dl"},
    {:blur, "blur"},
    {:sharpen, "sharpen"},
    {:invert, "invert"},
    {:orientation, "or"},
    {:min_height, "min-h"},
    {:max_height, "max-h"},
    {:min_width, "min-w"},
    {:max_width, "max-w"},
    {:quality, "q"},
    {:fit, "fit"},
    {:crop, "crop"},
    {:saturation, "sat"},
    {:auto, "auto"},
    {:dpr, "dpr"},
    {:pad, "pad"}
  ]

  defp file_base, do: ExSanity.Config.resolve(:file_base)
  defp project_id, do: ExSanity.Config.resolve(:project_id)
  defp dataset, do: ExSanity.Config.resolve(:dataset)

  @doc """
  Same as `url_for_file/1` but returns the value directly,
  or raises an exception if the image can't be processed.
  """
  def url_for_file!(spec) do
    case url_for_file(spec) do
      {:ok, url} -> url
      {:error, error} -> raise Atom.to_string(error)
    end
  end

  @doc """
  Converts a Sanity file into an file url.

  It allows you to pass the image object directly,
  or to pass it on the :source key.
  """
  def url_for_file(%{source: source}), do: url_for_file(source)

  def url_for_file(source) do
    case parse_file_asset(source["asset"]) do
      {:ok,
       %{
         id: id,
         format: format
       }} ->
        {:ok, "#{file_base()}/files/#{project_id()}/#{dataset()}/#{id}.#{format}"}

      error ->
        error
    end
  end

  defp parse_file_asset(%{"_id" => id}), do: parse_file_ref(id)

  defp parse_file_asset(%{"_ref" => ref}), do: parse_file_ref(ref)

  defp parse_file_asset(%{
         "url" => url
       }) do
    url
    |> String.split("/")
    |> List.last()
    |> case do
      ref when is_binary(ref) ->
        "file-#{Regex.replace(~r/\.([a-zA-Z0-9]+)$/, ref, "-\\1")}"
        |> parse_file_ref

      _ ->
        {:error, :malformed_asset}
    end
  end

  defp parse_file_asset(_), do: {:error, :malformed_asset}

  defp parse_file_ref(ref) do
    case String.split(ref, "-") do
      [_type, id, format] ->
        {:ok, %{id: id, format: format}}

      _ ->
        {:error, :malformed_asset}
    end
  end

  @doc """
  Same as `url_for_image/1` but returns the value directly,
  or raises an exception if the image can't be processed.
  """
  def url_for_image!(spec) do
    case url_for_image(spec) do
      {:ok, url} -> url
      {:error, error} -> raise Atom.to_string(error)
    end
  end

  @doc """
  Converts a Sanity image into an image url.

  It allows you to pass the image object directly,
  or to pass it on the :source key, with an optional
  :transforms key. Transforms map to options that can
  be passed in url params, documented here:
  https://www.sanity.io/docs/image-urls
  """
  def url_for_image(spec = %{source: source}) do
    with {:ok, asset} <- parse_image_asset(source["asset"]),
         {:ok, crop} <- parse_crop(source["crop"]),
         {:ok, hotspot} <- parse_hotspot(source["hotspot"]),
         {:ok, transforms} <- parse_transforms(spec[:transforms]) do
      make_image_url(%{
        asset: asset,
        crop: crop,
        hotspot: hotspot,
        transforms: transforms
      })
    else
      err -> err
    end
  end

  def url_for_image(source), do: url_for_image(%{source: source})

  defp parse_transforms(nil), do: {:ok, %{}}

  defp parse_transforms(transforms), do: {:ok, transforms}

  defp parse_hotspot(%{
         "x" => x,
         "y" => y,
         "height" => height,
         "width" => width
       }) do
    {:ok,
     %{
       x: x,
       y: y,
       height: height,
       width: width
     }}
  end

  defp parse_hotspot(_) do
    {:ok,
     %{
       x: 0.5,
       y: 0.5,
       height: 1.0,
       width: 1.0
     }}
  end

  defp parse_crop(%{
         "bottom" => bottom,
         "left" => left,
         "right" => right,
         "top" => top
       }) do
    {:ok,
     %{
       bottom: bottom,
       left: left,
       right: right,
       top: top
     }}
  end

  defp parse_crop(nil) do
    {:ok,
     %{
       bottom: 0,
       left: 0,
       right: 0,
       top: 0
     }}
  end

  defp parse_image_asset(%{"_id" => id}), do: parse_image_ref(id)

  defp parse_image_asset(%{"_ref" => ref}), do: parse_image_ref(ref)

  defp parse_image_asset(%{
         "url" => url
       }) do
    url
    |> String.split("/")
    |> List.last()
    |> case do
      ref when is_binary(ref) ->
        "image-#{Regex.replace(~r/\.([a-z]+)$/, ref, "-\\1")}"
        |> parse_image_ref

      _ ->
        {:error, :malformed_asset}
    end
  end

  defp parse_image_asset(_), do: {:error, :malformed_asset}

  defp parse_image_ref(ref) do
    case String.split(ref, "-") do
      [_type, id, width_x_height, format] ->
        case String.split(width_x_height, "x") do
          [width, height] ->
            {:ok,
             %{
               id: id,
               width: String.to_integer(width),
               height: String.to_integer(height),
               format: format
             }}

          _ ->
            {:error, :malformed_asset}
        end

      _ ->
        {:error, :malformed_asset}
    end
  end

  defp make_image_url(%{
         asset:
           asset = %{
             id: _id,
             width: width,
             height: height,
             format: _format
           },
         crop: crop,
         hotspot: hotspot,
         transforms: transforms
       }) do
    {:ok, fitted_crop} =
      fit_crop(%{
        width: width,
        height: height,
        crop: crop
      })

    {:ok, fitted_hotspot} =
      fit_hotspot(%{
        width: width,
        height: height,
        hotspot: hotspot
      })

    # If irrelevant, or if we are requested to: don't perform crop/fit based on
    # the crop/hotspot.
    if !(transforms[:rect] || transforms[:focal_point] || transforms[:ignore_image_params] ||
           transforms[:crop]) do
      {:ok, fitted} =
        fit(%{
          crop: fitted_crop,
          hotspot: fitted_hotspot,
          transforms: transforms
        })

      Map.merge(%{asset: asset}, fitted)
      |> spec_to_image_url()
    else
      spec_to_image_url(Map.merge(%{asset: asset}, transforms))
    end
  end

  defp fit_crop(%{
         width: width,
         height: height,
         crop: %{
           bottom: bottom,
           left: left,
           right: right,
           top: top
         }
       }) do
    crop_left = round(left * width)
    crop_top = round(top * height)
    crop_width = round(width - right * width - crop_left)
    crop_height = round(height - bottom * height - crop_top)

    {:ok,
     %{
       left: crop_left,
       top: crop_top,
       width: crop_width,
       height: crop_height
     }}
  end

  defp fit_hotspot(%{
         width: width,
         height: height,
         hotspot: %{
           height: hotspot_height,
           width: hotspot_width,
           x: hotspot_x,
           y: hotspot_y
         }
       }) do
    hotspot_vertical_radius = hotspot_height * height / 2
    hotspot_horizontal_radius = hotspot_width * height / 2
    hotspot_center_x = hotspot_x * width
    hotspot_center_y = hotspot_y * height

    {:ok,
     %{
       left: hotspot_center_x - hotspot_horizontal_radius,
       top: hotspot_center_y - hotspot_vertical_radius,
       right: hotspot_center_x + hotspot_horizontal_radius,
       bottom: hotspot_center_y + hotspot_vertical_radius
     }}
  end

  defp fit(%{
         crop:
           crop = %{
             left: crop_left,
             top: crop_top,
             width: crop_width,
             height: crop_height
           },
         hotspot: %{
           left: hotspot_left,
           top: hotspot_top,
           right: hotspot_right,
           bottom: hotspot_bottom
         },
         transforms: transforms
       }) do
    img_width = transforms[:width]
    img_height = transforms[:height]

    if !(img_width && img_height) do
      {:ok,
       %{
         width: img_width,
         height: img_height,
         rect: crop
       }}
    else
      # If we are here, that means aspect ratio is locked and fitting will be a bit harder
      desired_aspect_ratio = img_width / img_height
      crop_aspect_ratio = crop_width / crop_height

      crop_rect =
        if crop_aspect_ratio > desired_aspect_ratio do
          # The crop is wider than the desired aspect ratio.
          # That means we are cutting from the sides.
          height = round(crop_height)
          width = round(height * desired_aspect_ratio)
          top = max(0, round(crop_top))

          # Center output horizontally over hotspot
          hotspot_x_center = round((hotspot_right - hotspot_left) / 2 + hotspot_left)
          left = max(0, round(hotspot_x_center - width / 2))

          left =
            cond do
              left < crop_left ->
                crop_left

              left + width > crop_left + crop_width ->
                crop_left + crop_width - width

              true ->
                left
            end

          %{
            left: left,
            top: top,
            width: width,
            height: height
          }
        else
          # The crop is taller than the desired ratio, we are cutting from top and bottom
          width = crop_width
          height = round(width / desired_aspect_ratio)
          left = max(0, round(crop_left))

          # Center output vertically over hotspot
          hotspot_y_center = round((hotspot_bottom - hotspot_top) / 2 + hotspot_top)
          top = max(0, round(hotspot_y_center - height / 2))

          # Keep output rect within crop
          top =
            cond do
              top < crop_top ->
                crop_top

              top + height > crop_top + crop_height ->
                crop_top + crop_height - height

              true ->
                top
            end

          %{
            left: left,
            top: top,
            width: width,
            height: height
          }
        end

      {:ok,
       %{
         width: img_width,
         height: img_height,
         rect: crop_rect
       }}
    end
  end

  defp spec_to_image_url(
         spec = %{
           asset: %{
             id: id,
             width: width,
             height: height,
             format: format
           }
         }
       ) do
    filename = "#{id}-#{width}x#{height}.#{format}"
    base_url = "#{file_base()}/images/#{project_id()}/#{dataset()}/#{filename}"

    rect_param =
      if spec[:rect] do
        # Only bother url with a crop if it actually crops anything
        %{left: rect_left, top: rect_top, width: rect_width, height: rect_height} = spec[:rect]

        is_effective_crop =
          rect_left !== 0 || rect_top !== 0 || rect_height !== height || rect_width !== width

        if is_effective_crop do
          {"rect", "#{rect_left},#{rect_top},#{rect_width},#{rect_height}"}
        else
          nil
        end
      else
        nil
      end

    focal_point_param =
      if spec[:focal_point] do
        [{"fp-x", spec[:focal_point][:x]}, {"fp-y", spec[:focal_point][:y]}]
      else
        nil
      end

    flip_param =
      if spec[:flip_horizontal] || spec[:flip_vertical] do
        {"flip",
         "#{if spec[:flip_horizontal], do: "h", else: ""}#{
           if spec[:flip_vertical], do: "v", else: ""
         }"}
      end

    formatted_params =
      [
        rect_param,
        focal_point_param,
        flip_param
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)

    # Map from spec name to url param name, and allow using the actual param name as an alternative
    params =
      Enum.reduce(@spec_name_to_url_name_mapping, [], fn {transform_key, param_key}, params ->
        cond do
          spec[transform_key] -> params ++ [{param_key, spec[transform_key]}]
          spec[param_key] -> params ++ [{param_key, spec[spec[param_key]]}]
          true -> params
        end
      end)

    image_url =
      (formatted_params ++ params)
      |> URI.encode_query()
      |> case do
        "" -> base_url
        url_params -> "#{base_url}?#{url_params}"
      end

    {:ok, image_url}
  end
end
