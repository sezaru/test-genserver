defmodule Strategy do
  defmacro __using__(opts) do
    subscribe_to = Keyword.fetch!(opts, :subscribe_to)
    state = Keyword.get(opts, :state, :no_state)

    quote do
      use GenStage

      def start_link(args) do
        GenStage.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_args) do
        {:consumer, new_state(), subscribe_to: [{unquote(subscribe_to), max_demand: 1}]}
      end

      def handle_events(events, _from, state) do
        state = compute(events, state)

        {:noreply, [], state}
      end

      defp compute([event | rest], state) do
        state = do_compute(event, state)

        compute(rest, state)
      end

      defp compute([], state), do: state

      defp new_state(), do: unquote(state)
    end
  end
end
