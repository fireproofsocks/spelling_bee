# SpellingBee

This is an Elixir application demonstrating how to implement some of the functionality needed to support a word game like the [New York Times Spelling Bee](https://www.nytimes.com/puzzles/spelling-bee)

The included wordlist comes from
<https://www-personal.umich.edu/~jlawler/wordlist.html>

## Examples

The results here will only be as good as the word list. Remember to configure IEx so it does not clip the responses.

```elixir
iex> IEx.configure(inspect: [limit: :infinity, printable_limit: :infinity])
iex> SpellingBee.solutions("efl")
{:ok, ["leef", "flee", "fell", "feel"]}

iex> SpellingBee.solutions("abdr", "a", min_length: 5)
{:ok, ["radar", "draba", "barba", "babar", "araba"]}

iex> SpellingBee.solutions("abcde", "x")
{:error, "Missing required letter(s)"}
```
