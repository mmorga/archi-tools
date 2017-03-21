open Printf
(* open Core.Std *)

(** Prints a pair - for debugging *)
let print_pair k v =
  printf "%s\n" k

(** Prints an element and it's attribute values *)
let xdata_attrs xdata =
  printf "Element: %s\n" (Xml.tag xdata);
  List.iter (fun p -> let (attr, aval) = p in printf "  Attrib: %s=%s\n" attr aval) (Xml.attribs xdata);;

(** Prints the list of diagrams *)
let pr_dia_list dia_list =
  List.iter xdata_attrs dia_list;;

(*******************************************************)

let archi_file = "/Users/mmorga/work/ea-architecture/ea.archimate"
and svg_template_file = "template/diagram.svg" in
let archi_doc = Xml.parse_file archi_file in
let diagrams = Archimate.find_diagrams [] archi_doc in
let svg_doc = Svg.svg_template svg_template_file in

Svg.make_svgs archi_file svg_doc diagrams;;
