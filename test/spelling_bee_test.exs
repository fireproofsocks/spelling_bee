defmodule SpellingBeeTest do
  use ExUnit.Case

  describe "words/3" do
    test "basic matching :ok" do
      assert {:ok, ["dog"]} =
               SpellingBee.words("dgo", "o", wordlist: "priv/test.txt", min_length: 3)
    end
  end
end
