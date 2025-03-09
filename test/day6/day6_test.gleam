import day6/day6
import gleeunit/should

const test_input = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

pub fn day6_part1_test() {
  should.equal(day6.day6_part1(test_input), 41)
}

pub fn day6_part2_test() {
  should.equal(day6.day6_part2(test_input), 6)
}
