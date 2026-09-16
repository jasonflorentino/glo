import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp

pub fn str_from_decode_errors(errors: List(decode.DecodeError)) -> String {
  errors
  |> list.map(fn(err) {
    let path = string.join(err.path, with: ".")
    string.join(
      [path, ": ", "Expected ", err.expected, ", found ", err.found],
      "",
    )
  })
  |> string.join(", ")
}

pub fn is_yesterday(now: timestamp.Timestamp) -> Bool {
  let #(_, time) = timestamp.to_calendar(now, calendar.utc_offset)
  // We're still in the late-night of the day prior ET
  time.hours < 10
}

pub fn is_morning(now: timestamp.Timestamp) -> Bool {
  let #(_, time) = timestamp.to_calendar(now, calendar.utc_offset)
  // Usually morning ET and not the day before
  !is_yesterday(now) && time.hours < 17
}

pub fn to_date_str(date: calendar.Date) -> String {
  let n2 = pad_zero(_, to: 2)
  let n4 = pad_zero(_, to: 4)

  string.join(
    [n4(date.year), n2(calendar.month_to_int(date.month)), n2(date.day)],
    "-",
  )
}

pub fn pad_zero(digit: Int, to desired_length: Int) -> String {
  int.to_string(digit) |> string.pad_start(desired_length, "0")
}
