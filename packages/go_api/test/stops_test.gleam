import gleam/list
import gleeunit/should
import go_api/stops.{Ajax, HamiltonGoCentre, UnionStation, WestHarbour, Whitby}

pub fn returns_a_matching_line_test() {
  // lakeshort_west
  let sister_stops = stops.get_sister_stops(WestHarbour)
  let sister_stops = sister_stops |> should.be_some
  sister_stops |> stops.line_has_stop(HamiltonGoCentre) |> should.be_true

  let sister_stops = stops.get_sister_stops(WestHarbour)
  let sister_stops = sister_stops |> should.be_some
  sister_stops |> stops.line_has_stop(Ajax) |> should.be_false

  // lakeshort_east
  let sister_stops = stops.get_sister_stops(Whitby)
  let sister_stops = sister_stops |> should.be_some
  sister_stops |> stops.line_has_stop(Ajax) |> should.be_true

  let sister_stops = stops.get_sister_stops(Whitby)
  let sister_stops = sister_stops |> should.be_some
  sister_stops |> stops.line_has_stop(HamiltonGoCentre) |> should.be_false
}

pub fn lines_have_uniq_stops_test() {
  let combined = list.flat_map(stops.lines, stops.remove_stop(_, UnionStation))
  let uniq = list.unique(combined)
  list.length(combined) |> should.equal(list.length(uniq))
}
