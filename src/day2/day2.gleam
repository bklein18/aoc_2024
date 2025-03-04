/// Module for Advent of Code, Day 2
/// For problem, see https://adventofcode.com/2024/day/2
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Take in a list of Ints and determine how many rows are *safe*
///
pub fn day2_part1(input: String) -> Int {
  let parsed_input = parse_input(input)

  parsed_input
  |> list.count(fn(x) -> Bool { is_increasing(x) || is_decreasing(x) })
}

/// Take in a list of Ints and determine how many rows are *safe*
/// Can tolerate a single fault in each row
///
pub fn day2_part2(input: String) -> Int {
  let parsed_input = parse_input(input)

  parsed_input
  |> list.count(fn(x) -> Bool {
    is_increasing_damper(x)
    || is_decreasing_damper(x)
    || is_increasing_damper(list.reverse(x))
    || is_decreasing_damper(list.reverse(x))
  })
}

fn parse_input(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(fn(x) -> List(Int) {
    string.split(x, on: " ")
    |> list.map(fn(y) -> Int {
      int.parse(y)
      |> result.unwrap(-1)
    })
  })
}

fn is_increasing(input_list: List(Int)) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  is_increasing_loop(res, first)
}

fn is_increasing_loop(input_list: List(Int), previous: Int) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  case res == [], previous < first {
    False, True -> {
      let diff = first - previous
      case diff >= 1, diff <= 3 {
        True, True -> is_increasing_loop(res, first)
        _, _ -> False
      }
    }
    _, False -> False
    _, _ -> {
      let diff = first - previous
      case diff >= 1, diff <= 3 {
        True, True -> True
        _, _ -> False
      }
    }
  }
}

fn is_decreasing(input_list: List(Int)) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  is_decreasing_loop(res, first)
}

fn is_decreasing_loop(input_list: List(Int), previous: Int) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  case res == [], previous > first {
    False, True -> {
      let diff = previous - first
      case diff >= 1, diff <= 3 {
        True, True -> is_decreasing_loop(res, first)
        _, _ -> False
      }
    }
    _, False -> False
    _, _ -> {
      let diff = previous - first
      case diff >= 1, diff <= 3 {
        True, True -> True
        _, _ -> False
      }
    }
  }
}

fn is_increasing_damper(input_list: List(Int)) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  let second =
    list.first(res)
    |> result.unwrap(-1)
  let second_res =
    list.rest(res)
    |> result.unwrap(list.new())
  is_increasing_damper_loop(res, first, False)
  || is_increasing_damper_loop(second_res, second, True)
}

fn is_increasing_damper_loop(
  input_list: List(Int),
  previous: Int,
  fault_reached: Bool,
) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  case res == [], previous < first, fault_reached {
    False, True, _ -> {
      let diff = first - previous
      case diff >= 1, diff <= 3, fault_reached {
        True, True, _ -> is_increasing_damper_loop(res, first, fault_reached)
        _, _, False ->
          is_increasing_damper_loop(list.drop(input_list, 1), previous, True)
        _, _, _ -> False
      }
    }
    _, False, False -> {
      is_increasing_damper_loop(list.drop(input_list, 1), previous, True)
    }
    _, False, True -> False
    _, _, _ -> {
      let diff = first - previous
      case diff >= 1, diff <= 3, fault_reached {
        True, True, _ -> True
        _, _, False ->
          is_increasing_damper_loop(list.drop(input_list, 1), previous, True)
        _, _, _ -> False
      }
    }
  }
}

fn is_decreasing_damper(input_list: List(Int)) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  let second =
    list.first(res)
    |> result.unwrap(-1)
  let second_res =
    list.rest(res)
    |> result.unwrap(list.new())
  is_decreasing_damper_loop(res, first, False)
  || is_decreasing_damper_loop(second_res, second, True)
}

fn is_decreasing_damper_loop(
  input_list: List(Int),
  previous: Int,
  fault_reached: Bool,
) -> Bool {
  let first =
    list.first(input_list)
    |> result.unwrap(-1)
  let res =
    list.rest(input_list)
    |> result.unwrap(list.new())
  case res == [], previous > first, fault_reached {
    False, True, _ -> {
      let diff = previous - first
      case diff >= 1, diff <= 3, fault_reached {
        True, True, _ -> is_decreasing_damper_loop(res, first, fault_reached)
        _, _, False ->
          is_decreasing_damper_loop(list.drop(input_list, 1), previous, True)
        _, _, _ -> False
      }
    }
    _, False, False ->
      is_decreasing_damper_loop(list.drop(input_list, 1), previous, True)
    _, False, True -> False
    _, _, _ -> {
      let diff = previous - first
      case diff >= 1, diff <= 3, fault_reached {
        True, True, _ -> True
        _, _, False ->
          is_decreasing_damper_loop(list.drop(input_list, 1), previous, True)
        _, _, _ -> False
      }
    }
  }
}
