defmodule ExSanity.AssetBuilder do
  def file_base, do: ExSanity.Config.resolve(:file_base)
  def project_id, do: ExSanity.Config.resolve(:project_id)
  def dataset, do: ExSanity.Config.resolve(:dataset)

  def image_url(%{
        source: %{
          "asset" => %{
            "_ref" => ref
          },
          "crop" => %{
            "bottom" => crop_bottom,
            "left" => crop_left,
            "right" => crop_right,
            "top" => crop_top
          },
          "hotspot" => %{
            "height" => hotspot_height,
            "width" => hotspot_width,
            "x" => hotspot_x,
            "y" => hotspot_y
          }
        },
        transforms: transforms
      }) do
    asset =
      %{
        id: _id,
        width: width,
        height: height,
        format: _format
      } = parse_image_asset(ref)

    cleft = round(crop_left * width)
    ctop = round(crop_top * height)
    cwidth = round(width - crop_right * width - cleft)
    cheight = round(height - crop_bottom * height - ctop)

    crop = %{
      left: cleft,
      top: ctop,
      width: cwidth,
      height: cheight
    }

    hotspot_vertical_radius = hotspot_height * height / 2
    hotspot_horizontal_radius = hotspot_width * height / 2
    hotspot_center_x = hotspot_x * width
    hotspot_center_y = hotspot_y * height

    hotspot = %{
      left: hotspot_center_x - hotspot_horizontal_radius,
      top: hotspot_center_y - hotspot_vertical_radius,
      right: hotspot_center_x + hotspot_horizontal_radius,
      bottom: hotspot_center_y + hotspot_vertical_radius
    }

    # If irrelevant, or if we are requested to: don't perform crop/fit based on
    # the crop/hotspot.
    if !(transforms[:rect] || transforms[:focal_point] || transforms[:ignore_image_params] ||
           transforms[:crop]) do
      spec_to_image_url(
        Map.merge(
          %{asset: asset},
          fit(%{
            crop: crop,
            hotspot: hotspot,
            transforms: transforms
          })
        )
      )
    else
      spec_to_image_url(Map.merge(%{asset: asset}, transforms))
    end
  end

  # def image_url(image = %{"asset" => _asset}, opts) do
  #   options = make_options(image, opts)
  #   apply_options(image["asset"]["url"], options)
  # end

  # def image_url(image_ref_or_url, opts) do
  #   if String.contains?(image_ref_or_url, file_base()) do
  #     image_ref_or_url
  #   else
  #     build_image_url(image_ref_or_url)
  #   end
  #   |> apply_options(opts)
  # end

  # def file_url(file_ref_or_url) do
  #   if String.contains?(file_ref_or_url, file_base()) do
  #     file_ref_or_url
  #   else
  #     build_file_url(file_ref_or_url)
  #   end
  # end

  # def build_image_url(image_ref) do
  #   %{
  #     id: id,
  #     width: width,
  #     height: height,
  #     format: format
  #   } = parse_image_asset(image_ref)

  #   filename = "#{id}-#{width}x#{height}.#{format}"

  #   "#{file_base()}/images/#{project_id()}/#{dataset()}/#{filename}"
  # end

  # def build_file_url(file_ref) do
  #   %{
  #     id: id,
  #     format: format
  #   } = parse_file_asset(file_ref)

  #   filename = "#{id}.#{format}"

  #   "#{file_base()}/files/#{project_id()}/#{dataset()}/#{filename}"
  # end

  defp parse_image_asset(image_ref) do
    [_type, id, width_x_height, format] = String.split(image_ref, "-")

    [width, height] = String.split(width_x_height, "x")

    %{
      id: id,
      width: String.to_integer(width),
      height: String.to_integer(height),
      format: format
    }
  end

  # defp parse_file_asset(file_ref) do
  #   [_type, id, format] = String.split(file_ref, "-")

  #   %{
  #     id: id,
  #     format: format
  #   }
  # end

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

  def fit(%{
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
      %{
        width: img_width,
        height: img_height,
        rect: crop
      }
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

      %{
        width: img_width,
        height: img_height,
        rect: crop_rect
      }
    end
  end

  def spec_to_image_url(
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

    (formatted_params ++ params)
    |> URI.encode_query()
    |> case do
      "" -> base_url
      url_params -> "#{base_url}?#{url_params}"
    end
  end
end
