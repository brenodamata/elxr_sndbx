defmodule EkhexDelivery.PostalCode.NavigatorTest do
  use ExUnit.Case
  alias EkhexDelivery.PostalCode.Navigator
  doctest EkhexDelivery

  describe "get_distance" do
    test "postal code strings" do
      distance = Navigator.get_distance("06811", "06801")
      assert is_float(distance)
    end

    test "postal code integers" do
      distance = Navigator.get_distance(94062, 94104)
      assert is_float(distance)
    end

    test "postal code string and integer" do
      distance = Navigator.get_distance("06811", 94062)
      assert is_float(distance)
    end

    test "postal code invalid format" do
      assert_raise ArgumentError, fn ->
        Navigator.get_distance(94062, 94104.1)
      end
    end

    # @tag :capture_log
    # test "postal code invalid format" do
    #   navigatore_pid = Process.whereis(:postal_code_navigator)
    #   reference = Process.monitor(navigatore_pid)
    #   catch_exit do
    #     Navigator.get_distance(94062, 94104.1)
    #   end
    #   assert_received({:DOWN, ^reference, :process, ^navigatore_pid, {%ArgumentError{}, _}})
    # end
  end

  describe "get_distance (actual distance)" do
    test "distance between danbury and sf" do
      # Danbury, CT 06810
      # San Francisco, CA 94104
      # Driving distance = 2583.57
      distance = Navigator.get_distance("06810", 94104)
      # IO.puts "danbury -> sf: #{distance}"
      assert is_float(distance)
      assert distance == 2583.57
    end

    test "distance between sf and nyc" do
      # San Francisco, CA 94104
      # New York, NY 10028
      # Driving distance ~ 3100
      distance = Navigator.get_distance(94104, 10028)
      # IO.puts "sf -> ny: #{distance}"
      assert is_float(distance)
      assert distance == 2566.38
    end

    test "distance between mnpl and austin" do
      # Minneapolis, MN 55401
      # Austin, TX 78703
      # Driving distance ~ 1100
      distance = Navigator.get_distance(55401, 78703)
      # IO.puts "minneapolis -> austin: #{distance}"
      assert is_float(distance)
      assert distance == 1044.08
    end
  end
end
