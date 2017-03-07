defmodule EkhexDelivery.PostalCode.StoreTest do
  use ExUnit.Case
  alias EkhexDelivery.PostalCode.Store
  doctest EkhexDelivery

  test "get_geolocation" do
    {latitude, longitude} = Store.get_geolocation("06811")

    assert is_float(latitude)
    assert is_float(longitude)
  end
end
