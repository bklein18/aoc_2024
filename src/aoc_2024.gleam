import day1/day1
import gleam/int
import gleam/io
import gleam/result
import simplifile

pub fn main() {
  let input_path = "./src/day1/day1input.txt"
  let contents =
    simplifile.read(input_path)
    |> result.unwrap("")

  io.println("========== Day 1 ==========")
  io.print("List Difference: ")
  io.println(int.to_string(day1.day1_part1(contents)))
  io.print("List Similarity: ")
  io.println(int.to_string(day1.day1_part2(contents)))
}
