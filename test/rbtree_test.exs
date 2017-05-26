defmodule RbtreeTest do
  use ExUnit.Case

  import Tree

  doctest Tree

  test "should create empty tree" do
    assert null?(empty())
    assert height(empty()) == 0
  end

  test "create a rbtree from list" do
    tree = Tree.from_list(1..4 |> Enum.map(&Integer.to_string/1) |>Enum.to_list)
    assert ["4", "3", "2", "1"] == tree|> Tree.to_list

    tree = Tree.from_list([{"a", "test"}, "b"])
    assert ["b", {"a", "test"}] == tree|> Tree.to_list
  end

  test "initializing a red black tree" do
    {_,s} = Tree.new
    assert 0 == s
    assert [3, 2, 1] == [1,2,3] |> Tree.new |> Tree.to_list
  end


  test "to_list" do
    empty_tree = Tree.new
    bigger_tree = Tree.new([d: 1, b: 2, c: 3, a: 4])
    assert [] == Tree.to_list empty_tree

    # It should return the elements in order
    assert (Enum.reverse [{:a, 4}, {:b, 2}, {:c, 3}, {:d, 1}]) == Tree.to_list bigger_tree
    {_,s} = bigger_tree
    assert 4 == s
  end


  test "insert" do
    red_black_tree = Tree.insert Tree.new, 1, :bubbles
    assert [{1, :bubbles}] == Tree.to_list red_black_tree
    {_,s} = red_black_tree
    assert 1 == s

    red_black_tree = Tree.insert red_black_tree, 0, :walrus
    assert (Enum.reverse [{0, :walrus}, {1, :bubbles}]) == Tree.to_list red_black_tree
    {_,s} = red_black_tree
    assert 2 == s
  end


  # test "strict equality" do
  #   tree = Tree.new([{1, :bubbles}])
  #   updated = Tree.insert(tree, 1.0, :walrus)

  #   assert 2 == Tree.size(updated)

  #   # Deletes
  #   # We convert to lists so that the comparison ignores node colors
  #   assert Tree.to_list(Tree.new([{1, :bubbles}])) ==
  #          Tree.to_list(Tree.delete(updated, 1.0))
  #   assert Tree.to_list(Tree.new([{1.0, :walrus}])) ==
  #          Tree.to_list(Tree.delete(updated, 1))

  #   # Search
  #   assert :walrus == Tree.get(updated, 1.0)
  #   assert :bubbles == Tree.get(updated, 1)

  #   assert true == Tree.has_key?(updated, 1.0)
  #   assert true == Tree.has_key?(updated, 1)
  # end

  test "set and get" do
    tree = Tree.new([{"example", "test"}])
    assert get(tree, "example") == "test"

    tree = set(tree, "example", 1)
    assert get(tree, "example") == 1

    tree = Tree.new([d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7])
    assert 2 == get(tree, :b)
    assert 6 == get(tree, :a)
    assert 3 == get(tree, :f)
    assert 1 == get(tree, :d)
    assert 7 == get(tree, :e)
    assert 4 == get(tree, :g)
    assert 5 == get(tree, :c)
  end

  test "if key is in tree" do
    assert false == empty() |> member?("new")
    assert singleton("new") |> member?("new")
    assert false == singleton("new") |> member?("nw")
  end

  test "tree filter_range" do
    tree = Tree.from_list(1..100 |> Enum.to_list)
    assert 1..10 |> Enum.to_list == tree |> filter_range(1, 10)
  end

  test "deletion" do
    tree = Tree.from_list(1..4 |> Enum.map(&Integer.to_string/1) |>Enum.to_list)
    assert tree |> delete(1) |> delete(2) |> size == 2

    initial_tree = Tree.new([d: 1, b: 2, c: 3, a: 4])
    {_,s} = initial_tree
    assert 4 == s
    pruned_tree = delete(initial_tree, :c)

    {_,s} = pruned_tree
    assert 3 == s
    assert Enum.reverse([{:a, 4}, {:b, 2}, {:d, 1}]) == to_list pruned_tree

    assert [] == to_list delete new(), :b
  end

  test "has_key?" do
    assert Tree.has_key?(Tree.new([a: 1, b: 2]), :b)
    assert not Tree.has_key?(Tree.new([a: 1, b: 2]), :c)
  end

  test "get the nth element from the tree" do
    range = 1..10
    tree = Tree.from_list(range |>  Enum.map(&({&1, &1})) |>Enum.to_list)
    for i <- range do
      assert tree |> nth(i-1) == {i,i}
    end

    # Incorrect index will always return nil
    tree = Tree.from_list(1..10|>  Enum.map(&({&1, &1})) |>Enum.to_list)
    assert tree |> nth(10) == nil
    assert tree |> nth(0) == {1,1}
    assert tree |> nth(1) == {2,2}
    assert tree |> nth(-1) == {10,10}
  end

  test "get range a..b" do
    tree = Tree.from_list(1..4 |> Enum.to_list)
    assert [{1, nil}] == tree |> range(0..0)
    assert [{4, nil}] == tree |> range(-1..0)
    assert [{1, nil}, {2, nil}, {3, nil}, {4, nil}] == tree |> range(0..-1)
    assert nil == tree |> range(10..1)
    assert nil == tree |> range(0..100)
    assert [{1, nil},{2, nil}] == tree |> range(0..1)
    assert [{1, nil},{2, nil},{3,nil}] == tree |> range(0..2)
    assert [{1, nil},{2, nil},{3,nil},{4,nil}] == tree |> range(0..3)
    assert [{2, nil},{3,nil},{4,nil}] == tree |> range(1..3)

    k = 100
    tree = Tree.from_list(1..k |> Enum.to_list)
    assert 100 == tree |> size
    assert tree |> range((-2)..(-1)) == [{99, nil}, {100, nil}]


    # Comprehensive testing
    x = 10
    y = 10
    for i <- 1..x do
      for j <- 1..y do
        if j > i do
          tree = Tree.from_list( 1..j |> Enum.to_list )
          left = i..j |> Enum.reduce([], fn i,acc ->  acc ++ [{i,nil}] end)
          right = tree |> range((i-1)..(j-1))
          assert left == right
        end
      end
    end

  end



  # test "implements Collectable" do
  #   members = [d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7]
  #   tree1 = Enum.into(members, Tree.new)
  #   tree2 = Tree.new(members)

  #   # The trees won't be identical due to the comparator function
  #   assert Tree.to_list(tree1) == Tree.to_list(tree2)
  # end

  # test "implements Access" do
  #   tree = Tree.new([d: 1, b: 2, f: 3, g: 4, c: 5, a: 6, e: 7])
  #   assert 1 == tree[:d]
  #   assert 2 == tree[:b]
  #   assert 3 == tree[:f]
  #   assert 4 == tree[:g]

  #   {6, %{tree: new_tree}} = get_and_update_in(%{tree: tree}, [:tree, :a], fn (prev) ->
  #     {prev, prev * 2}
  #   end)
  #   assert 12 == Tree.get(new_tree, :a)
  # end

  test "should put everything to list or map" do
    assert [{"new", "test"}] == singleton("new", "test") |> to_list
    assert %{"new" => "test"} == singleton("new", "test") |> to_map
  end

  test "should conver tree to string" do
    str_tree = singleton("new", "test") |> Tree.to_string
    assert "\n(size:1)\nblack { \"new\", \"test\" }(d:1)\n+ \n+ \n" == str_tree
  end


  test "size" do
    for i <- 1..16 do
      tree = Tree.from_list(1..i |>  Enum.map(&({&1, &1})) |>Enum.to_list)
      # IO.puts tree |> Tree.to_string
      {_,s} = tree
      assert s == size(tree)
    end
  end



end
