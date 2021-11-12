defmodule ExSanity.AssetBuilderTest do
  use ExUnit.Case

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

  # describe("file_url/1") do
  #   test("handles asset _ref") do
  #     ref = "file-88a39460f9a23f524ae80688fff8464b40e4e8ec-mp3"
  #     output = ExSanity.AssetBuilder.file_url(ref)

  #     assert output ==
  #              "https://cdn.sanity.io/files/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec.mp3"
  #   end

  #   test("handles asset url") do
  #     url = "https://cdn.sanity.io/files/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec.mp3"
  #     output = ExSanity.AssetBuilder.file_url(url)

  #     assert output == url
  #   end
  # end

  describe("image_url/1") do
    test "does not crop when no crop is required" do
      url = ExSanity.AssetBuilder.image_url(%{source: uncropped_image(), transforms: %{}})

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg"
    end

    test "does does not crop, but limits size when only width dimension is specified" do
      url =
        ExSanity.AssetBuilder.image_url(%{
          source: uncropped_image(),
          transforms: %{
            width: 100
          }
        })

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?w=100"
    end

    test "does does not crop, but limits size when only height dimension is specified" do
      url =
        ExSanity.AssetBuilder.image_url(%{
          source: uncropped_image(),
          transforms: %{
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?h=100"
    end

    test "a tall crop is centered on the hotspot" do
      url =
        ExSanity.AssetBuilder.image_url(%{
          source: uncropped_image(),
          transforms: %{
            width: 30,
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=150,0,900,3000&w=30&h=100"
    end

    test "a wide crop is centered on the hotspot" do
      url =
        ExSanity.AssetBuilder.image_url(%{
          source: uncropped_image(),
          transforms: %{
            width: 100,
            height: 30
          }
        })

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=0,600,2000,600&w=100&h=30"
    end

    test "a crop with identical aspect and no specified crop is not cropped" do
      url =
        ExSanity.AssetBuilder.image_url(%{
          source: uncropped_image(),
          transforms: %{
            width: 200,
            height: 300
          }
        })

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?w=200&h=300"
    end

    test "respects the crop, even when no explicit crop is asked for" do
      url =
        ExSanity.AssetBuilder.image_url(%{
          source: cropped_image(),
          transforms: %{}
        })

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=200,300,1600,2400"
    end

    test "a tall crop is centered on the hotspot and constrained within the image crop" do
      url =
        ExSanity.AssetBuilder.image_url(%{
          source: cropped_image(),
          transforms: %{
            width: 30,
            height: 100
          }
        })

      assert URI.decode(url) ==
               "#{ExSanity.AssetBuilder.file_base()}/images/#{ExSanity.AssetBuilder.project_id()}/#{
                 ExSanity.AssetBuilder.dataset()
               }/Tb9Ew8CXIwaY6R1kjMvI0uRR-2000x3000.jpg?rect=240,300,720,2400&w=30&h=100"
    end
  end
end
