defmodule ExSanity.QueryTest do
  use ExUnit.Case, async: true

  import ExSanity.Query

  describe "from/1" do
    test "sets document type" do
      query = from(:foo)

      assert query.types == [:foo]
    end
  end

  describe "select/2" do
    test "sets projections" do
      query =
        from(:foo)
        |> select([:bar])

      assert query.projections == [:bar]
    end
  end

  describe "Sanity Examples" do
    test "Filters" do
      assert from("*") |> build() == ~s(*[])
      assert from(:movie) |> build() == ~s(*[_type == "movie"])
      assert from("*") |> build("abc.123") == ~s(*[_id == "abc.123"])
      assert from([:movie, :person]) |> build() == ~s(*[_type in ["movie", "person"]])

      assert from(:movie)
             |> filter("popularity > 15")
             |> filter("releaseDate > \"2016-04-25\"")
             |> build() ==
               ~s(*[_type == "movie" && popularity > 15 && releaseDate > "2016-04-25"])

      # May need to wait on "OR" filters
      # assert from(:movie)
      #        |> filter("popularity > 15")
      #        |> or_filter("releaseDate > \"2016-04-25\"")
      #        |> build() ==
      #          ~s(*[_type == "movie" && (popularity > 15 || releaseDate > "2016-04-25"\)])

      # *[popularity < 15] // less than
      # *[popularity > 15] // greater than
      # *[popularity <= 15] // less than or equal
      # *[popularity >= 15] // greater than or equal
      # *[popularity == 15]
      # *[releaseDate != "2016-04-27"] // not equal
      # *[!(releaseDate == "2016-04-27")] // not equal
      # *[!(releaseDate != "2016-04-27")] // even equal via double negatives "not not equal"
      # *[dateTime(_updatedAt) > dateTime('2018-04-20T20:43:31Z')] // Use zulu-time when comparing datetimes to strings
      # *[dateTime(_updatedAt) > dateTime(now()) - 60*60*24*7] // Updated within the past week
      # *[name < "Baker"] // Records whose name precedes "Baker" alphabetically
      # *[awardWinner == true] // match boolean
      # *[awardWinner] // true if awardWinner == true
      # *[!awardWinner] // true if awardWinner == false
      # *[defined(awardWinner)] // has been assigned an award winner status (any kind of value)
      # *[!defined(awardWinner)] // has not been assigned an award winner status (any kind of value)
      # *[title == "Aliens"]
      # *[title in ["Aliens", "Interstellar", "Passengers"]]
      # *[_id in path("a.b.c.*")] // _id matches a.b.c.d but not a.b.c.d.e
      # *[_id in path("a.b.c.**")] // _id matches a.b.c.d, and also a.b.c.d.e.f.g, but not a.b.x.1
      # *[!(_id in path("drafts.**"))] // _id matches anything that is not under the drafts-path
      # *["yolo" in tags] // documents that have the string "yolo" in the array "tags"
      # *[status in ["completed", "archived"]] // the string field status is either == "completed" or "archived"
      # *["person_sigourney-weaver" in castMembers[].person._ref] // Any document having a castMember referencing sigourney as its person
      # *[slug.current == "some-slug"] // nested properties
      # *[count((categories[]->slug.current)[@ in ["action", "thriller"]]) > 0] // documents that reference categories with slugs of "action" or "thriller"
      # *[count((categories[]->slug.current)[@ in ["action", "thriller"]]) == 2]
    end

    test "ordering and slicing" do
      assert from(:movie)
             |> order({:_createdAt, :asc})
             |> build() == ~s(*[_type == "movie"] | order(_createdAt asc\))

      assert from(:movie)
             |> order({:releaseDate, :desc})
             |> order({:_createdAt, :asc})
             |> build() ==
               ~s(*[_type == "movie"] | order(releaseDate desc\) | order(_createdAt asc\))

      # FUTURE: support mixed ordering
      # *[_type == "todo"] | order(priority desc, _updatedAt desc) 

      assert from(:movie)
             |> order({:_createdAt, :asc})
             |> slice("0")
             |> build() == ~s(*[_type == "movie"] | order(_createdAt asc\)[0])

      assert from(:movie)
             |> order({:_createdAt, :desc})
             |> slice("0")
             |> build() == ~s(*[_type == "movie"] | order(_createdAt desc\)[0])

      assert from(:movie)
             |> order({:_createdAt, :asc})
             |> slice("0..9")
             |> build() == ~s(*[_type == "movie"] | order(_createdAt asc\)[0..9])

      # *[_type == "movie"][0..9] | order(_createdAt asc)

      # *[_type == "movie"] | order(_createdAt asc) [$start..$end]

      # *[_type == "movie"] | order(title asc)

      # *[_type == "movie"] | order(lower(title) asc)
    end
  end
end
