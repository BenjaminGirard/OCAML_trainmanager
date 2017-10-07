
module type PARSING =
sig
  val epur_str : string -> string
  val string_to_list : char -> string -> (string) list
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

module P : PARSING =
struct

  let getStr (str, _) = str
  let getId (_, id) = id

  let rec epur_str = function
    |"" -> ""
    |str when str.[0] == ' ' -> ((String.sub str 0 1)^epur_str(String.trim str))
    |str -> ((String.sub str 0 1)^epur_str(String.sub str 1 ((String.length str) - 1)))

  let rec string_to_list sep = function
    | ""  -> []
    | str when (String.contains str sep) -> (String.sub str 0 (String.index str sep))::
      (string_to_list sep (String.sub str ((String.index str sep) + 1) ((String.length str) - ((String.index str sep) + 1))))
    | str -> [str]

  let rec print_trips list list_s n =
    if (list == []) then list_s
    else
      begin
	print_endline (getStr (List.hd list));
	print_trips (List.tl list) list_s (n + 1)
      end

  let remove_at id list =
    if ((id < 0) || (id >= List.length list)) then
      begin
	prerr_string ("Can't remove element at position " ^ string_of_int(id) ^ "\n");
	list
      end
    else
      let rec delete id = function
	|[] -> []
	|head::tail when id == 0 -> tail
	|head::tail -> head :: delete (id - 1) tail
      in delete id list

  let rec is_num c str =
    if (c >= String.length str) then true
    else if (String.get str c) < '0' || (String.get str c) > '9' then false
    else is_num (c + 1) str

  let rec delete_trip cmd trips id =
    if (trips == [] || id >= List.length trips) then
      begin
	prerr_string ("Can't delete " ^ (List.nth cmd 1) ^ "\n");
	trips
      end
    else if (String.compare (List.nth cmd 1) (getId (List.hd trips)) == 0) then remove_at id trips
    else delete_trip cmd trips (id + 1)

  let check_type str =
    if (String.compare str "TGV" != 0 &&
	String.compare str "Eurostar" != 0 &&
	String.compare str "Thalys" != 0) then false
    else true

  let rec check_date_format c str =
    if (String.length str != 10) then false
    else if (c >= String.length str) then true
    else if ((c == 2 || c == 5) && str.[c] != '-') then false
    else if ((c != 2 && c != 5) && is_num 0 (String.sub str c 1) == false) then false
    else check_date_format (c + 1) str

  let check_date_consistency str =
    let day = int_of_string(String.sub str 0 2)
    and month = int_of_string(String.sub str 3 2)
    and year = int_of_string(String.sub str 6 4)
    in ((day != 0 && day <= 31) && (month != 0 && month <= 12) && (year != 0 && year >= 1000))

  let rec check_time_format c str =
    if (String.length str != 5) then false
    else if (c >= String.length str) then true
    else if ((c == 2) && str.[c] != ':') then false
    else if ((c != 2) && is_num 0 (String.sub str c 1) == false) then false
    else check_time_format (c + 1) str

  let check_time_consistency str =
    let hours = int_of_string(String.sub str 0 2)
    and minutes = int_of_string(String.sub str 3 2)
    in ((hours >= 0 && hours <= 23) && (minutes >= 0 && minutes <= 59))

  let rec check_stations  s stations t =
    if (List.length s < 2) then false
    else if (stations == []) then true
    else match t with
      |"TGV" when (List.mem (List.hd stations) Train.Tgv.stations) == true
	  -> check_stations s (List.tl stations) t
      |"Eurostar" when (List.mem (List.hd stations) Train.Eurostar.stations) == true
	  -> check_stations s (List.tl stations) t
      |"Thalys" when (List.mem (List.hd stations) Train.Thalys.stations) == true
	  -> check_stations s (List.tl stations) t
      |_ -> false


  let create_trips cmd t =
    let module I =
	struct
	  let destinations = cmd
	  let trips = t
	  let getStr (str, _) = str
	  let getId (_, id) = id
	  let rec string_to_list sep = function
	    | ""  -> []
	    | str when (String.contains str sep) -> (String.sub str 0 (String.index str sep))::
	      (string_to_list sep (String.sub str ((String.index str sep) + 1) ((String.length str) - ((String.index str sep) + 1))))
	    | str -> [str]
	end
    in
    if (String.compare (List.nth cmd 1) "TGV" == 0) then
      begin
	let module TgvTrip = Trip.MakeTrip (Train.Tgv) (Trip.D) (I)
	in
	print_endline ("Trip created: TGV " ^ (String.sub (I.getId(List.hd TgvTrip.trip)) 3 4));
	t@TgvTrip.trip
      end
    else if (String.compare (List.nth cmd 1) "Eurostar" == 0) then
      begin
	let module EurostarTrip = Trip.MakeTrip (Train.Eurostar) (Trip.D) (I)
	in
	print_endline ("Trip created: Eurostar " ^ (String.sub (I.getId(List.hd EurostarTrip.trip)) 8 4));
	t@EurostarTrip.trip
      end
    else
      begin
	let module ThalysTrip = Trip.MakeTrip (Train.Thalys) (Trip.D) (I)
	in
	print_endline ("Trip created: Thalys " ^ (String.sub (I.getId(List.hd ThalysTrip.trip)) 6 4));
	t@ThalysTrip.trip
      end

  let parse_cmd cmd trips =
    if ((List.length cmd) == 0) then trips
    else match (List.hd cmd) with
      |"create" when (List.length cmd) == 5 &&
	  check_type (List.nth cmd 1) == true &&
	  check_date_format 0 (List.nth cmd 2) == true &&
	  check_date_consistency (List.nth cmd 2) == true &&
	  check_time_format 0 (List.nth cmd 3) == true &&
	  check_time_consistency (List.nth cmd 3) == true &&
	  check_stations (string_to_list  ',' (List.nth cmd 4))
	  (string_to_list  ',' (List.nth cmd 4)) (List.nth cmd 1) == true
	  -> create_trips cmd trips
      |"delete" when (List.length cmd) == 2 -> delete_trip cmd trips 0
      |"list" when (List.length cmd) == 1 -> print_trips trips trips 0
      |"quit" when (List.length cmd) == 1 -> exit 0
      |_ ->  print_endline "error" ; trips

end
