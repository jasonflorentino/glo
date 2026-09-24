import go_api/timetable

pub type Message {
  FetchTimetableError(String)
  ServerReturnedTimetable(timetable.Timetable)
  UserPressedFetch
}
