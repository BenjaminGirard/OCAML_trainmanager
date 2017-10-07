
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

module D : DATA =
struct
  let distances = [("Paris" , "Lyon" , 427);
		   ("Dijon" , "Lyon" , 192);
		   ("Paris" , "Lille" , 225);
		   ("Paris" , "Nancy" , 327);
                   ("Dijon" , "Nancy" , 226);
		   ("Brest" , "Rennes" , 248);
                   ("Lille" , "London" , 269);
		   ("Liege" , "Cologone" , 118);
                   ("Le Mans" , "Paris" , 201);
		   ("Cologne" , "Essen" , 81);
		   ("Lyon" , "Marseille" , 325);
                   ("Brussels" , "Liege" , 104);
		   ("Paris" , "Le Havre" , 230);
		   ("Rennes" , "Le Mans" , 163);
		   ("Le Mans" , "Nantes" , 183);
		   ("Paris" , "Bordeaux" , 568);
                   ("Lille" , "Brussels" , 106);
		   ("Nancy" , "Strasbourg" , 149);
		   ("Paris" , "Strasbourg" , 449);
                   ("Dijon" , "Strasbourg" , 309);
                   ("Toulouse" , "Bordeaux" , 256);
                   ("Brussels" , "Amsterdam" , 211);
		   ("Montpellier" , "Toulouse" , 248);
                   ("Marseille" , "Montpellier" , 176)]

  let getFTown (f, _, _) = f
  let getSTown (_, s, _) = s
  let getDist (_, _, d) = d

end

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

module MakeTrip : MAKETRIP = functor (T : Train.TRAIN) (D : DATA) (I : INFO) ->
struct

  let rec check_id id list =
    if (list == []) then true
    else if (String.compare (I.getId (List.hd list)) (T.t ^ string_of_int(id)) == 0) then false
    else (check_id id (List.tl list))

  let rec setid  id =
    if ((check_id id I.trips) == true) then id
    else (setid ((Random.int 8999) + 1000))

  let id = T.t ^ string_of_int(setid ((Random.int 8999) + 1000))

  let hour_to_minint hour =
    ((int_of_string(String.sub hour 0 2)) * 60) + (int_of_string(String.sub hour 3 2))

  let minint_to_hour min =
    (if ((min / 60) < 10) then ("0" ^ string_of_int(min / 60)) else (string_of_int(min / 60)))
    ^ ":"
    ^ (if ((min mod 60) < 10) then ("0"^string_of_int(min mod 60)) else (string_of_int(min mod 60)))

  let rec duration_minute t1 t2 dist =
    if (dist == []) then 0
    else if ((String.compare t1 (D.getFTown (List.hd dist)) == 0 &&
		String.compare t2 (D.getSTown (List.hd dist)) == 0)
	     || (String.compare t2 (D.getFTown (List.hd dist)) == 0 &&
		   String.compare t1 (D.getSTown (List.hd dist)) == 0))
    then (truncate(ceil((float_of_int(D.getDist (List.hd dist)) *. 60.0) /. float_of_int(T.speed))))
    else duration_minute t1 t2 (List.tl dist)

  let begin_trip dest str =
    str ^ T.t ^ " " ^ (String.sub id (String.length T.t) 4) ^ "\n" ^ (List.nth dest 0)
    ^ " (,) (" ^ (List.nth I.destinations 2) ^ "," ^ (List.nth I.destinations 3) ^ ")\n"

  let continue_trip from dest min_from str =
    str ^ dest ^ " (" ^ (List.nth I.destinations 2) ^ ","
    ^ (minint_to_hour (min_from + (duration_minute from dest D.distances))) ^ ") ("
    ^ (List.nth I.destinations 2) ^ ","
    ^ (minint_to_hour(min_from + (duration_minute from dest D.distances) + 10)) ^ ")\n"

  let end_trip from dest min_from str =
    str ^ dest ^ " (" ^ (List.nth I.destinations 2) ^ ","
    ^ (minint_to_hour (min_from + (duration_minute from dest D.distances))) ^ ") (,)"

  let rec create i dest str =
    if (i == List.length dest) then str
    else if (i == 0) then create (i + 1) dest (str ^ (begin_trip dest str))
    else if (i == (List.length dest - 1)) then
      create (i + 1) dest (end_trip (List.nth dest (i - 1)) (List.nth dest i)
			     (hour_to_minint (String.sub str (String.length str - 7) 5)) str)
    else
      create (i + 1) dest (continue_trip (List.nth dest (i - 1)) (List.nth dest i)
			     (hour_to_minint (String.sub str (String.length str - 7) 5)) str)

  let trip = [((create 0 (I.string_to_list ',' (List.nth I.destinations 4)) ""), id)]

end
