let rec main trips =
  let line = try read_line () with
    | End_of_file -> exit 0
  in
  let trips = Parsing.P.parse_cmd (Parsing.P.string_to_list ' ' (Parsing.P.epur_str (String.trim line))) trips
  in
  main trips

(**********************************************************)

let _ = main []








  (* let () =  print_list list list 0; *)

