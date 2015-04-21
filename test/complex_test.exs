defmodule ComplexTest do
  use ExUnit.Case

  setup_all do
    python_path = [__DIR__, "pylib"] |> Path.join |> to_char_list

    {:ok, py} = :python.start [python_path: python_path]

    :ok = :python.call py, :coder, :setup, []

    seed = :erlang.now
    {a, b, c} = seed

    reps = 10_000

    IO.puts "\n\nTesting Complex"
    IO.puts "Using Random seed {#{a}, #{b}, #{c}}"
    IO.puts "Input length: #{reps}"

    on_exit fn() -> :python.stop(py) end

    {:ok, py: py, seed: seed, reps: reps}
  end

  setup %{seed: seed} do
    Random.seed seed

    :ok
  end

  test "imaginary unit macros" do
    require Complex

    assert Complex.j == Complex.new(0, 1)
    assert Complex.i == Complex.new(0, 1)
  end


  @unary [
    {:negation, &Complex.neg/1, :operator, :neg, 307, 0, 0},
    {:signum, &Complex.sign/1, :helper, :signum, 75, 0, 10},
    {:absolute_value, &Complex.abs/1, :operator, :abs, 200, 0, 10},
    {:argument, &Complex.arg/1, :cmath, :phase, 150, 0, 0},
    {:conjugate, &Complex.conj/1, :helper, :conj, 307, 0, 0},
    {:exponentiation, &Complex.exp/1, :cmath, :exp, 2.5, 0, 0},
    {:square_root, &Complex.sqrt/1, :cmath, :sqrt, 200, 0, 10}
  ]

  Enum.each @unary, fn({name, fun, py_mod, py_fun, magnitude, epsilon, ulps}) ->
    test "#{name}", %{py: py, reps: reps} do
      numbers = TestHelper.random_complex_numbers reps, unquote(magnitude)

      result = Enum.map numbers, unquote(fun)

      expected = Enum.map numbers, fn(x) ->
        :python.call(py, unquote(py_mod), unquote(py_fun), [TestHelper.encode(x)])
        |> TestHelper.decode
      end

      List.zip([numbers, result, expected])
      |> Enum.each(fn({inp, res, exp}) ->
           assert Complex.close_enough?(res, exp, unquote(epsilon), unquote(ulps)),
                  "In: #{inp}\nOut: #{res}\nExp: #{exp}"
      end)
    end
  end

  test "cis", %{py: py, reps: reps} do
    numbers = TestHelper.random_floats reps, 10

    result = Enum.map numbers, &Complex.cis/1

    expected = Enum.map numbers, fn(x) ->
      :python.call(py, :helper, :cis, [x])
      |> TestHelper.decode
    end

    List.zip([numbers, result, expected])
    |> Enum.each(fn({inp, res, exp}) ->
         assert Complex.equal?(res, exp), "In: #{inp}\nOut: #{res}\n Exp: #{exp}"
    end)
  end

  @binary [
    {:addition, &Complex.add/2, :add, 307},
    {:subtraction, &Complex.sub/2, :sub, 307},
    {:multiplication, &Complex.mul/2, :mul, 150},
    {:division, &Complex.div/2, :truediv, 150}
  ]

  Enum.each @binary, fn({name, fun, py_fun, magnitude}) ->
    test "#{name}", %{py: py, reps: reps} do
      pairs = TestHelper.random_complex_pairs reps, unquote(magnitude)

      result = Enum.map pairs, fn({a, b}) -> unquote(fun).(a, b) end

      expected = Enum.map pairs, fn({a, b}) ->
        :python.call(py, :operator, unquote(py_fun), [TestHelper.encode(a), TestHelper.encode(b)])
        |> TestHelper.decode
      end

      List.zip([pairs, result, expected])
      |> Enum.each(fn({{a, b}, res, exp}) ->
           assert res == exp, "In: #{a} -- #{b}\nOut: #{res}\nExp: #{exp}"
      end)
    end
  end
end

