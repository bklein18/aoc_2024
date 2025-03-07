import day4/day4
import gleam/io
import gleeunit/should

pub fn day4_part1_test() {
  let test_input =
    "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"
  should.equal(day4.day4_part1(test_input), 18)
}

pub fn day4_part2_test() {
  let test_input =
    "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"
  io.println("======Input======")
  io.println(test_input)
  should.equal(day4.day4_part2(test_input), 9)
}
