defmodule Complex do
  @moduledoc """
  Functions for working with complex numbers.
  """

  # Unimport Kernel functions to prevent name clashes.
  import Kernel, except: [abs: 1, div: 2]

  defstruct r: 0, i: 0

  @typedoc """
  Complex numbers in rectangular form.
  """
  @type t :: %Complex{r: number, i: number}

  @typedoc """
  General type for complex and real numbers.
  """
  @type cnum :: t | number

  defimpl String.Chars, for: Complex do
    def to_string(%Complex{r: r, i: i}) do
      if i >= 0 do
        "#{r} + #{i}j"
      else
        "#{r} - #{-i}j"
      end
    end
  end

  defimpl Inspect, for: Complex do
    def inspect(c, _opts) do
      "#(#{c})"
    end
  end


  @spec new(number, number) :: t
  def new(r, i), do: %Complex{r: r, i: i}

  @spec new({number, number}) :: t
  def new({r, i}), do: %Complex{r: r, i: i}

  @spec convert(cnum) :: t
  def convert(x = %Complex{}), do: x
  def convert(r), do: new(r, 0)


  @doc """
  Imaginary unit.
  """
  defmacro j(), do: Macro.escape(new(0, 1))

  @doc """
  imaginary unit
  """
  defmacro i(), do: Macro.escape(new(0, 1))


  @spec neg(a) :: a when a: cnum
  def neg(%Complex{r: r, i: i}), do: new(-r, -i)
  def neg(x), do: -x

  @doc """
  Signum function generalized to complex numbers.
  """
  @spec sign(t) :: t | 0
  @spec sign(number) :: -1 | 0 | 1
  def sign(x = %Complex{}) do
    if equal?(x, 0) do
      new(0, 0)
    else
      div(x, abs(x))
    end
  end
  def sign(x), do: ExMath.sign(x)

  @spec add(cnum, cnum) :: cnum
  def add(%Complex{r: r1, i: i1}, %Complex{r: r2, i: i2}) do
    new r1 + r2, i1 + i2
  end
  def add(%Complex{r: r1, i: i}, r2), do: new(r1 + r2, i)
  def add(r1, %Complex{r: r2, i: i}), do: new(r1 + r2, i)
  def add(a, b), do: a + b

  @spec sub(cnum, cnum) :: cnum
  def sub(%Complex{r: r1, i: i1}, %Complex{r: r2, i: i2}) do
    new r1 - r2, i1 - i2
  end
  def sub(%Complex{r: r1, i: i}, r2), do: new(r1 - r2, i)
  def sub(r1, %Complex{r: r2, i: i}), do: new(r1 - r2, -i)
  def sub(a, b), do: a - b

  @spec mul(cnum, cnum) :: cnum
  def mul(%Complex{r: r1, i: i1}, %Complex{r: r2, i: i2}) do
    new r1*r2 - i1*i2, r1*i2 + i1*r2
  end
  def mul(%Complex{r: r, i: i}, x), do: new(x*r, x*i)
  def mul(x, %Complex{r: r, i: i}), do: new(x*r, x*i)
  def mul(a, b), do: a*b

  @doc """
  A slightly unusual algorithm is used to avoid over- and underflow errors.

  Inspired by Python's [complex division method](https://github.com/python/cpython/blob/60b3703e5b567520de9a848d47cd381f49872f2f/Objects/complexobject.c#L52).
  """
  @spec div(cnum, cnum) :: t | float
  def div(%Complex{r: r1, i: i1}, %Complex{r: r2, i: i2}) do
    if Kernel.abs(r2) >= Kernel.abs(i2) do
      rat = i2/r2
      den = r2 + i2*rat

      Complex.new (r1 + i1*rat)/den, (i1 - r1*rat)/den
    else
      rat = r2/i2
      den = r2*rat + i2

      Complex.new (r1*rat + i1)/den, (i1*rat - r1)/den
    end
  end
  def div(%Complex{r: r, i: i}, x), do: new(r/x, i/x)
  def div(a, b = %Complex{}), do: div(convert(a), b)
  def div(a, b), do: a/b


  @doc """
  Corresponds to Kernel.==/2. `1`, `1.0`, and `1+0j` are considered equal.
  """
  @spec equal?(cnum, cnum) :: boolean
  def equal?(%Complex{r: r1, i: i1}, %Complex{r: r2, i: i2}) do
    r1 == r2 and i1 == i2
  end
  def equal?(a, b), do: equal?(convert(a), convert(b))

  @doc """
  Floating point equality. See `ExMath.close_enough?/4` for more information.
  """
  @spec close_enough?(cnum, cnum, number, non_neg_integer) :: boolean
  def close_enough?(%Complex{r: r1, i: i1}, %Complex{r: r2, i: i2}, epsilon, ulps) do
    ExMath.close_enough?(r1, r2, epsilon, ulps) and ExMath.close_enough?(i1, i2, epsilon, ulps)
  end
  def close_enough?(a, b, epsilon, ulps) do
    close_enough? convert(a), convert(b), epsilon, ulps
  end


  @spec abs(cnum) :: number
  def abs(%Complex{r: r, i: i}), do: ExMath.hypot(r, i)
  def abs(x), do: Kernel.abs(x)

  @spec arg(cnum) :: number
  def arg(%Complex{r: r, i: i}), do: :math.atan2(i, r)
  def arg(x) when x >= 0, do: 0
  def arg(_), do: :math.pi

  @doc """
  Return `cos(x) + j*sin(x)`
  """
  @spec cis(number) :: t
  def cis(x), do: new(:math.cos(x), :math.sin(x))

  @spec conj(t) :: t
  @spec conj(a) :: a when a: number
  def conj(%Complex{r: r, i: i}), do: new(r, -i)
  def conj(x), do: x

  @spec exp(t) :: t
  @spec exp(number) :: float
  def exp(%Complex{r: r, i: i}), do: mul(:math.exp(r), cis(i))
  def exp(x), do: :math.exp(x)

  @doc """
  Complex square root. Uses the same algorithm as Python's
  [complex square root](https://github.com/python/cpython/blob/60b3703e5b567520de9a848d47cd381f49872f2f/Modules/cmathmodule.c#L733)
  to avoid overflow errors.
  """
  @spec sqrt(cnum) :: t | float
  def sqrt(x = %Complex{r: r, i: i}) do
    if equal?(x, 0) do
      new(0, 0)
    else
      ar = Kernel.abs(r) / 8
      ai = Kernel.abs i

      s = 2 * :math.sqrt(ar + ExMath.hypot(ar, ai/8))
      d = ai/(2*s)

      new(if r >= 0 do
        {s, ExMath.copysign(d, i)}
      else
        {d, ExMath.copysign(s, i)}
      end)
    end
  end
  def sqrt(x) when x < 0, do: new(0, :math.sqrt(-x))
  def sqrt(x), do: :math.sqrt(x)

  
  @spec sum([cnum]) :: cnum
  def sum([]), do: 0
  def sum(numbers), do: Enum.reduce(numbers, &add/2)
end

