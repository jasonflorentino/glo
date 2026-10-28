import gleam/option
import go_api/stops
import go_api/timetable

pub type Message {
  ComputerUpdatedFrom(option.Option(List(stops.Stop)))
  FetchTimetableError(String)
  RuntimeError(String)
  ServerReturnedTimetable(timetable.Timetable)
  UserPressedFetch
  UserChangedFrom(String)
}
