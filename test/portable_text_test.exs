defmodule ExSanity.PortableTextTest do
  use ExUnit.Case

  import Phoenix.HTML

  describe "to_html/1" do
    test "renders block" do
      block = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block) |> safe_to_string()

      assert html == "<div><p>Hello!</p></div>"
    end

    test "respects false container config" do
      block = [
        %{
          "_key" => "1",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "a",
              "_type" => "span",
              "marks" => [],
              "text" => "One"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "2",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b",
              "_type" => "span",
              "marks" => [],
              "text" => "Two"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block, %{ container: false })
      |> Enum.map(&safe_to_string/1)
      |> Enum.join()

      assert html == "<p>One</p><p>Two</p>"
    end

    test "respects function container config" do
      block = [
        %{
          "_key" => "1",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "a",
              "_type" => "span",
              "marks" => [],
              "text" => "One"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "2",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b",
              "_type" => "span",
              "marks" => [],
              "text" => "Two"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block, %{
        container: fn (nodes) ->
          html = nodes
          |> Enum.map(&safe_to_string/1)
          |> Enum.join()
          "<div class='test'>#{html}</div>"
        end
      })

      assert html == "<div class='test'><p>One</p><p>Two</p></div>"
    end

    test "renders block with single mark" do
      block_with_mark = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => ["strong"],
              "text" => "Hello!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block_with_mark) |> safe_to_string()

      assert html == "<div><p><b>Hello!</b></p></div>"
    end

    test "renders block with nested marks" do
      block_with_multiple_marks = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => ["strong", "underline"],
              "text" => "Hello!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block_with_multiple_marks) |> safe_to_string()

      assert html == "<div><p><u><b>Hello!</b></u></p></div>"
    end

    test "renders block with custom mark" do
      block_with_custom_mark = [
        %{
          "_key" => "007988308ea1",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "1cf204f13e6c",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello, how are you? "
            },
            %{
              "_key" => "e8e151d4064b",
              "_type" => "span",
              "marks" => [
                "04dd8390b9ed"
              ],
              "text" => "Go here"
            }
          ],
          "markDefs" => [
            %{
              "_key" => "04dd8390b9ed",
              "_type" => "link",
              "href" => "www.google.com"
            }
          ],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block_with_custom_mark) |> safe_to_string()

      assert html ==
               "<div><p>Hello, how are you? <a href=\"www.google.com\">Go here</a></p></div>"
    end

    test "renders block with multiple children" do
      block_with_multiple_children = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello! "
            },
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => ["strong"],
              "text" => "Let's talk!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block_with_multiple_children) |> safe_to_string()

      assert html == "<div><p>Hello! <b>Let&#39;s talk!</b></p></div>"
    end

    test "renders multiple blocks" do
      multiple_blocks = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Let's talk!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(multiple_blocks) |> safe_to_string()

      assert html == "<div><p>Hello!</p><p>Let&#39;s talk!</p></div>"
    end

    test "renders custom image block with asset -> url" do
      custom_blocks = [
        %{
          "_key" => "3df88bd329dd",
          "_type" => "image",
          "asset" => %{
            "url" => "https://www.image.com"
          }
        }
      ]

      html = ExSanity.PortableText.to_html(custom_blocks) |> safe_to_string()

      assert html == "<div><img src=\"https://www.image.com\"></div>"
    end

    test "renders custom image block with asset -> _ref" do
      custom_blocks = [
        %{
          "_key" => "8b9ada80e403",
          "_type" => "image",
          "asset" => %{
            "_ref" => "image-88a39460f9a23f524ae80688fff8464b40e4e8ec-1024x576-jpg",
            "_type" => "reference"
          }
        }
      ]

      html = ExSanity.PortableText.to_html(custom_blocks) |> safe_to_string()

      assert html == "<div><img src=\"https://cdn.sanity.io/images/123/test/88a39460f9a23f524ae80688fff8464b40e4e8ec-1024x576.jpg\"></div>"
    end

    test "renders list blocks" do
      list_blocks = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello"
            }
          ],
          "markDefs" => [],
          "style" => "h1"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List item one"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List item two"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(list_blocks) |> safe_to_string()

      assert html ==
               "<div><h1>Hello</h1><ul><li>List item one</li><li>List item two</li></ul></div>"
    end

    test "renders nested list blocks" do
      list_blocks = [
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List-item-one"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "Nested-List-item-one"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "Nested-List-item-two"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List-item-two"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(list_blocks) |> safe_to_string()

      match =
        """
        <div>
          <ul>
            <li>List-item-one
              <ul>
                <li>Nested-List-item-one</li>
                <li>Nested-List-item-two</li>
              </ul>
            </li>
            <li>List-item-two</li>
          </ul>
        </div>
        """
        |> String.replace("\n", "")
        |> String.replace("\r", "")
        |> String.replace(" ", "")

      assert html == match
    end

    test "renders deep nested list blocks" do
      list_blocks = [
        %{
          "_key" => "1A_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "1A_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "1A"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "2A_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "2A_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "2A"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "2B_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "2B_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "2B"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "3A_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "3B_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "3A"
            }
          ],
          "level" => 3,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "1B_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "1B_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "1B"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(list_blocks) |> safe_to_string()

      match =
        """
        <div>
          <ul>
            <li>1A
              <ul>
                <li>2A</li>
                <li>
                  2B
                  <ul>
                    <li>3A</li>
                  </ul>
                </li>
              </ul>
            </li>
            <li>1B</li>
          </ul>
        </div>
        """
        |> String.replace("\n", "")
        |> String.replace("\r", "")
        |> String.replace(" ", "")

      assert html == match
    end

    test "renders deep jumping nested list blocks" do
      list_blocks = [
        %{
          "_key" => "1A_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "1A_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "1A"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "2A_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "2A_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "2A"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "2B_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "2B_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "2B"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "3A_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "3A_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "3A"
            }
          ],
          "level" => 3,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "2C_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "2C_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "2C"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "3B_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "3B_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "3B"
            }
          ],
          "level" => 3,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "heading"
            }
          ],
          "markDefs" => [],
          "style" => "h1"
        },
        %{
          "_key" => "1C_BLOCK",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "1C_TEXT",
              "_type" => "span",
              "marks" => [],
              "text" => "1C"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(list_blocks) |> safe_to_string()

      match =
        """
        <div>
          <ul>
            <li>1A
              <ul>
                <li>2A</li>
                <li>
                  2B
                  <ul>
                    <li>3A</li>
                  </ul>
                </li>
                <li>2C
                  <ul>
                    <li>3B</li>
                  </ul>
                </li>
              </ul>
            </li>
          </ul>
          <h1>heading</h1>
          <ul>
            <li>1C</li>
          </ul>
        </div>
        """
        |> String.replace("\n", "")
        |> String.replace("\r", "")
        |> String.replace(" ", "")

      assert html == match
    end
  end

  describe("to_html/2") do
    test "renders block type with custom serializer override" do
      custom_serializers = %{
        block: fn _serializer_defs, _block, _mark_defs -> "some custom text" end
      }

      block = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block, %{
        serializers: custom_serializers
      }) |> safe_to_string()

      assert html == "<div>some custom text</div>"
    end

    test "renders custom mark with custom serializer override" do
      custom_serializers = %{
        marks: %{
          link: fn _serializers, _node, _mark_defs -> "some custom text" end
        }
      }

      block_with_custom_mark = [
        %{
          "_key" => "007988308ea1",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "1cf204f13e6c",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello, how are you? "
            },
            %{
              "_key" => "e8e151d4064b",
              "_type" => "span",
              "marks" => [
                "04dd8390b9ed"
              ],
              "text" => "Go here"
            }
          ],
          "markDefs" => [
            %{
              "_key" => "04dd8390b9ed",
              "_type" => "link",
              "href" => "www.google.com"
            }
          ],
          "style" => "normal"
        }
      ]

      html = ExSanity.PortableText.to_html(block_with_custom_mark, %{
        serializers: custom_serializers
      }) |> safe_to_string()

      assert html ==
               "<div><p>Hello, how are you? some custom text</p></div>"
    end
  end

  describe("with_blocks/1") do
    test "returns array of blocks with no list blocks" do
      raw_blocks = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Let's talk!"
            }
          ],
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      blocks = ExSanity.PortableText.Lists.with_list_blocks(raw_blocks)

      assert length(blocks) == 2
      assert blocks == raw_blocks
    end

    test "renders blocks with nested list block" do
      raw_blocks = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello"
            }
          ],
          "markDefs" => [],
          "style" => "h1"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List item one"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List item two"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      blocks = ExSanity.PortableText.Lists.with_list_blocks(raw_blocks)

      assert length(blocks) == 2

      assert blocks == [
               %{
                 "_key" => "7e08e718fa43",
                 "_type" => "block",
                 "children" => [
                   %{
                     "_key" => "b90a808df999",
                     "_type" => "span",
                     "marks" => [],
                     "text" => "Hello"
                   }
                 ],
                 "markDefs" => [],
                 "style" => "h1"
               },
               %{
                 "_key" => "7e94398f8aea-parent",
                 "_type" => "list",
                 "level" => 1,
                 "listItem" => "bullet",
                 "markDefs" => [],
                 "children" => [
                   %{
                     "_key" => "7e94398f8aea",
                     "_type" => "block",
                     "children" => [
                       %{
                         "_key" => "bf75c745642c",
                         "_type" => "span",
                         "marks" => [],
                         "text" => "List item one"
                       }
                     ],
                     "level" => 1,
                     "listItem" => "bullet",
                     "markDefs" => [],
                     "style" => "normal"
                   },
                   %{
                     "_key" => "7e94398f8aea",
                     "_type" => "block",
                     "children" => [
                       %{
                         "_key" => "bf75c745642c",
                         "_type" => "span",
                         "marks" => [],
                         "text" => "List item two"
                       }
                     ],
                     "level" => 1,
                     "listItem" => "bullet",
                     "markDefs" => [],
                     "style" => "normal"
                   }
                 ]
               }
             ]
    end

    test "renders blocks with deeply nested list block (level 2)" do
      raw_blocks = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello"
            }
          ],
          "markDefs" => [],
          "style" => "h1"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List item one"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "Nested List item one"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "Nested List item two"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      blocks_with_lists = ExSanity.PortableText.Lists.with_list_blocks(raw_blocks)

      assert length(blocks_with_lists) == 2

      mock = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello"
            }
          ],
          "markDefs" => [],
          "style" => "h1"
        },
        %{
          "_key" => "7e94398f8aea-parent",
          "_type" => "list",
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "children" => [
            %{
              "_key" => "7e94398f8aea",
              "_type" => "block",
              "level" => 1,
              "listItem" => "bullet",
              "markDefs" => [],
              "style" => "normal",
              "children" => [
                %{
                  "_key" => "bf75c745642c",
                  "_type" => "span",
                  "marks" => [],
                  "text" => "List item one"
                },
                %{
                  "_key" => "7e94398f8aea-parent",
                  "_type" => "list",
                  "level" => 2,
                  "listItem" => "bullet",
                  "markDefs" => [],
                  "children" => [
                    %{
                      "_key" => "7e94398f8aea",
                      "_type" => "block",
                      "children" => [
                        %{
                          "_key" => "bf75c745642c",
                          "_type" => "span",
                          "marks" => [],
                          "text" => "Nested List item one"
                        }
                      ],
                      "level" => 2,
                      "listItem" => "bullet",
                      "markDefs" => [],
                      "style" => "normal"
                    },
                    %{
                      "_key" => "7e94398f8aea",
                      "_type" => "block",
                      "children" => [
                        %{
                          "_key" => "bf75c745642c",
                          "_type" => "span",
                          "marks" => [],
                          "text" => "Nested List item two"
                        }
                      ],
                      "level" => 2,
                      "listItem" => "bullet",
                      "markDefs" => [],
                      "style" => "normal"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]

      assert blocks_with_lists == mock
    end

    test "renders blocks with deeply nested list block (level 3)" do
      raw_blocks = [
        %{
          "_key" => "7e08e718fa43",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "b90a808df999",
              "_type" => "span",
              "marks" => [],
              "text" => "Hello"
            }
          ],
          "markDefs" => [],
          "style" => "h1"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "List item one"
            }
          ],
          "level" => 1,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "Nested List item one"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "Nested List item two"
            }
          ],
          "level" => 2,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        },
        %{
          "_key" => "7e94398f8aea",
          "_type" => "block",
          "children" => [
            %{
              "_key" => "bf75c745642c",
              "_type" => "span",
              "marks" => [],
              "text" => "Nested List item one"
            }
          ],
          "level" => 3,
          "listItem" => "bullet",
          "markDefs" => [],
          "style" => "normal"
        }
      ]

      blocks_with_lists = ExSanity.PortableText.Lists.with_list_blocks(raw_blocks)

      assert length(blocks_with_lists) == 2

      assert blocks_with_lists == [
               %{
                 "_key" => "7e08e718fa43",
                 "_type" => "block",
                 "children" => [
                   %{
                     "_key" => "b90a808df999",
                     "_type" => "span",
                     "marks" => [],
                     "text" => "Hello"
                   }
                 ],
                 "markDefs" => [],
                 "style" => "h1"
               },
               %{
                 "_key" => "7e94398f8aea-parent",
                 "_type" => "list",
                 "level" => 1,
                 "listItem" => "bullet",
                 "markDefs" => [],
                 "children" => [
                   %{
                     "_key" => "7e94398f8aea",
                     "_type" => "block",
                     "level" => 1,
                     "listItem" => "bullet",
                     "markDefs" => [],
                     "style" => "normal",
                     "children" => [
                       %{
                         "_key" => "bf75c745642c",
                         "_type" => "span",
                         "marks" => [],
                         "text" => "List item one"
                       },
                       %{
                         "_key" => "7e94398f8aea-parent",
                         "_type" => "list",
                         "level" => 2,
                         "listItem" => "bullet",
                         "markDefs" => [],
                         "children" => [
                           %{
                             "_key" => "7e94398f8aea",
                             "_type" => "block",
                             "level" => 2,
                             "listItem" => "bullet",
                             "markDefs" => [],
                             "style" => "normal",
                             "children" => [
                               %{
                                 "_key" => "bf75c745642c",
                                 "_type" => "span",
                                 "marks" => [],
                                 "text" => "Nested List item one"
                               }
                             ]
                           },
                           %{
                             "_key" => "7e94398f8aea",
                             "_type" => "block",
                             "level" => 2,
                             "listItem" => "bullet",
                             "markDefs" => [],
                             "style" => "normal",
                             "children" => [
                               %{
                                 "_key" => "bf75c745642c",
                                 "_type" => "span",
                                 "marks" => [],
                                 "text" => "Nested List item two"
                               },
                               %{
                                 "_key" => "7e94398f8aea-parent",
                                 "_type" => "list",
                                 "level" => 3,
                                 "listItem" => "bullet",
                                 "markDefs" => [],
                                 "children" => [
                                   %{
                                     "_key" => "7e94398f8aea",
                                     "_type" => "block",
                                     "level" => 3,
                                     "listItem" => "bullet",
                                     "markDefs" => [],
                                     "style" => "normal",
                                     "children" => [
                                       %{
                                         "_key" => "bf75c745642c",
                                         "_type" => "span",
                                         "marks" => [],
                                         "text" => "Nested List item one"
                                       }
                                     ]
                                   }
                                 ]
                               }
                             ]
                           }
                         ]
                       }
                     ]
                   }
                 ]
               }
             ]
    end
  end
end
