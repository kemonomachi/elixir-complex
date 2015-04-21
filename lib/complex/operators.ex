defmodule Complex.Operators do
  @unary [
    -: :neg
  ]

  @binary [
    +: :add,
    -: :sub,
    *: :mul,
    /: :div,
    ==: :equal?
  ]

  defmacro __using__(_opts) do
    ops = Enum.map(@unary, fn({op, _}) -> {op, 1} end)
          ++
          Enum.map(@binary, fn({op, _}) -> {op, 2} end)

    quote do
      import Kernel, except: unquote(ops)
      import Complex.Operators, only: unquote(ops)
    end
  end

  Enum.each @unary, fn({op, name}) ->
    def unquote(op)(a) do
      Complex.unquote(name)(a)
    end
  end

  Enum.each @binary, fn({op, name}) ->
    def unquote(op)(a, b) do
      Complex.unquote(name)(a, b)
    end
  end
end

