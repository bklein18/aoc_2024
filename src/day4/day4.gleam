import gleam/list
import gleam/result
import gleam/string

const xmas = "XMAS"

pub fn day4_part1(contents: String) -> Int {
  let forward_backward =
    string.split(contents, "\n")
    |> list.fold(0, fn(acc, str) -> Int { acc + count_xmas_in_string(str) })
  let up_down =
    convert_string_to_matrix(contents)
    |> list.transpose
    |> list.map(fn(x) -> String {
      list.fold(x, "", fn(acc, char) -> String { acc <> char })
    })
    |> list.fold(0, fn(acc, str) -> Int { acc + count_xmas_in_string(str) })
  let diagonals_tl_br =
    convert_string_to_matrix(contents)
    |> convert_matrix_to_diagonal
    |> list.fold(0, fn(acc, str) -> Int { acc + count_xmas_in_string(str) })
  let diagonals_tr_bl =
    convert_string_to_matrix(contents)
    |> list.reverse
    |> convert_matrix_to_diagonal
    |> list.fold(0, fn(acc, str) -> Int { acc + count_xmas_in_string(str) })
  forward_backward + up_down + diagonals_tl_br + diagonals_tr_bl
}

pub fn day4_part2(contents: String) -> Int {
  convert_string_to_window_mat_list(contents)
  |> list.fold(0, fn(acc, window_list) -> Int {
    acc
    + list.count(window_list, fn(list) -> Bool {
      case list {
        [["M", _, "M"], [_, "A", _], ["S", _, "S"]]
        | [["M", _, "S"], [_, "A", _], ["M", _, "S"]]
        | [["S", _, "M"], [_, "A", _], ["S", _, "M"]]
        | [["S", _, "S"], [_, "A", _], ["M", _, "M"]] -> True
        _ -> False
      }
    })
  })
}

fn convert_string_to_window_mat_list(
  contents: String,
) -> List(List(List(List(String)))) {
  contents
  |> convert_string_to_matrix
  |> list.map(fn(l) { list.window(l, by: 3) })
  |> list.transpose
  |> list.map(fn(mat) { list.window(mat, by: 3) })
}

/// Assume that input string from AoC is diagonalizable (i.e. square matrix)
///
fn convert_string_to_matrix(str: String) -> List(List(String)) {
  string.split(str, "\n")
  |> list.map(fn(x) -> List(String) { string.to_graphemes(x) })
}

/// Convert matrix of characters into diagonal string list
/// Strategy:
///     - Take list of lists, for each row, take the first element
///     - Shift lists down one row, repeat (i.e. El. 0,0 -> nothing, El. 10 -> 01)
fn convert_matrix_to_diagonal(mat: List(List(String))) -> List(String) {
  let expected_length = { list.length(mat) * 2 } - 1
  let list_of_firsts: List(List(String)) =
    list.map(mat, fn(x) -> List(String) {
      let element =
        list.first(x)
        |> result.unwrap("")
      [element]
    })
  let rest_of_lists: List(List(String)) =
    list.map(mat, fn(x) {
      list.rest(x)
      |> result.unwrap([])
    })
  let after = expected_length - list.length(list_of_firsts)
  let before = 0
  let padded_list = pad_array_to_diag_length(list_of_firsts, before, after)
  list.map2(
    padded_list,
    get_remaining_columns(rest_of_lists, before + 1, after - 1),
    fn(list_a, list_b) -> List(String) { list.append(list_a, list_b) },
  )
  |> list.map(fn(x) { list.fold(x, "", fn(acc, char) { acc <> char }) })
}

fn get_remaining_columns(
  mat: List(List(String)),
  before_pad: Int,
  after_pad: Int,
) -> List(List(String)) {
  case after_pad >= 0 {
    True -> {
      let list_of_firsts: List(List(String)) =
        list.map(mat, fn(x) -> List(String) {
          let element =
            list.first(x)
            |> result.unwrap("")
          [element]
        })
      let rest_of_lists: List(List(String)) =
        list.map(mat, fn(x) {
          list.rest(x)
          |> result.unwrap([])
        })
      let padded_list =
        pad_array_to_diag_length(list_of_firsts, before_pad, after_pad)
      list.map2(
        padded_list,
        get_remaining_columns(rest_of_lists, before_pad + 1, after_pad - 1),
        fn(list_a, list_b) -> List(String) { list.append(list_a, list_b) },
      )
    }
    False -> list.repeat([], list.length(mat) + before_pad + after_pad)
  }
}

fn pad_array_to_diag_length(
  l: List(List(String)),
  before: Int,
  after: Int,
) -> List(List(String)) {
  let before_list = list.repeat(["."], before)
  let after_list = list.repeat(["."], after)
  before_list
  |> list.append(l)
  |> list.append(after_list)
}

/// Count forward and backward instances of "XMAS" in a single line of a string
///
fn count_xmas_in_string(str: String) -> Int {
  let str_list = string.to_graphemes(str)
  let reverse_list = list.reverse(str_list)
  let forward_count =
    str_list
    |> list.window(by: 4)
    |> list.count(fn(list) -> Bool {
      let combined_str =
        list.fold(list, "", fn(acc, item) -> String { acc <> item })
      combined_str == xmas
    })
  let reverse_count =
    reverse_list
    |> list.window(by: 4)
    |> list.count(fn(list) -> Bool {
      let combined_str =
        list.fold(list, "", fn(acc, item) -> String { acc <> item })
      combined_str == xmas
    })
  forward_count + reverse_count
}
