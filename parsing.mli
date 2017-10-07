
module type PARSING =
sig
  val epur_str : string -> string
  val string_to_list : char -> string -> (string) list
  (* val strstr : string -> string -> int -> int -> bool *)
  val print_trips : (string * string) list -> (string * string) list -> int -> (string * string) list
  val parse_cmd : (string) list -> (string * string) list -> (string * string) list
  val delete_trip : (string) list -> (string * string) list -> int -> (string * string) list
  val getStr : (string * string) -> string
  val getId : (string * string) -> string
  val remove_at : int -> 'a list -> 'a list
  val is_num : int -> string -> bool
  val check_type : string -> bool
  val check_date_format : int -> string -> bool
  val check_date_consistency : string -> bool
  val check_time_format : int -> string -> bool
  val check_time_consistency : string -> bool
  val check_stations : (string) list -> (string) list -> string -> bool
  val create_trips : (string) list -> (string * string) list -> (string * string) list
end

module P : PARSING
