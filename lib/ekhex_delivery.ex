defmodule EkhexDelivery do
  use Application

  def start(_type, _args) do
    EkhexDelivery.Supervisor.start_link
  end
end
