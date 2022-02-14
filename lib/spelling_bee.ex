defmodule SpellingBee do
  @moduledoc """
  `SpellingBee` is an app built for demonstration purposes. It shows a solution
  for how to solve [New York Times Spelling Bee](https://www.nytimes.com/puzzles/spelling-bee)
  puzzles using Elixir.
  """

  require Logger

  @default_wordlist "priv/wordlist.txt"
  @default_min_length 4
  @doc """
  This will find a list of words made up of the given `available` letters and the
  given `required` letters (if provided).

  ## Options
  - `:wordlist` path to a wordlist file. Default: `#{@default_wordlist}`
  - `:min_length` (integer) minimum length that solutions must have to be viable. Default: `#{@default_min_length}`

  ## Examples

  The results here will only be as good as the word list. Remember to configure IEx
  so it does not clip the responses.

      iex> IEx.configure(inspect: [limit: :infinity, printable_limit: :infinity])
      iex> SpellingBee.solutions("efl")
      {:ok, ["leef", "flee", "fell", "feel"]}

      iex> SpellingBee.solutions("abdr", "a", min_length: 5)
      {:ok, ["radar", "draba", "barba", "babar", "araba"]}

      iex> SpellingBee.solutions("abcde", "x")
      {:error, "Missing required letter(s)"}
  """
  def solutions(available, required \\ "", opts \\ [])
      when is_binary(available) and is_binary(required) and is_list(opts) do
    avail_letters = to_set(available)
    required_letters = to_set(required)
    wordlist = Keyword.get(opts, :wordlist, @default_wordlist)
    min_length = Keyword.get(opts, :min_length, @default_min_length)

    Logger.debug(
      "Available #{inspect(avail_letters)}; required: #{inspect(required_letters)}; wordlist: #{wordlist}; min_length: #{min_length}"
    )

    with :ok <- has_required_letters(avail_letters, required_letters),
         :ok <- wordlist_exists(wordlist),
         :ok <- wordlist_not_dir(wordlist) do
      {:ok, anagrams(wordlist, avail_letters, required_letters, min_length)}
    end
  end

  defp to_set(string) do
    string
    |> String.graphemes()
    |> MapSet.new()
  end

  defp has_required_letters(avail_letters, required_letters) do
    case MapSet.subset?(required_letters, avail_letters) do
      false -> {:error, "Missing required letter(s)"}
      true -> :ok
    end
  end

  defp anagrams(wordlist, avail_letters, required_letters, min_length) do
    wordlist
    |> File.stream!()
    |> Enum.reduce(MapSet.new(), fn line, acc ->
      with {:ok, word} <- spellable?(line, avail_letters, ""),
           :ok <- word_long_enough(word, min_length),
           :ok <- word |> to_set() |> has_required_letters(required_letters) do
        MapSet.put(acc, word)
      else
        _ -> acc
      end
    end)
    |> Enum.to_list()
  end

  # Returns {:ok, trimmed_word} if we have a match
  # Words terminate with newline
  defp spellable?("\n", _, word_acc), do: {:ok, word_acc}

  defp spellable?(<<letter::binary-size(1)>> <> tail, avail_letters, word_acc) do
    case MapSet.member?(avail_letters, letter) do
      true ->
        spellable?(tail, avail_letters, word_acc <> letter)

      false ->
        :skip
    end
  end

  defp word_long_enough(word, min_length) do
    case String.length(word) >= min_length do
      true -> :ok
      false -> {:error, "Too short"}
    end
  end

  defp wordlist_exists(wordlist) do
    case File.exists?(wordlist) do
      true -> :ok
      false -> {:error, "Wordlist #{inspect(wordlist)} does not exist"}
    end
  end

  defp wordlist_not_dir(wordlist) do
    case File.dir?(wordlist) do
      true -> {:error, "The wordlist at #{inspect(wordlist)} is a directory"}
      false -> :ok
    end
  end
end
