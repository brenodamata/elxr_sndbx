defmodule EkhexDelivery.PostalCode.DataParser do
  @postal_codes_filepath "data/2016_Gaz_zcta_national.txt"

  def parse_data do
    [_header | data_rows] = File.read!(@postal_codes_filepath) |> String.split("\n")
    data_rows
      |> Stream.map(&(String.split(&1, "\t")))
      |> Stream.filter(&data_row?(&1))
      |> Stream.map(&parse_data_columns(&1))
      |> Stream.map(&format_row(&1))
      |> Enum.into(%{})
  end

  defp data_row?(row) do
    case row do
      [_postal_code, _, _, _, _, _latitude, _logitude] -> true
      _ -> false
    end
  end

  defp parse_data_columns(row) do
    [postal_code, _, _, _, _, latitude, logitude] = row
    [postal_code, latitude, logitude]
  end

  defp parse_number(str) do
    str |> String.replace(" ", "") |> String.to_float
  end

  # format three element list into a two element tuple
  defp format_row([postal_code, latitude, logitude]) do
    {postal_code, {parse_number(latitude), parse_number(logitude)}}
  end
end
