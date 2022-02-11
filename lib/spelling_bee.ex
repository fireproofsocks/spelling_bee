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

  The results here will only be as good as the word list:

      iex> SpellingBee.words("efl")
      {:ok, ["leef", "flee", "fell", "feel"]}

      iex> SpellingBee.words("abdr", "a", min_length: 5)
      {:ok, ["radar", "draba", "barba", "babar", "araba"]}
  """
  def words(available, required \\ "", opts \\ [])
      when is_binary(available) and is_binary(required) and is_list(opts) do
    available_set = to_set(available)
    required_set = to_set(required)
    wordlist = Keyword.get(opts, :wordlist, @default_wordlist)
    min_length = Keyword.get(opts, :min_length, @default_min_length)

    Logger.debug(
      "Available #{inspect(available_set)}; required: #{inspect(required_set)}; wordlist: #{wordlist}; min_length: #{min_length}"
    )

    with :ok <- contains_required_letters(available_set, required_set),
         :ok <- wordlist_exists(wordlist),
         :ok <- wordlist_not_dir(wordlist) do
      {:ok, find_words(wordlist, available_set, required_set, min_length)}
    end
  end

  defp to_set(string) do
    string
    |> String.graphemes()
    |> MapSet.new()
  end

  defp contains_required_letters(available_set, required_set) do
    case MapSet.subset?(required_set, available_set) do
      false -> {:error, "Missing required letter(s)"}
      true -> :ok
    end
  end

  defp find_words(wordlist, available_set, required_set, min_length) do
    wordlist
    |> File.stream!()
    |> Enum.reduce([], fn line, acc ->
      word = String.trim(line)

      with :ok <- spellable?(word, available_set, required_set, word),
           :ok <- word_long_enough(word, min_length) do
        [word | acc]
      else
        _ -> acc
      end
    end)
  end

  defp spellable?("", _, required_set, word) do
    word
    |> to_set()
    |> contains_required_letters(required_set)
  end

  defp spellable?(<<head::binary-size(1)>> <> tail, available_set, required_set, word) do
    case MapSet.member?(available_set, head) do
      true ->
        spellable?(tail, available_set, required_set, word)

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
      false -> {:error, "Wordlist #{inspect(wordlist)} does not exist or is a directory"}
    end
  end

  defp wordlist_not_dir(wordlist) do
    case File.dir?(wordlist) do
      true -> {:error, "The wordlist at #{inspect(wordlist)} is a directory"}
      false -> :ok
    end
  end
end
