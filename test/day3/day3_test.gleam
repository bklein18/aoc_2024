import day3/day3
import gleeunit/should

pub fn day3_part1_test() {
  let test_input =
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))mul( 1, 9 )"
  should.equal(day3.day3_part1(test_input), 161)
}

pub fn day3_part2_test() {
  let test_input =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))mul( 1, 9 )"
  should.equal(day3.day3_part2(test_input), 48)
}
