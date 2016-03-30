(** Returns true if element is an Archimate Diagram *)
let is_diagram xdata =
  match xdata with
  | Xml.PCData pc -> false
  | Xml.Element el ->
    let tag, attrs, _ = el in
    let xsi_type = XmlUtil.attr_val attrs "xsi:type" in
    tag = "element" && xsi_type = "archimate:ArchimateDiagramModel";;

let rec find_diagrams diagram_list xdata =
  match xdata with
  | Xml.PCData pc -> diagram_list
  | Xml.Element el ->
    Xml.fold find_diagrams (if is_diagram xdata then diagram_list @ [xdata] else diagram_list) xdata;
