import day1/day1
import gleeunit/should

pub fn day1_part1_test() {
  let test_data =
    "3   4
4   3
2   5
1   3
3   9
3   3"
  should.equal(day1.day1_part1(test_data), 11)
}

pub fn day1_part2_test() {
  let test_data =
    "3   4
4   3
2   5
1   3
3   9
3   3"
  should.equal(day1.day1_part2(test_data), 31)
}
