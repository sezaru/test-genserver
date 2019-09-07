defmodule AccIndicator do
  defmacro __using__(opts) do
    subscribe_to = Keyword.fetch!(opts, :subscribe_to)
    acc_until = Keyword.fetch!(opts, :accumulate_until)
    custom_state = Keyword.get(opts, :custom_state, :no_state)

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
        %{accumulated_data: data, custom_state: custom_state} = state

        {results, data, custom_state} = compute(events, data, custom_state)

        state = %{state | accumulated_data: data, custom_state: custom_state}

        {:noreply, results, state}
      end

      defp compute(events, data, custom_state, results \\ [])

      defp compute([event | rest], data, custom_state, results) do
        {result, data, custom_state} = compute_data(data ++ [event], custom_state)

        compute(rest, data, custom_state, results ++ result)
      end

      defp compute([], data, custom_state, results), do: {results, data, custom_state}

      defp compute_data(data, custom_state) when length(data) < unquote(acc_until) do
        {[], data, custom_state}
      end

      defp compute_data(data, custom_state) when length(data) == unquote(acc_until) do
        {result, custom_state} = do_compute(data, custom_state)

        {[result], data, custom_state}
      end

      defp compute_data([_ | data], custom_state) do
        {result, custom_state} = do_compute(data, custom_state)

        {[result], data, custom_state}
      end

      defp new_state() do
        %{accumulated_data: [], custom_state: unquote(custom_state)}
      end
    end
  end
end
