(* module Model = *)
(* struct *)
type archimate_version = ArchiMate2_1 | ArchiMate3_0

type model = {
  id : string;
  version : archimate_version;
  name : string;
  (* documentation : documentation list; *)
  (* properties : property list; *)
  (* elements : element list; *)
  (* folders : folder list; *)
  (* relationships : relationship list; *)
  (* diagrams : diagram list; *)
}

let make id version name =
  { id = id; version = version; name = name; }

(* end *)

