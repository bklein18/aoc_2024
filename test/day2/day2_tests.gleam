import day2/day2
import gleeunit/should

pub fn day2_part1_test() {
  let test_input =
    "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
1 3 6 7 11"
  should.equal(day2.day2_part1(test_input), 2)
}

pub fn day2_part2_test() {
  let test_input =
    "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
1 3 6 7 11"
  should.equal(day2.day2_part2(test_input), 5)
}
