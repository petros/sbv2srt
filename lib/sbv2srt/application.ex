defmodule SBV2SRT.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # For CLI applications, we spawn a process to run the CLI
    pid = spawn(&run_cli/0)
    Process.monitor(pid)
    
    # Return a minimal supervisor to satisfy the Application behavior
    children = []
    opts = [strategy: :one_for_one, name: SBV2SRT.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec run_cli() :: no_return()
  defp run_cli do
    args = Burrito.Util.Args.get_arguments()
    SBV2SRT.CLI.main(args)
    System.halt(0)
  end
end