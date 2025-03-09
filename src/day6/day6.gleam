import gleam/list
import gleam/result
import gleam/string
import glearray.{type Array}

pub fn day6_part1(contents: String) -> Int {
  let state =
    contents
    |> parse_input
  let #(row, col) = get_guard_x_y(state)
  state
  |> game(row, col)
  |> count_x
}

type PathRecord {
  PathRecord(row: Int, col: Int, orientation: Guard)
}

pub fn day6_part2(contents: String) -> Int {
  let state =
    contents
    |> parse_input
  let #(row, col) = get_guard_x_y(state)
  let guard =
    glearray.get(to_array(state), row)
    |> result.try(glearray.get(_, col))
    |> result.try(char_to_guard_state(_))
    |> result.unwrap(Up)
  generate_all_test_cases(state)
  |> list.count(game_loop(_, row, col, guard, []))
}

const obstacle = "#"

type Guard {
  Up
  Down
  Left
  Right
}

fn guard_state_to_char(guard: Guard) -> String {
  case guard {
    Up -> "^"
    Down -> "v"
    Left -> "<"
    Right -> ">"
  }
}

fn char_to_guard_state(str: String) -> Result(Guard, Nil) {
  case str {
    "^" -> Ok(Up)
    "v" -> Ok(Down)
    "<" -> Ok(Left)
    ">" -> Ok(Right)
    _ -> Error(Nil)
  }
}

fn rotate_guard(guard: Guard) -> Guard {
  case guard {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn list_contains_guard(l: List(String)) -> Bool {
  let r =
    l
    |> list.find(fn(x) -> Bool {
      case x {
        "^" | "v" | "<" | ">" -> True
        _ -> False
      }
    })
  case r {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn count_x(state: List(List(String))) -> Int {
  state
  |> list.fold(0, fn(acc, x) {
    acc
    + list.count(x, fn(y) {
      case y {
        "X" -> True
        _ -> False
      }
    })
  })
}

fn game(state: List(List(String)), row: Int, col: Int) -> List(List(String)) {
  let guard =
    glearray.get(to_array(state), row)
    |> result.try(glearray.get(_, col))
    |> result.try(char_to_guard_state(_))
    |> result.unwrap(Up)
  case can_guard_move(guard, to_array(state), row, col) {
    True -> {
      let #(next_row, next_col) = get_next_space_coords(guard, row, col)
      let former =
        to_array(state)
        |> glearray.get(row)
        |> result.try(glearray.copy_set(_, col, "X"))
        |> result.try(glearray.copy_set(to_array(state), row, _))
        |> result.unwrap(to_array(state))
      former
      |> glearray.get(next_row)
      |> result.try(glearray.copy_set(_, next_col, guard_state_to_char(guard)))
      |> result.try(glearray.copy_set(former, next_row, _))
      |> result.unwrap(former)
      |> to_list
      |> game(next_row, next_col)
    }
    False -> {
      case will_guard_leave(guard, state, row, col) {
        False -> {
          to_array(state)
          |> glearray.get(row)
          |> result.try(glearray.copy_set(
            _,
            col,
            guard_state_to_char(rotate_guard(guard)),
          ))
          |> result.try(glearray.copy_set(to_array(state), row, _))
          |> result.unwrap(to_array(state))
          |> to_list
          |> game(row, col)
        }
        True -> {
          to_array(state)
          |> glearray.get(row)
          |> result.try(glearray.copy_set(_, col, "X"))
          |> result.try(glearray.copy_set(to_array(state), row, _))
          |> result.unwrap(to_array(state))
          |> to_list
        }
      }
    }
  }
}

fn game_loop(
  state: List(List(String)),
  row: Int,
  col: Int,
  guard: Guard,
  tracker_list: List(PathRecord),
) -> Bool {
  let contains_exact_same_path =
    tracker_list
    |> list.find(fn(x) { x == PathRecord(row, col, guard) })
  case contains_exact_same_path {
    Ok(_) -> {
      True
    }
    _ -> {
      case can_guard_move(guard, to_array(state), row, col) {
        True -> {
          let #(next_row, next_col) = get_next_space_coords(guard, row, col)
          let tracker_list =
            append_to_tracker_list(row, col, guard, tracker_list)
          state
          |> game_loop(next_row, next_col, guard, tracker_list)
        }
        False -> {
          case will_guard_leave(guard, state, row, col) {
            False -> {
              let tracker_list =
                append_to_tracker_list(row, col, guard, tracker_list)
              state
              |> game_loop(row, col, rotate_guard(guard), tracker_list)
            }
            True -> {
              False
            }
          }
        }
      }
    }
  }
}

fn generate_all_test_cases(state) -> List(List(List(String))) {
  let #(row, col) = get_guard_x_y(state)
  let num_rows =
    state
    |> list.length
  let row_range = list.range(0, num_rows - 1)
  let num_cols =
    state
    |> list.first
    |> result.unwrap([])
    |> list.length
  let col_range = list.range(0, num_cols - 1)
  row_range
  |> list.fold([], fn(acc, r) {
    col_range
    |> list.fold([], fn(ac, c) {
      case r == row, c == col {
        True, True -> ac
        _, _ -> list.append(ac, [generate_test_case(state, r, c)])
      }
    })
    |> list.append(acc, _)
  })
}

fn generate_test_case(state, row, col) -> List(List(String)) {
  state
  |> to_array
  |> glearray.get(row)
  |> result.try(glearray.copy_set(_, col, obstacle))
  |> result.try(glearray.copy_set(to_array(state), row, _))
  |> result.unwrap(to_array(state))
  |> to_list
}

fn append_to_tracker_list(row, col, guard, tracker_list) -> List(PathRecord) {
  list.append(tracker_list, [PathRecord(row, col, guard)])
}

fn get_next_space_coords(guard: Guard, row: Int, col: Int) -> #(Int, Int) {
  case guard {
    Up -> #(row - 1, col)
    Right -> #(row, col + 1)
    Down -> #(row + 1, col)
    Left -> #(row, col - 1)
  }
}

fn will_guard_leave(
  guard: Guard,
  state: List(List(String)),
  row: Int,
  col: Int,
) -> Bool {
  case guard {
    Up -> row == 0
    Left -> col == 0
    Down -> row == { list.length(state) - 1 }
    Right -> {
      let num_cols =
        list.first(state)
        |> result.unwrap([])
        |> list.length
      col == { num_cols - 1 }
    }
  }
}

fn can_guard_move(
  guard: Guard,
  state: Array(Array(String)),
  row: Int,
  col: Int,
) -> Bool {
  case guard {
    Up -> {
      case row == 0 {
        True -> False
        _ -> {
          let next_element =
            glearray.get(state, row - 1)
            |> result.try(glearray.get(_, col))
            |> result.unwrap(".")
          next_element != obstacle
        }
      }
    }
    Right -> {
      let arr_size =
        to_list(state)
        |> list.first
        |> result.unwrap([])
        |> list.length
      case col == arr_size - 1 {
        True -> False
        _ -> {
          let next_element =
            glearray.get(state, row)
            |> result.try(glearray.get(_, col + 1))
            |> result.unwrap(".")
          next_element != obstacle
        }
      }
    }
    Down -> {
      let arr_size =
        to_list(state)
        |> list.length
      case row == arr_size - 1 {
        True -> False
        _ -> {
          let next_element =
            glearray.get(state, row + 1)
            |> result.try(glearray.get(_, col))
            |> result.unwrap(".")
          next_element != obstacle
        }
      }
    }
    Left -> {
      case col == 0 {
        True -> False
        _ -> {
          let next_element =
            glearray.get(state, row)
            |> result.try(glearray.get(_, col - 1))
            |> result.unwrap(".")
          next_element != obstacle
        }
      }
    }
  }
}

fn get_guard_x_y(for l: List(List(String))) -> #(Int, Int) {
  let r =
    l
    |> list.find(list_contains_guard)
  case r {
    Ok(found_guard) -> {
      let lead_rows_dropped =
        l
        |> list.drop_while(fn(l) { l != found_guard })
      let lead_rows_only =
        l
        |> list.take(list.length(l) - list.length(lead_rows_dropped))
      let guard_row =
        lead_rows_dropped
        |> list.first
      case guard_row {
        Ok(gr) -> {
          let guard =
            list.find_map(gr, char_to_guard_state)
            |> result.unwrap(Up)
          // we've already found the guard once, this will not return nil
          let lead_cols_dropped =
            list.drop_while(gr, fn(x) { x != guard_state_to_char(guard) })
          let lead_cols_only =
            list.take(gr, list.length(gr) - list.length(lead_cols_dropped))

          #(list.length(lead_rows_only), list.length(lead_cols_only))
        }
        _ -> #(-1, -1)
      }
    }
    Error(_) -> #(-1, -1)
  }
}

fn parse_input(input: String) -> List(List(String)) {
  input
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn to_array(l: List(List(String))) -> Array(Array(String)) {
  l
  |> list.map(glearray.from_list)
  |> glearray.from_list
}

fn to_list(a: Array(Array(String))) -> List(List(String)) {
  a
  |> glearray.to_list
  |> list.map(glearray.to_list)
}
