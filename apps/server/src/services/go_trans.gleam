import common/util
import gleam/option.{type Option}
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp
import go_api/client as go_client
import go_api/stops as go_stops
import go_api/timetable as go_timetable

pub fn fetch_timetable(
  from: Option(String),
  to: Option(String),
  date: Option(String),
) -> Result(go_timetable.Timetable, String) {
  let now = timestamp.system_time()
  let from =
    from
    |> option.unwrap(or: get_default_from(now))
  let to = to |> option.unwrap(or: get_default_to(now))
  let date = date |> option.unwrap(or: get_default_date(now))

  let client = go_client.new(go_client.Config(go_client.metrolinx_base, ""))
  go_client.get_timetable(client, from, to, date)
}

fn get_default_date(now: timestamp.Timestamp) -> String {
  let d = case util.is_yesterday(now) {
    True -> timestamp.subtract(now, duration.hours(24))
    False -> now
  }
  let #(d, _) = timestamp.to_calendar(d, calendar.utc_offset)
  util.to_date_str(d)
}

fn get_default_from(now: timestamp.Timestamp) -> String {
  case util.is_morning(now) {
    True -> go_stops.to_code(go_stops.WestHarbour)
    False -> go_stops.to_code(go_stops.UnionStation)
  }
}

fn get_default_to(now: timestamp.Timestamp) -> String {
  case util.is_morning(now) {
    True -> go_stops.to_code(go_stops.UnionStation)
    False -> go_stops.to_code(go_stops.WestHarbour)
  }
}
