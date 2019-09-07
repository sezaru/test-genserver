# defmodule M do
#   def create_wait_more_data_do_compute(args, size) do
#     args
#     |> List.duplicate(size)
#     |> Enum.with_index(0)
#     |> Enum.map(fn {v, i} -> List.replace_at(v, i, []) end)
#     |> Enum.map(fn args ->
#       quote do
#         def do_compute(unquote_splicing(args), results) do
#           {unquote_splicing(args), results}
#         end
#       end
#     end)
#   end

#   def create_real_do_compute(args, size) do
#     size_with_result = size + 1

#     quote do
#       def do_compute(unquote_splicing(args), results) do
#         vars =
#           unquote(args)
#           |> Enum.map(fn [h | t] -> {h, t} end)

#         firsts = Enum.map(vars, fn {h, _} -> h end)
#         rests = Enum.map(vars, fn {h, t} -> t end)

#         result = apply(&(real_compute / unquote(size)), firsts)

#         results = results ++ [result]

#         apply(&(do_compute/ unquote(size_with_result)), rests ++ [results])
#       end
#     end    
#   end

#   defmacro create(argument_names) do
#     args = Enum.map(argument_names, fn arg -> Macro.var(arg, nil) end)
#     size = length(args)

#     a = create_wait_more_data_do_compute(args, size)
#     b = create_real_do_compute(args, size)

#     [a, b]
#   end
# end

# defmodule Test do
#   def real_compute(a, b, c) do
#     a + b + c
#   end
  
#   M.create([:a, :b, :c])
# end

# require M

# quoted = quote do
#   M.create([:a, :b, :c])
# end

# quoted |> Macro.expand_once(__ENV__) |> Macro.to_string() |> IO.puts

# Test.do_compute([1, 2], [3, 4], [1], [])

# def do_compute([], b, c, results), do: {[], b, c, results}
# def do_compute(a, [], c, results), do: {a, [], c, results}
# def do_compute(a, b, [], results), do: {a, b, [], results}

# defp do_compute([a | a_rest], [b | b_rest], [c | c_rest], results),
#   do: do_compute(a_rest, b_rest, c_rest, results ++ [real_compute(a, b, c)])

# def(do_compute([], b, c, results)) do
#   {[], b, c, results}
# end

# def(do_compute(a, [], c, results)) do
#   {a, [], c, results}
# end

# def(do_compute(a, b, [], results)) do
#   {a, b, [], results}
# end

# def(do_compute(a, b, c, results)) do
#   vars = [a, b, c] |> Enum.map(fn [h | t] -> {h, t} end)
#   firsts = Enum.map(vars, fn {h, _} -> h end)
#   rests = Enum.map(vars, fn {h, t} -> t end)
#   result = apply(&real_compute/3, firsts)
#   results = results ++ [result]
#   apply(&do_compute/4, rests ++ [results])
# end
