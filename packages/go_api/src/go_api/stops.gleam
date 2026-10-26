import gleam/list
import gleam/option.{type Option, None, Some}

pub type Stop {
  Acton
  Agincourt
  Ajax
  Aldershot
  AllandaleWaterfront
  Appleby
  Aurora
  BarrieSouth
  Bloor
  Bradford
  Bramalea
  BramptonInnovationDistrict
  Bronte
  Burlington
  Centennial
  Clarkson
  Confederation
  Cooksville
  Danforth
  Dixie
  DownsviewPark
  DurhamCollegeOshawa
  EastGwillimbury
  Eglinton
  Erindale
  EtobicokeNorth
  Exhibition
  Georgetown
  Gormley
  GuelphCentral
  Guildwood
  HamiltonGoCentre
  Kennedy
  KingCity
  Kipling
  Kitchener
  Langstaff
  Lisgar
  LongBranch
  Malton
  Maple
  Markham
  Meadowvale
  Milliken
  Milton
  Mimico
  MountDennis
  MountJoy
  MountPleasant
  Newmarket
  NiagaraFalls
  Oakville
  OldCummer
  OldElm
  Oriole
  PearsonAirport
  Pickering
  PortCredit
  RichmondHill
  RougeHill
  Rutherford
  Scarborough
  SquareOneGoTerminal
  StCatharines
  Stouffville
  Streetsville
  Unionville
  UnionStation
  WestHarbour
  Weston
  Whitby
}

pub fn to_code(stop: Stop) -> String {
  case stop {
    Acton -> "AC"
    Agincourt -> "AG"
    Ajax -> "AJ"
    Aldershot -> "AL"
    AllandaleWaterfront -> "AD"
    Appleby -> "AP"
    Aurora -> "AU"
    BarrieSouth -> "BA"
    Bloor -> "BL"
    Bradford -> "BD"
    Bramalea -> "BE"
    BramptonInnovationDistrict -> "BR"
    Bronte -> "BO"
    Burlington -> "BU"
    Centennial -> "CE"
    Clarkson -> "CL"
    Confederation -> "CF"
    Cooksville -> "CO"
    Danforth -> "DA"
    Dixie -> "DI"
    DownsviewPark -> "DW"
    DurhamCollegeOshawa -> "OS"
    EastGwillimbury -> "EA"
    Eglinton -> "EG"
    Erindale -> "ER"
    EtobicokeNorth -> "ET"
    Exhibition -> "EX"
    Georgetown -> "GE"
    Gormley -> "GO"
    GuelphCentral -> "GL"
    Guildwood -> "GU"
    HamiltonGoCentre -> "HA"
    Kennedy -> "KE"
    KingCity -> "KC"
    Kipling -> "KP"
    Kitchener -> "KI"
    Langstaff -> "LA"
    Lisgar -> "LS"
    LongBranch -> "LO"
    Malton -> "MA"
    Maple -> "MP"
    Markham -> "MR"
    Meadowvale -> "ME"
    Milliken -> "MK"
    Milton -> "ML"
    Mimico -> "MI"
    MountDennis -> "MD"
    MountJoy -> "MJ"
    MountPleasant -> "MO"
    Newmarket -> "NE"
    NiagaraFalls -> "NI"
    Oakville -> "OA"
    OldCummer -> "OL"
    OldElm -> "LI"
    Oriole -> "OR"
    PearsonAirport -> "PA"
    Pickering -> "PIN"
    PortCredit -> "PO"
    RichmondHill -> "RI"
    RougeHill -> "RO"
    Rutherford -> "RU"
    Scarborough -> "SC"
    SquareOneGoTerminal -> "00132"
    StCatharines -> "SCTH"
    Stouffville -> "ST"
    Streetsville -> "SR"
    Unionville -> "UI"
    UnionStation -> "UN"
    WestHarbour -> "WR"
    Weston -> "WE"
    Whitby -> "WH"
  }
}

pub fn to_name(stop: Stop) -> String {
  case stop {
    Acton -> "Acton GO"
    Agincourt -> "Agincourt GO"
    Ajax -> "Ajax GO"
    Aldershot -> "Aldershot GO"
    AllandaleWaterfront -> "Allandale Waterfront GO"
    Appleby -> "Appleby GO"
    Aurora -> "Aurora GO"
    BarrieSouth -> "Barrie South GO"
    Bloor -> "Bloor GO"
    Bradford -> "Bradford GO"
    Bramalea -> "Bramalea GO"
    BramptonInnovationDistrict -> "Brampton Innovation District GO"
    Bronte -> "Bronte GO"
    Burlington -> "Burlington GO"
    Centennial -> "Centennial GO"
    Clarkson -> "Clarkson GO"
    Confederation -> "Confederation GO"
    Cooksville -> "Cooksville GO"
    Danforth -> "Danforth GO"
    Dixie -> "Dixie GO"
    DownsviewPark -> "Downsview Park GO"
    DurhamCollegeOshawa -> "Durham College Oshawa GO"
    EastGwillimbury -> "East Gwillimbury GO"
    Eglinton -> "Eglinton GO"
    Erindale -> "Erindale GO"
    EtobicokeNorth -> "Etobicoke North GO"
    Exhibition -> "Exhibition GO"
    Georgetown -> "Georgetown GO"
    Gormley -> "Gormley GO"
    GuelphCentral -> "Guelph Central GO"
    Guildwood -> "Guildwood GO"
    HamiltonGoCentre -> "Hamilton GO Centre"
    Kennedy -> "Kennedy GO"
    KingCity -> "King City GO"
    Kipling -> "Kipling GO"
    Kitchener -> "Kitchener GO"
    Langstaff -> "Langstaff GO"
    Lisgar -> "Lisgar GO"
    LongBranch -> "Long Branch GO"
    Malton -> "Malton GO"
    Maple -> "Maple GO"
    Markham -> "Markham GO"
    Meadowvale -> "Meadowvale GO"
    Milliken -> "Milliken GO"
    Milton -> "Milton GO"
    Mimico -> "Mimico GO"
    MountDennis -> "Mount Dennis GO"
    MountJoy -> "Mount Joy GO"
    MountPleasant -> "Mount Pleasant GO"
    Newmarket -> "Newmarket GO"
    NiagaraFalls -> "Niagara Falls GO (VIA Station)"
    Oakville -> "Oakville GO"
    OldCummer -> "Old Cummer GO"
    OldElm -> "Old Elm GO"
    Oriole -> "Oriole GO"
    PearsonAirport -> "Pearson Airport"
    Pickering -> "Pickering GO"
    PortCredit -> "Port Credit GO"
    RichmondHill -> "Richmond Hill GO"
    RougeHill -> "Rouge Hill GO"
    Rutherford -> "Rutherford GO"
    Scarborough -> "Scarborough GO"
    SquareOneGoTerminal -> "Square One GO Terminal"
    StCatharines -> "St. Catharines GO (VIA Station)"
    Stouffville -> "Stouffville GO"
    Streetsville -> "Streetsville GO"
    Unionville -> "Unionville GO"
    UnionStation -> "Union Station"
    WestHarbour -> "West Harbour GO"
    Weston -> "Weston GO"
    Whitby -> "Whitby GO"
  }
}

pub const barrie = [
  AllandaleWaterfront,
  BarrieSouth,
  Bradford,
  EastGwillimbury,
  Newmarket,
  Aurora,
  KingCity,
  Maple,
  Rutherford,
  DownsviewPark,
  UnionStation,
]

pub const kitchener = [
  Kitchener,
  GuelphCentral,
  Acton,
  Georgetown,
  MountPleasant,
  BramptonInnovationDistrict,
  Bramalea,
  Malton,
  EtobicokeNorth,
  Weston,
  MountDennis,
  Bloor,
  UnionStation,
]

pub const lakeshore_east = [
  DurhamCollegeOshawa,
  Whitby,
  Ajax,
  Pickering,
  RougeHill,
  Guildwood,
  Eglinton,
  Scarborough,
  Danforth,
  UnionStation,
]

pub const lakeshore_west = [
  NiagaraFalls,
  StCatharines,
  Confederation,
  WestHarbour,
  HamiltonGoCentre,
  Aldershot,
  Burlington,
  Appleby,
  Bronte,
  Oakville,
  Clarkson,
  PortCredit,
  LongBranch,
  Mimico,
  Exhibition,
  UnionStation,
]

pub const milton = [
  Milton,
  Lisgar,
  Meadowvale,
  Streetsville,
  Erindale,
  Cooksville,
  Dixie,
  Kipling,
  UnionStation,
]

pub const richmond_hill = [
  Gormley,
  RichmondHill,
  Langstaff,
  OldCummer,
  Oriole,
  UnionStation,
]

pub const stouffville = [
  OldElm,
  Stouffville,
  MountJoy,
  Markham,
  Centennial,
  Unionville,
  Milliken,
  Agincourt,
  Kennedy,
  UnionStation,
]

pub const lines = [
  barrie,
  kitchener,
  lakeshore_east,
  lakeshore_west,
  milton,
  richmond_hill,
  stouffville,
]

fn equal(a, b: Stop) -> Bool {
  a == b
}

pub fn line_has_stop(line: List(Stop), stop: Stop) -> Bool {
  list.any(line, equal(_, stop))
}

/// Assumes every stop appears in exactly one line (Except Union)
pub fn get_sister_stops(stop: Stop) -> Option(List(Stop)) {
  case stop == UnionStation {
    True -> {
      lines |> list.flatten |> list.unique |> remove_stop(UnionStation) |> Some
    }
    False -> {
      let line = lines |> list.find(line_has_stop(_, stop))
      case line {
        Ok(line) -> line |> remove_stop(stop) |> Some
        Error(_) -> None
      }
    }
  }
}

pub fn remove_stop(list: List(Stop), stop: Stop) -> List(Stop) {
  list.filter(list, fn(s) { s != stop })
}
