defmodule MultiInputIndicator do
  defmacro __using__(opts) do
    inputs = Keyword.fetch!(opts, :inputs)
    state_map = inputs |> Enum.map(&{&1, []}) |> Enum.into(%{})

    subscribe_to =
      Keyword.fetch!(opts, :subscribe_to)
      |> Enum.zip(inputs)
      |> Enum.map(fn {ind, name} -> {ind, max_demand: 1, name: name} end)

    custom_state = Keyword.get(opts, :custom_state, :no_state)

    quote do
      use GenStage
      
      def start_link(args) do
        GenStage.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_args) do
        {:producer_consumer, new_state(),
         subscribe_to: unquote(subscribe_to), dispatcher: GenStage.BroadcastDispatcher}
      end

      def handle_subscribe(:consumer, _opts, _to_or_from, state), do: {:automatic, state}

      def handle_subscribe(:producer, opts, {_pid, tag}, state) do
        name = Keyword.fetch!(opts, :name)

        state = state |> put_in([:by_tag, tag], name) |> put_in([:by_name, name], [])

        {:automatic, state}
      end

      def handle_events(events, {_pid, tag}, state) do
        name = get_in(state, [:by_tag, tag])

        {events, state} =
          state
          |> update_in([:by_name, name], &(&1 ++ events))
          |> compute()

        {:noreply, events, state}
      end

      defp new_state() do
        %{
          by_tag: %{},
          by_name: unquote(Macro.escape(state_map)),
          custom_state: unquote(custom_state)
        }
      end

      def compute(%{by_name: map, custom_state: custom_state} = state) do
        {values, custom_state, results} = map |> Map.values() |> compute(custom_state)

        map = map |> Map.keys() |> Enum.zip(values) |> Enum.into(%{})

        {results, %{state | by_name: map, custom_state: custom_state}}
      end

      def compute(values, custom_state, results \\ []) when is_list(values) do
        if Enum.any?(values, &Enum.empty?/1) do
          {values, custom_state, results}
        else
          calc_args = values |> Enum.map(&hd/1)
          rest_args = values |> Enum.map(&tl/1)

          {result, custom_state} = apply(__MODULE__, :do_compute, calc_args ++ [custom_state])

          compute(rest_args, custom_state, results ++ [result])
        end
      end
    end
  end
end
