import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Token {
  // literal
  Int(String)
  // keyword
  Mul
  // conditional operation
  Do
  Dont
  // grouping
  LeftParen
  RightParen
  // punctuation
  Comma
  // other
  Invalid
}

/// Convert a given string to a token.
/// Returns a result containing either an error or a tuple with the converted token AND the remaining string
///
fn to_token(str: String) -> Result(#(Token, String), Nil) {
  case string.pop_grapheme(str) {
    Error(_) -> Error(Nil)
    Ok(#(grapheme, remaining)) -> {
      case grapheme {
        "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0" -> {
          let i = grapheme <> take_while(remaining, is_integer_grapheme)
          Ok(#(Int(i), string.drop_start(str, string.length(i))))
        }
        "m" | "u" | "l" -> {
          let mul = grapheme <> take_while(remaining, is_name_grapheme)
          case mul == "mul" {
            True -> Ok(#(Mul, string.drop_start(str, string.length(mul))))
            False -> Error(Nil)
          }
        }
        "(" -> Ok(#(LeftParen, string.drop_start(str, 1)))
        ")" -> Ok(#(RightParen, string.drop_start(str, 1)))
        "," -> Ok(#(Comma, string.drop_start(str, 1)))
        _ -> Ok(#(Invalid, string.drop_start(str, 1)))
      }
    }
  }
}

/// Convert a given string to a token.
/// Returns a result containing either an error or a tuple with the converted token AND the remaining string
///
fn to_token_do_dont(str: String) -> Result(#(Token, String), Nil) {
  case string.pop_grapheme(str) {
    Error(_) -> Error(Nil)
    Ok(#(grapheme, remaining)) -> {
      case grapheme {
        "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0" -> {
          let i = grapheme <> take_while(remaining, is_integer_grapheme)
          Ok(#(Int(i), string.drop_start(str, string.length(i))))
        }
        "m" | "u" | "l" -> {
          let mul =
            grapheme <> take_first_while(remaining, 3, is_keyword_grapheme)
          case mul == "mul" {
            True -> Ok(#(Mul, string.drop_start(str, string.length(mul))))
            False -> Error(Nil)
          }
        }
        "d" | "o" | "n" | "'" | "t" -> {
          let keyword =
            grapheme <> take_first_while(remaining, 5, is_keyword_grapheme)
          case keyword {
            "do" -> Ok(#(Do, string.drop_start(str, 2)))
            "don't" -> Ok(#(Dont, string.drop_start(str, 5)))
            _ -> Error(Nil)
          }
        }
        "(" -> Ok(#(LeftParen, string.drop_start(str, 1)))
        ")" -> Ok(#(RightParen, string.drop_start(str, 1)))
        "," -> Ok(#(Comma, string.drop_start(str, 1)))
        _ -> Ok(#(Invalid, string.drop_start(str, 1)))
      }
    }
  }
}

pub fn day3_part1(contents: String) -> Int {
  contents
  |> lex
  |> parse
  |> evaluate
}

pub fn day3_part2(contents: String) -> Int {
  contents
  |> lex_do_dont
  |> parse_do_dont
  |> evaluate
}

/// Take in a list of tokens, and remove any incorrectly used tokens
/// Example: "mul(2,4)%&mul[3,7]" would only return [Mul, LeftParen, Int(2), Comma, Int(4), RightParen
///
fn parse(tokens: List(Token)) -> List(Token) {
  remove_invalid_tokens(tokens, [])
}

/// Take in a list of tokens, and remove any incorrectly used tokens (and ignored tokens)
/// Example: "mul(2,4)%&mul[3,7]" would only return [Mul, LeftParen, Int(2), Comma, Int(4), RightParen
///
fn parse_do_dont(tokens: List(Token)) -> List(Token) {
  remove_invalid_tokens_do_dont(tokens, [], True)
}

/// Evaluate a valid list of instructions
///
fn evaluate(parsed_list: List(Token)) -> Int {
  parsed_list
  |> list.filter(fn(token) -> Bool {
    case token {
      Int(_) -> True
      _ -> False
    }
  })
  |> list.sized_chunk(into: 2)
  |> list.fold(0, fn(acc, pair) -> Int {
    acc
    + list.fold(pair, 1, fn(a, x) -> Int {
      case x {
        Int(wrapped_val) -> {
          case int.parse(wrapped_val) {
            Ok(int_val) -> a * int_val
            _ ->
              panic as "Should never have parsed an Int out of something that's not an Int"
          }
        }
        _ -> panic as "Should never be called with anything but Int"
      }
    })
  })
}

fn remove_invalid_tokens(
  tokens: List(Token),
  accumulator: List(Token),
) -> List(Token) {
  case list.first(tokens), list.rest(tokens) {
    Ok(token), Ok(rest) -> {
      case token {
        Mul -> {
          let parsed_list =
            expect_token(LeftParen, rest)
            |> result.try(expect_token(Int(""), in: _))
            |> result.try(expect_token(Comma, in: _))
            |> result.try(expect_token(Int(""), in: _))
            |> result.try(expect_token(RightParen, in: _))
          case parsed_list {
            Ok(_) -> {
              let #(valid_instruction, r) = list.split(tokens, 6)
              remove_invalid_tokens(
                r,
                list.append(accumulator, valid_instruction),
              )
            }
            Error(_) -> remove_invalid_tokens(rest, accumulator)
          }
        }
        _ -> remove_invalid_tokens(rest, accumulator)
      }
    }
    _, _ -> accumulator
  }
}

fn remove_invalid_tokens_do_dont(
  tokens: List(Token),
  accumulator: List(Token),
  evaluate: Bool,
) -> List(Token) {
  case list.first(tokens), list.rest(tokens) {
    Ok(token), Ok(rest) -> {
      case token, evaluate {
        Mul, True -> {
          let parsed_list =
            expect_token(LeftParen, rest)
            |> result.try(expect_token(Int(""), in: _))
            |> result.try(expect_token(Comma, in: _))
            |> result.try(expect_token(Int(""), in: _))
            |> result.try(expect_token(RightParen, in: _))
          case parsed_list {
            Ok(_) -> {
              let #(valid_instruction, r) = list.split(tokens, 6)
              remove_invalid_tokens_do_dont(
                r,
                list.append(accumulator, valid_instruction),
                evaluate,
              )
            }
            Error(_) ->
              remove_invalid_tokens_do_dont(rest, accumulator, evaluate)
          }
        }
        Do, _ -> {
          let parsed_list =
            expect_token(LeftParen, rest)
            |> result.try(expect_token(RightParen, in: _))
          case parsed_list {
            Ok(_) -> {
              let #(valid_instruction, r) = list.split(tokens, 3)
              remove_invalid_tokens_do_dont(
                r,
                list.append(accumulator, valid_instruction),
                True,
              )
            }
            Error(_) ->
              remove_invalid_tokens_do_dont(rest, accumulator, evaluate)
          }
        }
        Dont, _ -> {
          let parsed_list =
            expect_token(LeftParen, rest)
            |> result.try(expect_token(RightParen, in: _))
          case parsed_list {
            Ok(_) -> {
              let #(valid_instruction, r) = list.split(tokens, 3)
              remove_invalid_tokens_do_dont(
                r,
                list.append(accumulator, valid_instruction),
                False,
              )
            }
            Error(_) ->
              remove_invalid_tokens_do_dont(rest, accumulator, evaluate)
          }
        }
        _, _ -> remove_invalid_tokens_do_dont(rest, accumulator, evaluate)
      }
    }
    _, _ -> accumulator
  }
}

fn expect_token(token: Token, in l: List(Token)) -> Result(List(Token), Nil) {
  case list.first(l) {
    Ok(t) -> {
      case t == token {
        True -> {
          case list.rest(l) {
            Ok(remaining) -> Ok(remaining)
            _ -> Ok([])
          }
        }
        False -> {
          case t, token {
            Int(actual_int), Int(_) -> {
              case list.rest(l), string.length(actual_int) <= 3 {
                Ok(remaining), True -> Ok(remaining)
                _, _ -> Ok([])
              }
            }
            _, _ -> Error(Nil)
          }
        }
      }
    }
    _ -> Error(Nil)
  }
}

/// Take in a string, and return all valid tokens
///
fn lex(contents: String) -> List(Token) {
  to_token_list_loop(contents, [])
}

/// Take in a string, and return all valid tokens WITH do and don't
///
fn lex_do_dont(contents: String) -> List(Token) {
  to_token_list_loop_do_dont(contents, [])
}

fn to_token_list_loop(
  remaining: String,
  accumulator: List(Token),
) -> List(Token) {
  case to_token(remaining) {
    Error(_) -> {
      case string.pop_grapheme(remaining) {
        Error(_) -> accumulator
        Ok(#(_, r)) -> to_token_list_loop(r, accumulator)
      }
    }
    Ok(#(token, r)) -> {
      to_token_list_loop(r, list.append(accumulator, [token]))
    }
  }
}

fn to_token_list_loop_do_dont(
  remaining: String,
  accumulator: List(Token),
) -> List(Token) {
  case to_token_do_dont(remaining) {
    Error(_) -> {
      case string.pop_grapheme(remaining) {
        Error(_) -> accumulator
        Ok(#(_, r)) -> to_token_list_loop_do_dont(r, accumulator)
      }
    }
    Ok(#(token, r)) -> {
      to_token_list_loop_do_dont(r, list.append(accumulator, [token]))
    }
  }
}

// utils

fn take_while(str: String, predicate: fn(String) -> Bool) -> String {
  case string.pop_grapheme(str) {
    Error(_) -> str
    Ok(#(grapheme, remaining)) -> {
      case predicate(grapheme) {
        True -> grapheme <> take_while(remaining, predicate)
        False -> ""
      }
    }
  }
}

fn take_first_while(
  str: String,
  max_count: Int,
  predicate: fn(String) -> Bool,
) -> String {
  case string.pop_grapheme(str) {
    Error(_) -> str
    Ok(#(grapheme, remaining)) -> {
      case predicate(grapheme) {
        True ->
          grapheme <> take_first_while(remaining, max_count - 1, predicate)
        False -> ""
      }
    }
  }
}

fn is_name_grapheme(char: String) -> Bool {
  case char {
    "m" | "u" | "l" -> True
    _ -> False
  }
}

fn is_keyword_grapheme(char: String) -> Bool {
  case char {
    "m" | "u" | "l" | "d" | "o" | "n" | "'" | "t" -> True
    _ -> False
  }
}

fn is_integer_grapheme(char: String) -> Bool {
  case char {
    "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0" -> True
    _ -> False
  }
}
