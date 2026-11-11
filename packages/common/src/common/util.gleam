import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp

pub fn is_morning(now: timestamp.Timestamp) -> Bool {
  let #(_, time) = timestamp.to_calendar(now, calendar.utc_offset)
  // Usually morning ET and not the day before
  !is_yesterday(now) && time.hours < 17
}

pub fn is_yesterday(now: timestamp.Timestamp) -> Bool {
  let #(_, time) = timestamp.to_calendar(now, calendar.utc_offset)
  // We're still in the late-night of the day prior ET
  time.hours < 10
}

pub fn pad_zero(digit: Int, to desired_length: Int) -> String {
  int.to_string(digit) |> string.pad_start(desired_length, "0")
}

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

/// 1h23m
pub fn time_str_from_minutes(mins: Int) -> String {
  let h = mins / 60
  let m = mins % 60
  case h, m {
    0, _ -> int.to_string(m) <> "m"
    _, _ -> int.to_string(h) <> "h" <> pad_zero(m, to: 2) <> "m"
  }
}

/// YYYY-MM-DD
pub fn to_date_str(date: calendar.Date) -> String {
  let n2 = pad_zero(_, to: 2)
  let n4 = pad_zero(_, to: 4)

  string.join(
    [n4(date.year), n2(calendar.month_to_int(date.month)), n2(date.day)],
    "-",
  )
}

/// Mon Jan 2, 2006
pub fn to_day_date_str(date: calendar.Date) -> String {
  let day = calendar.day_of_week(date)
  string.join(
    [
      day_to_str(day, short: True),
      " ",
      month_to_str(date.month, short: True),
      " ",
      int.to_string(date.day),
      ", ",
      int.to_string(date.year),
    ],
    "",
  )
}

pub fn day_to_str(day: calendar.DayOfWeek, short short: Bool) -> String {
  let str = case day {
    calendar.Monday -> "Monday"
    calendar.Tuesday -> "Tuesday"
    calendar.Wednesday -> "Wednesday"
    calendar.Thursday -> "Thursday"
    calendar.Friday -> "Friday"
    calendar.Saturday -> "Saturday"
    calendar.Sunday -> "Sunday"
  }
  case short {
    True -> string.slice(str, at_index: 0, length: 3)
    False -> str
  }
}

pub fn month_to_str(month: calendar.Month, short short: Bool) -> String {
  let str = case month {
    calendar.January -> "January"
    calendar.February -> "February"
    calendar.March -> "March"
    calendar.April -> "April "
    calendar.May -> "May"
    calendar.June -> "June"
    calendar.July -> "July"
    calendar.August -> "August"
    calendar.September -> "September"
    calendar.October -> "October"
    calendar.November -> "November"
    calendar.December -> "December"
  }
  case short {
    True -> string.slice(str, at_index: 0, length: 3)
    False -> str
  }
}
