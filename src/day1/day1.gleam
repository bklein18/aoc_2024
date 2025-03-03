/// Module for Advent of Code, Day 1
/// For problem, see https://adventofcode.com/2024/day/1
///
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Calculate list difference. Can take any two lists that are space separated
///
pub fn day1_part1(input_contents: String) -> Int {
  let #(list_1, list_2) = parse_data(input_contents)

  let sorted_list_1 = list.sort(list_1, by: int.compare)
  let sorted_list_2 = list.sort(list_2, by: int.compare)

  let list_distance = list_distance(sorted_list_1, sorted_list_2)
  list_distance
}

/// Calculate list similarity. Can take any two lists that are space separated
///
pub fn day1_part2(input_contents: String) -> Int {
  let #(list_1, list_2) = parse_data(input_contents)

  let sorted_list_1 = list.sort(list_1, by: int.compare)
  let sorted_list_2 = list.sort(list_2, by: int.compare)

  let list_similarity = list_similarity(sorted_list_1, sorted_list_2)
  list_similarity
}

fn parse_data(input_contents: String) -> #(List(Int), List(Int)) {
  let list_1 =
    string.split(input_contents, on: "\n")
    |> list.map(fn(x) -> Int {
      string.split(x, on: " ")
      |> list.first
      |> result.try(int.parse)
      |> result.unwrap(0)
    })

  let list_2 =
    string.split(input_contents, on: "\n")
    |> list.map(fn(x) -> Int {
      string.split(x, on: " ")
      |> list.last
      |> result.try(int.parse)
      |> result.unwrap(0)
    })

  #(list_1, list_2)
}

fn list_distance(list_1: List(Int), list_2: List(Int)) -> Int {
  list.zip(list_1, list_2)
  |> list.fold(0, fn(b, a) -> Int { b + int.absolute_value({ a.0 - a.1 }) })
}

fn list_similarity(list_1: List(Int), list_2: List(Int)) -> Int {
  list.fold(list_1, 0, fn(b, a) -> Int {
    let item_similarity =
      list.filter(list_2, fn(x) { x == a })
      |> list.length
    b + { item_similarity * a }
  })
}
