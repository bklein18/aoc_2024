import gleam/bool
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import graph

pub fn day5_part1(contents: String) -> Int {
  let parts = string.split(contents, "\n\n")
  let ordering =
    list.first(parts)
    |> result.unwrap("")
    |> string.split("\n")
    |> create_order_graph
  list.last(parts)
  |> result.unwrap("")
  |> string.split("\n")
  |> list.filter(fn(x) { production_order_obeys(x, ordering) })
  |> list.map(fn(x) {
    string.split(x, ",")
    |> get_middle_element
  })
  |> list.fold(0, fn(acc, x) { acc + x })
}

pub fn day5_part2(contents: String) -> Int {
  let parts = string.split(contents, "\n\n")
  let ordering =
    list.first(parts)
    |> result.unwrap("")
    |> string.split("\n")
    |> create_order_graph
  list.last(parts)
  |> result.unwrap("")
  |> string.split("\n")
  |> list.filter(fn(x) { bool.negate(production_order_obeys(x, ordering)) })
  |> list.map(fn(x) {
    string.split(x, ",")
    |> reorder_production_list(by: ordering)
    |> get_middle_element
  })
  |> list.fold(0, fn(acc, x) { acc + x })
}

fn reorder_production_list(str_list: List(String), by g) -> List(String) {
  str_list
  |> list.map(fn(x) {
    int.parse(x)
    |> result.unwrap(0)
  })
  |> list.sort(fn(x, y) {
    case bool.negate(graph.has_edge(g, x, y)) {
      True -> order.Lt
      False -> order.Gt
    }
  })
  |> list.map(int.to_string)
}

fn get_middle_element(str_list: List(String)) {
  { list.length(str_list) - 1 } / 2
  |> list.drop(str_list, _)
  |> list.first
  |> result.try(int.parse)
  |> result.unwrap(0)
}

fn create_order_graph(str_list: List(String)) {
  str_list
  |> list.fold(graph.new(), fn(acc, line) {
    let parts = string.split(line, "|")
    let first =
      parts
      |> list.first
      |> result.unwrap("0")
      |> int.parse
      |> result.unwrap(0)
    let last =
      parts
      |> list.last
      |> result.unwrap("0")
      |> int.parse
      |> result.unwrap(0)
    insert_node_if_none_exists(acc, first)
    |> insert_node_if_none_exists(last)
    |> graph.insert_directed_edge(
      int.to_string(first) <> " to " <> int.to_string(last),
      first,
      last,
    )
  })
}

fn insert_node_if_none_exists(g, node_id) {
  case graph.has_node(g, node_id) {
    True -> g
    False -> graph.insert_node(g, graph.Node(node_id, int.to_string(node_id)))
  }
}

fn production_order_obeys(str, g) {
  let production_list =
    string.split(str, ",")
    |> list.try_map(int.parse)
    |> result.unwrap([])
  case list.first(production_list), list.rest(production_list) {
    Ok(first), Ok(rest) -> {
      let current_item_obeys =
        list.fold(rest, True, fn(acc, x) {
          bool.and(acc, bool.negate(graph.has_edge(g, from: x, to: first)))
        })
      let remaining_obeys =
        list.map(rest, int.to_string)
        |> string.join(",")
        |> production_order_obeys(g)
      bool.and(current_item_obeys, remaining_obeys)
    }
    _, _ -> True
  }
}
