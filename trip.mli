module type INFO =
sig
  val destinations : (string) list
  val trips : (string * string) list
  val getStr : (string * string) -> string
  val getId : (string * string) -> string
  val string_to_list : char -> string -> (string) list
end

module type DATA =
sig
  val distances : (string * string * int)  list
  val getFTown : (string * string * int) -> string
  val getSTown : (string * string * int) -> string
  val getDist : (string * string * int) -> int
end

module D : DATA

module type TRIP =
sig
  val check_id : int -> (string * string) list -> bool
  val setid : int -> int
  val id : string
  val hour_to_minint : string -> int
  val minint_to_hour : int -> string
  val duration_minute : string -> string -> (string * string * int) list -> int
  val trip : (string * string) list
  val create : int -> (string) list -> string -> string
  val begin_trip : (string) list -> string -> string
  val continue_trip : string -> string -> int -> string -> string
  val end_trip : string -> string -> int -> string -> string
end


module type MAKETRIP = functor (T : Train.TRAIN) (D : DATA) (I : INFO) -> TRIP

module MakeTrip : MAKETRIP
