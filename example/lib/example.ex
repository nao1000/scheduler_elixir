
# structs... describe structure but not an instance
defmodule Membership do
  defstruct [:type, :price]
end

defmodule User do
  defstruct [:name, :membership]
end


defmodule Example do
  use Application

  # defines a "constant" i.e. a moduel attribue
  @y 5

  # could rebind it here but why?
  #@y 10

  def start(_type, _args) do
    Example.guesser()
    # Example.main1()
    # Example.main2()
    # Example.main3()
    # Example.mainNum()
    # Example.mainCompoundTypes()
    # Example.mainTupleLists()
    # Example.mainMap()
    # Example.mainStruct()
    Supervisor.start_link([], strategy: :one_for_one)
  end


  def guesser do

    # gives 0 to 10, not just 1 to 10
    correct = :rand.uniform(11) - 1

    # get user input
    guess = IO.gets("Guess a number between 0 and 10: ") |> String.trim() |> Integer.parse()
    IO.inspect(guess)
    IO.inspect(elem(guess, 0))

  end

  def main1 do

    # declare a variable


    x = 5     ## will get a warning about it being unused
              ## because x isn't used before rebinding

    # can rebind variables
    x = 10
    IO.puts(x)

    # can not rebind y
    IO.puts(@y)

    # atoms are constant values -- useful when we have
    # small set of constant values with no arbitrary meaning
    # atoms are static, but for perf than strings
    IO.puts(:hello)

    # also an atom
    IO.puts(:"hello world")
  end

  def main2 do
    name = "Caleb"
    status = :gold

    # equality operate is "==="
    # there is a less strict "=="
    if status === :gold do

      # # sign works like fstring
      IO.puts("Welcome to the fancy loung, #{name}")

    # will get a warning because status is always gold
    # I can run status = Enum.random(([:gold, :silver, :bronze]))
    # then compiler won't know and no issues
    else
      IO.puts("Get Lost")
    end
  end

  def main3 do
    name = "Caleb"
    status = Enum.random([:gold, :silver, :bronze, :"not a member"])

    # case statements, pattern matching
    case status do
      :gold -> IO.puts("Welcome #{name}")
      :"not a member" -> IO.puts("get a sub")
      _ -> IO.puts("get lost")
    end
  end

  def mainNum do
    a = 10
    b = 3.0
    IO.puts(a+b)

    # shows 20 decimal places
    :io.format("~.20f\n", [0.1])

    # Float.<function> or Integer.<function>

  end

  def mainCompoundTypes do

    # can't just print compound types
    time = Time.new!(16,30,0,0)
    date = Date.new!(2025,1,1)
    date_time = DateTime.new!(date, time, "Etc/UTC")
    IO.inspect(time)
    IO.inspect(date)
    IO.inspect(date_time)

    time = DateTime.new!(Date.new!(2026,1,1), Time.new!(0,0,0,0), "Etc/UTC")
    time_till = DateTime.diff(time, DateTime.utc_now())
    IO.puts(time_till)

    days = div(time_till, 86_400)
    IO.puts(days)
    hours = (div(rem(time_till, 86_400), 60*60))
    IO.puts(hours)

    mins = div(rem(time_till, 60*60), 60)
    IO.puts(mins)
    seconds = rem(time_till, 60)
    IO.puts(seconds)

    IO.puts("Time until new year: #{days} days, #{hours} hours, blah blah blah ")
  end

  def mainTupleLists do
    memberships = {:bronze, :silver}

    # is making a new one, have to reassign
    memberships = Tuple.insert_at(memberships, 2, :gold)
    IO.inspect(memberships)

    prices = {5,10,15}
    avg = Tuple.sum(prices)/tuple_size(prices)
    IO.puts(avg)

    IO.puts("Average price from #{elem(memberships, 0)}, #{elem(memberships, 1)}, #{elem(memberships, 2)} is #{avg}")


    user1 = {"Morya", :gold}
    user2 = {"Nathan", :gold}
    user3 = {"Kory", :gold}


    # lists
    users = [
      {"Morya", :gold},
      {"Nathan", :gold},
      {"Kory", :gold},
      {"One more", :bronze}
    ]

    # define a loop function and using a list
    IO.puts("Iteratively printing users from list")
    Enum.each(users, fn {name, membership} -> IO.puts("#{name} has a #{membership} membership") end)

    # deconstructing tuple
    IO.puts("\nPrint using line by line")
    {name, membership} = user1
    IO.puts("#{name} has a #{membership} membership.")
    {name, membership} = user2
    IO.puts("#{name} has a #{membership} membership.")
    {name, membership} = user3
    IO.puts("#{name} has a #{membership} membership.")
  end

  def mainMap do

    memberships = %{
      gold: :gold,
      silver: :silver,
      bronze: :bronze,
      none: :none
    }

    prices = %{
      gold: 25,
      silver: 20,
      bronze: 15,
      none: 0
    }

    # lists
    users = [
      {"Morya", memberships.gold},
      {"Nathan", memberships.gold},
      {"Kory", memberships.silver},
      {"One more", memberships.bronze}
    ]

    # define a loop function and using a list
    IO.puts("\nWith map printing users from list")
    Enum.each(users, fn {name, membership} ->
      IO.puts("#{name} has a #{membership} membership paying #{prices[membership]}.")
    end)
  end

  def mainStruct do
    gold_membership = %Membership{type: :gold, price: 25}
    silver_membership = %Membership{type: :silver, price: 20}
    bronze_membership = %Membership{type: :bronze, price: 15}
    none_membership = %Membership{type: :none, price: 0}

    users = [%User{name: "Morya", membership: gold_membership},
      %User{name: "Nathan", membership: gold_membership},
      %User{name: "Kory", membership: silver_membership},
      %User{name: "Extra", membership: bronze_membership}
    ]

    Enum.each(users, fn %User{name: name, membership: membership} ->
      IO.puts("#{name} has a #{membership.type} membership paying #{membership.price}.")
    end)
  end

end
