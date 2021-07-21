defmodule ExSanity.AssetBuilderTest do
  use ExUnit.Case

  describe("file_url/1") do
    test("handles asset _ref") do
      ref = "file-88a39460f9a23f524ae80688fff8464b40e4e8ec-mp3"
      output = ExSanity.AssetBuilder.file_url(ref)

      assert output == "https://cdn.sanity.io/files/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec.mp3"
    end

    test("handles asset url") do
      url = "https://cdn.sanity.io/files/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec.mp3"
      output = ExSanity.AssetBuilder.file_url(url)

      assert output == url
    end
  end

  describe("image_url/1") do
    test("handles asset _ref") do
      ref = "image-88a39460f9a23f524ae80688fff8464b40e4e8ec-1024x576-jpg"
      output = ExSanity.AssetBuilder.image_url(ref)

      assert output == "https://cdn.sanity.io/images/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec-1024x576.jpg"
    end

    test("handles asset url") do
      url = "https://cdn.sanity.io/images/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec-1024x576.jpg"
      output = ExSanity.AssetBuilder.image_url(url)

      assert output == url
    end
  end
end
