defmodule Mix.Tasks.Tree.Prof do
  @shortdoc "Profile using ExProf"
  use Mix.Task
  import ExProf.Macro

  @list Enum.to_list(1..10000)
  @dict @list |> Enum.map(&({&1,nil}))


  @tree Tree.from_list(@dict)
  @rbdict :rbdict.from_list(@dict)


  def run(_mix_args) do
    profile do
      # :gb_sets.from_list(@dict)
      # Tree.from_list(@dict)
      :rbdict.from_list(@dict)
      # Enum.each(@list, &Tree.delete(@tree, &1))

      # Tree.to_list(@tree)

      # Tree.get(@tree, 0)

      # Tree.member?(@tree, 10)
      # :rbdict.is_key(10, @rbdict)

    end
  end
end