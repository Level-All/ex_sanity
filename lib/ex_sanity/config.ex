defmodule ExSanity.Config do
  @spec resolve(atom, any) :: any
  def resolve(key, default \\ nil)

  def resolve(key, default) when is_atom(key) do
    Application.get_env(:ex_sanity, key, default)
    |> expand_value()
  end

  def resolve(key, _) do
    raise(
      ArgumentError,
      message: "#{__MODULE__} expected key '#{key}' to be an atom"
    )
  end

  defp expand_value({module, function, args})
       when is_atom(function) and is_list(args) do
    apply(module, function, args)
  end

  defp expand_value(value) when is_function(value) do
    value.()
  end

  defp expand_value(value), do: value
end
