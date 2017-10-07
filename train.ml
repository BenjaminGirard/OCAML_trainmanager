module type TRAIN =
sig
  val t : string
  val speed : int
  val stations : (string) list
end

module Tgv : TRAIN =
struct
  let t = "TGV"
  let speed = 230
  let stations = ["Brest"; "Le Havre"; "Lille"; "Paris"; "Strasbourg"; "Nancy";
		  "Dijon"; "Lyon"; "Nice"; "Marseille"; "Montpellier"; "Perpignan";
		  "Bordeaux"; "Nantes"; "Avignon"; "Rennes"; "Biarritz"; "Toulouse";
		 "Le Mans"]
end

module Thalys : TRAIN =
struct
  let t = "Thalys"
  let speed = 210
  let stations = ["Paris"; "Lille"; "Liege"; "Brussels"; "Amsterdam"; "Cologne"; "Essen"]
end

module Eurostar : TRAIN =
struct
  let t = "Eurostar"
  let speed = 160
  let stations = ["Paris"; "London"; "Brussels"; "Lille"]
end
