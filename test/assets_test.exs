defmodule ExSanity.AssetsTest do
  use ExUnit.Case

  def image_base do
    "#{ExSanity.Config.resolve(:file_base)}/images/#{ExSanity.Config.resolve(:project_id)}/#{ExSanity.Config.resolve(:dataset)}"
  end

  def file_base do
    "#{ExSanity.Config.resolve(:file_base)}/files/#{ExSanity.Config.resolve(:project_id)}/#{ExSanity.Config.resolve(:dataset)}"
  end

  def image_with_no_crop_specificed() do
    %{
      "_type" => "image",
      "asset" => %{
        "_ref" => "image-vK7bXJPEjVpL_C950gH1N73Zv14r7pYsbUdXl-4288x2848-jpg",
        "_type" => "reference"
      }
    }
  end

  def uncropped_image do
    %{
      "_type" => "image",
      "asset" => %{
        "_ref" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000-jpg",
        "_type" => "reference"
      },
      "crop" => %{
        "bottom" => 0.0,
        "left" => 0,
        "right" => 0,
        "top" => 0
      },
      "hotspot" => %{
        "height" => 0.3,
        "width" => 0.3,
        "x" => 0.3,
        "y" => 0.3
      }
    }
  end

  def materialized_asset_with_crop do
    %{
      "_type" => "image",
      "asset" => %{
        "_id" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000-jpg",
        "_type" => "sanity.imageAsset",
        "url" =>
          "https://cdn.sanity.io/images/ppsg7ml5/test/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg"
      },
      "crop" => %{
        "bottom" => 0.1,
        "left" => 0.1,
        "right" => 0.1,
        "top" => 0.1
      },
      "hotspot" => %{
        "height" => 0.3,
        "width" => 0.3,
        "x" => 0.3,
        "y" => 0.3
      }
    }
  end

  def asset_with_url do
    %{
      "_type" => "image",
      "asset" => %{
        "_type" => "sanity.imageAsset",
        "url" =>
          "https://cdn.sanity.io/images/ppsg7ml5/test/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg"
      },
      "crop" => %{
        "bottom" => 0.1,
        "left" => 0.1,
        "right" => 0.1,
        "top" => 0.1
      },
      "hotspot" => %{
        "height" => 0.3,
        "width" => 0.3,
        "x" => 0.3,
        "y" => 0.3
      }
    }
  end

  def cropped_image do
    %{
      "_type" => "image",
      "asset" => %{
        "_ref" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000-jpg",
        "_type" => "reference"
      },
      "crop" => %{
        "bottom" => 0.1,
        "left" => 0.1,
        "right" => 0.1,
        "top" => 0.1
      },
      "hotspot" => %{
        "height" => 0.3,
        "width" => 0.3,
        "x" => 0.3,
        "y" => 0.3
      }
    }
  end

  def cropped_landscape_image_rounding do
    %{
      "_type" => "image",
      "asset" => %{
        "_ref" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-3833x2555-jpg",
        "_type" => "reference"
      },
      "crop" => %{
        "bottom" => 0,
        "left" => 0,
        "right" => 0,
        "top" => 0
      },
      "hotspot" => %{
        "height" => 0.7281480823863636,
        "width" => 0.48536873219336263,
        "x" => 0.5858922039336789,
        "y" => 0.3640740411931818
      }
    }
  end

  def cropped_portrait_image_rounding do
    %{
      "_type" => "image",
      "asset" => %{
        "_ref" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-2555x3833-jpg",
        "_type" => "reference"
      },
      "crop" => %{
        "bottom" => 0,
        "left" => 0,
        "right" => 0,
        "top" => 0
      },
      "hotspot" => %{
        "width" => 0.7281480823863636,
        "height" => 0.48536873219336263,
        "x" => 0.3640740411931818,
        "y" => 0.5858922039336789
      }
    }
  end

  def no_hotspot_image do
    %{
      "_type" => "image",
      "asset" => %{
        "_ref" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000-jpg",
        "_type" => "reference"
      }
    }
  end

  def asset_document do
    %{
      "_id" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000-jpg",
      "_type" => "sanity.imageAsset",
      "assetId" => "Tb9Ew8CXIwaY6R1kjMvI0uRR",
      "extension" => "jpg",
      "metadata" => %{
        "dimensions" => %{
          "aspectRatio" => 1.5,
          "height" => 3000,
          "width" => 2000
        }
      },
      "mimeType" => "image/jpeg",
      "path" => "images/ppsg7ml5/test/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg",
      "sha1hash" => "075b7c7a434870280dab6613b3bf687988e36d75",
      "size" => 12_233_794,
      "url" =>
        ~c"https://cdn.sanity.io/images/ppsg7ml5/test/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg"
    }
  end

  describe "url_for_file/1" do
    test "handles asset _ref" do
      {:ok, url} =
        ExSanity.Assets.url_for_file(%{
          source: %{
            "_type" => "file",
            "asset" => %{
              "_type" => "reference",
              "_ref" => "file-88a39460f9a23f524ae80688fff8464b40e4e8ec-mp3"
            }
          }
        })

      assert URI.decode(url) ==
               "#{file_base()}/88a39460f9a23f524ae80688fff8464b40e4e8ec.mp3"
    end

    test "handles asset url" do
      source = "https://cdn.sanity.io/files/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec.mp3"

      {:ok, url} =
        ExSanity.Assets.url_for_file(%{
          source: %{
            "_type" => "file",
            "asset" => %{
              "_type" => "reference",
              "url" => source
            }
          }
        })

      assert url == source
    end

    test "can pass source directly" do
      {:ok, url} =
        ExSanity.Assets.url_for_file(%{
          "_type" => "file",
          "asset" => %{
            "_type" => "reference",
            "_ref" => "file-88a39460f9a23f524ae80688fff8464b40e4e8ec-mp3"
          }
        })

      assert URI.decode(url) ==
               "#{file_base()}/88a39460f9a23f524ae80688fff8464b40e4e8ec.mp3"
    end
  end

  describe "url_for_image/1" do
    test "gracefully handles malformed url" do
      assert {:error, :malformed_asset} ==
               ExSanity.Assets.url_for_image(%{
                 source: %{
                   "_type" => "image",
                   "asset" => %{
                     "_ref" => "image-Tb9Ew8CXIwaY6R1kjMvI0uRR-NotxNumber-jpg",
                     "_type" => "reference"
                   }
                 }
               })

      assert {:error, :malformed_asset} ==
               ExSanity.Assets.url_for_image(%{
                 source: %{
                   "_type" => "image",
                   "asset" => %{
                     "_ref" => "nope",
                     "_type" => "reference"
                   }
                 }
               })

      assert {:error, :malformed_asset} ==
               ExSanity.Assets.url_for_image(%{
                 source: %{
                   "_type" => "image",
                   "asset" => %{
                     "_id" => "nope",
                     "_type" => "reference"
                   }
                 }
               })

      assert {:error, :malformed_asset} ==
               ExSanity.Assets.url_for_image(%{
                 source: %{
                   "_type" => "image",
                   "asset" => %{
                     "_ref" => "Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x1000-jpg",
                     "_type" => "reference"
                   }
                 }
               })
    end

    test "does not crop when no crop is required" do
      {:ok, url} = ExSanity.Assets.url_for_image(%{source: uncropped_image()})

      assert URI.decode(url) == "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg"
    end

    test "does does not crop, but limits size when only width dimension is specified" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: uncropped_image(),
          transforms: %{
            width: 100
          }
        })

      assert URI.decode(url) == "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?w=100"
    end

    test "does does not crop, but limits size when only height dimension is specified" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: uncropped_image(),
          transforms: %{
            height: 100
          }
        })

      assert URI.decode(url) == "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?h=100"
    end

    test "a tall crop is centered on the hotspot" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: uncropped_image(),
          transforms: %{
            width: 30,
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=150,0,900,3000&w=30&h=100"
    end

    test "a wide crop is centered on the hotspot" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: uncropped_image(),
          transforms: %{
            width: 100,
            height: 30
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=0,600,2000,600&w=100&h=30"
    end

    test "a crop with identical aspect and no specified crop is not cropped" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: uncropped_image(),
          transforms: %{
            width: 200,
            height: 300
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?w=200&h=300"
    end

    test "respects the crop, even when no explicit crop is asked for" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: cropped_image(),
          transforms: %{}
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=200,300,1600,2400"
    end

    test "a tall crop is centered on the hotspot and constrained within the image crop" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: cropped_image(),
          transforms: %{
            width: 30,
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=240,300,720,2400&w=30&h=100"
    end

    test "ignores the image crop if caller specifies another" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: cropped_image(),
          transforms: %{
            width: 30,
            height: 100,
            rect: %{left: 10, top: 20, width: 30, height: 40}
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=10,20,30,40&w=30&h=100"
    end

    test "gracefully handles a non-hotspot image" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?h=100"
    end

    test "formats flip params correctly" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            flip_horizontal: true
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?flip=h"

      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            flip_vertical: true
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?flip=v"

      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            flip_horizontal: true,
            flip_vertical: true
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?flip=hv"
    end

    test "formats focal point params correctly" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            focal_point: %{
              x: 0.5,
              y: 1
            }
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?fp-x=0.5&fp-y=1"
    end

    test "formats snakecase params" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            format: :png
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?fm=png"
    end

    test "formats url params with original names" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            "min-w": 200
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?min-w=200"
    end

    test "removes invalid params" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: no_hotspot_image(),
          transforms: %{
            test: 1
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg"
    end

    test "gracefully handles materialized asset" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: materialized_asset_with_crop(),
          transforms: %{
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=200,300,1600,2400&h=100"
    end

    test "gracefully handles asset with only url" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: asset_with_url(),
          transforms: %{
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=200,300,1600,2400&h=100"
    end

    test "gracefully handles rounding errors" do
      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: cropped_portrait_image_rounding(),
          transforms: %{
            width: 400,
            height: 600
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-2555x3833.jpg?w=400&h=600"

      {:ok, url} =
        ExSanity.Assets.url_for_image(%{
          source: cropped_landscape_image_rounding(),
          transforms: %{
            width: 600,
            height: 400
          }
        })

      assert URI.decode(url) ==
               "#{image_base()}/Tb9Ew8CXIwaY6R1kjMvI0uRR-3833x2555.jpg?w=600&h=400"
    end
  end
end
