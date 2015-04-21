defmodule TestHelper do
  def random_integers(len, min, max) do
    Stream.repeatedly(fn() ->
      Random.random(max - min) + min
    end)
    |> Stream.reject(&(&1 == 0))
    |> Enum.take(len)
  end

  def random_integer_pairs(len, min, max) do
    Enum.zip random_integers(len, min, max), random_integers(len, min, max)
  end

  def random_float(magnitude \\ 307) do
    coefficient = 2 * Random.random - 1
    exponent = Random.random(magnitude*2) - magnitude

    coefficient * :math.pow(10, exponent)
  end

  def random_floats(len, magnitude \\ 307) do
    Stream.repeatedly(fn() -> random_float(magnitude) end)
    |> Enum.take(len)
  end

  def random_complex_numbers(len, magnitude \\ 307) do
    Stream.repeatedly(fn() ->
      Complex.new random_float(magnitude), random_float(magnitude)
    end)
    |> Stream.reject(&Complex.equal?(&1, 0))
    |> Enum.take(len)
  end

  def random_complex_pairs(len, magnitude \\ 307) do
    Enum.zip random_complex_numbers(len, magnitude), random_complex_numbers(len, magnitude)
  end

  def encode(x), do: {:complex, x.r, x.i}

  def decode({r, i}), do: Complex.new(r, i)
  def decode(x), do: x
end

ExUnit.start()

