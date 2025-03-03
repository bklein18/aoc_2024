import day1/day1
import day2/day2
import gleam/int
import gleam/io
import gleam/result
import simplifile

pub fn main() {
  let day1_input_path = "./src/day1/day1input.txt"
  let day1_contents =
    simplifile.read(day1_input_path)
    |> result.unwrap("")

  io.println("========== Day 1 ==========")
  io.print("List Difference: ")
  io.println(int.to_string(day1.day1_part1(day1_contents)))
  io.print("List Similarity: ")
  io.println(int.to_string(day1.day1_part2(day1_contents)))

  let day2_input_path = "./src/day2/day2_input.txt"
  let day2_contents =
    simplifile.read(day2_input_path)
    |> result.unwrap("")

  io.println("========== Day 2 ==========")
  io.print("Safe lists: ")
  io.println(int.to_string(day2.day2_part1(day2_contents)))
  io.print("Safe lists with damper: ")
  io.println(int.to_string(day2.day2_part2(day2_contents)))
}
