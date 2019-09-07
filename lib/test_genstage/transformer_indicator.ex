defmodule TransformerIndicator do
  defmacro __using__(opts) do
    subscribe_to = Keyword.fetch!(opts, :subscribe_to)
    state = Keyword.get(opts, :state, :no_state)

    quote do
      use GenStage
      
      def start_link(args) do
        GenStage.start_link(__MODULE__, args, name: __MODULE__)
      end
      
      def init(_args) do
        {:producer_consumer, new_state(),
         subscribe_to: [{unquote(subscribe_to), max_demand: 1}],
         dispatcher: GenStage.BroadcastDispatcher}
      end

      def handle_events(events, _from, state) do
        {results, state} = compute(events, state)

        {:noreply, results, state}
      end

      defp compute(events, state, results \\ [])

      defp compute([event | rest], state, results) do
        {result, state} = do_compute(event, state)

        case result do
          nil -> compute(rest, state, results)
          _ -> compute(rest, state, results ++ [result])
        end
      end

      defp compute([], state, results), do: {results, state}

      defp new_state(), do: unquote(state)
    end
  end
end
