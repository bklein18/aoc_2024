import day1/day1
import day2/day2
import day3/day3
import day4/day4
import day5/day5
import day6/day6
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

  let day3_input_path = "./src/day3/day3_input.txt"
  let day3_contents =
    simplifile.read(day3_input_path)
    |> result.unwrap("")

  io.println("========== Day 3 ==========")
  io.print("Parsed result: ")
  io.println(int.to_string(day3.day3_part1(day3_contents)))
  io.print("Parsed result with do / don't ")
  io.println(int.to_string(day3.day3_part2(day3_contents)))

  let day4_input_path = "./src/day4/day4_input.txt"
  let day4_contents =
    simplifile.read(day4_input_path)
    |> result.unwrap("")

  io.println("========== Day 4 ==========")
  io.print("Number of Xmas's: ")
  io.println(int.to_string(day4.day4_part1(day4_contents)))
  io.print("Number of X-mas's: ")
  io.println(int.to_string(day4.day4_part2(day4_contents)))

  let day5_input_path = "./src/day5/day5_input.txt"
  let day5_contents =
    simplifile.read(day5_input_path)
    |> result.unwrap("")

  io.println("========== Day 5 ==========")
  io.print("Sum of middle valid rows: ")
  io.println(int.to_string(day5.day5_part1(day5_contents)))
  io.print("Sum of middle invalid rows: ")
  io.println(int.to_string(day5.day5_part2(day5_contents)))

  let day6_input_path = "./src/day6/day6_input.txt"
  let _day6_contents =
    simplifile.read(day6_input_path)
    |> result.unwrap("")

  io.println("========== Day 6 ==========")
  // leaving these commented because they take a *long* time to work. They do work, they are just really inefficient
  // io.print("Spaces visited by guard: ")
  // io.println(int.to_string(day6.day6_part1(day6_contents)))
  // io.print("Paradox spaces: ")
  // io.println(int.to_string(day6.day6_part2(day6_contents)))
}
