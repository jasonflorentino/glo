import gleam/option
import go_api/stops
import go_api/timetable

pub type Message {
  ComputerUpdatedFrom(
    option.Option(stops.Stop),
    option.Option(stops.Stop),
    option.Option(List(stops.Stop)),
  )
  CopyFeedbackWindowEnded(id: String)
  FetchTimetableError(String)
  RuntimeError(String)
  ServerReturnedTimetable(timetable.Timetable)
  UserPressedFetch
  UserChangedFrom(String)
  UserChangedTo(String)
  UserClickedCopy(id: String, text: String)
}
