module type TRAIN =
sig
  val t : string
  val speed : int
  val stations : (string) list
end

module Tgv : TRAIN
module Thalys : TRAIN
module Eurostar : TRAIN
