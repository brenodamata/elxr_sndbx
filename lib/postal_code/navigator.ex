defmodule EkhexDelivery.PostalCode.Navigator do
  use GenServer
  alias :math, as: Math
  alias EkhexDelivery.PostalCode.{Store, Cache}

  # @radius 6371 #km
  @radius 3959

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :postal_code_navigator)
  end

  def get_distance(from, to) do
    do_get_distance(from, to)
    GenServer.call(:postal_code_navigator, {:get_distance, from, to})
  end

  # Callbacks

  def handle_call({:get_distance, from, to}, _from, state) do
    distance = do_get_distance(from, to)
    {:reply, distance, state}
  end

  defp do_get_distance(from, to) do
    from = format_postal_code(from)
    to = format_postal_code(to)

    case Cache.get_distance(from, to) do
      nil ->
        {lat1, long1} = Store.get_geolocation(from)
        {lat2, long2} = Store.get_geolocation(to)

        # calculate_distance_deprecated(lat1, long1, lat2, long2)
        distance = calculate_distance({lat1, long1}, {lat2, long2})
        Cache.set_distance(from, to, distance)
        distance
      distance -> distance
    end
  end

  defp format_postal_code(postal_code) when is_binary(postal_code), do: postal_code
    # {123, 456}
    # Store.get_geolocation(postal_code)
  # end
  defp format_postal_code(postal_code) when is_integer(postal_code) do
    postal_code = Integer.to_string(postal_code)
    format_postal_code(postal_code)
  end
  defp format_postal_code(postal_code) do
    error = "unexpected `postal code`, received: (#{inspect(postal_code)})"
    raise ArgumentError, error
  end

  # defp calculate_distance_deprecated(from_lat, from_long, to_lat, to_long) do
  #   r = 6371; # km
  #   distance_lat  = Math.deg2rad(to_lat - from_lat)
  #   distance_long = Math.deg2rad(to_long - from_long)
  #   lat1 = Math.deg2rad(from_lat)
  #   lat2 = Math.deg2rad(to_lat)
  #
  #   a = Math.sin(distance_lat/2) * Math.sin(distance_lat/2) +
  #       Math.sin(distance_long/2) * Math.sin(distance_long/2) * Math.cos(lat1) * Math.cos(lat2)
  #   c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  #
  #   distance = r * c
  # end

  defp calculate_distance({lat1, long1}, {lat2, long2}) do
    lat_diff = degrees_to_radians(lat2 - lat1)
    long_diff = degrees_to_radians(long2 - long1)

    lat1 = degrees_to_radians(lat1)
    lat2 = degrees_to_radians(lat2)

    cos_lat1 = Math.cos(lat1)
    cos_lat2 = Math.cos(lat2)

    sin_lat_diff_sq = Math.sin(lat_diff / 2) |> Math.pow(2)
    sin_long_diff_sq = Math.sin(long_diff / 2) |> Math.pow(2)

    a = sin_lat_diff_sq + (sin_long_diff_sq * cos_lat1 * cos_lat2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    @radius * c |> Float.round(2)
  end

  defp degrees_to_radians(degrees) do
    degrees * (Math.pi / 180)
  end
end
