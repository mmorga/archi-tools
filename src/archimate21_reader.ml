open Datamodel

module OrderedXmlName =
struct type t = Xmlm.name
  let compare a b =
    let a0, a1 = a in
    let b0, b1 = b in
    let nscmp = String.compare a0 b0 in
    match nscmp with
    | 0 -> String.compare a1 b1
    | _ -> nscmp
end
module AttributeMap = Map.Make(OrderedXmlName)

let map_attributes attrs =
  let add_attr_map attr m =
    let name, value = attr in
    AttributeMap.add name value m
  in
  List.fold_right add_attr_map attrs AttributeMap.empty

let has_type key v =
  key == ("", "type")

let key_exists key k v =
  k == ("", key)

let fetch_ns ns key m =
  try
    AttributeMap.find (ns, key) m
  with Not_found ->
    Format.fprintf Format.std_formatter "Unable to find attribute '%s:%s' in attribute map" ns key;
    raise Not_found

let fetch key m =
  fetch_ns "" key m

let fetch_with_default key default m =
  match AttributeMap.exists (key_exists key) m with
  | true -> fetch key m
  | false -> default

let fetch_optional key m =
  match AttributeMap.exists (key_exists key) m with
  | true -> Some (fetch key m)
  | false -> None

let fetch_optional_float key m =
  match fetch_optional key m with
  | Some s -> Some (float_of_string s)
  | None -> None

let fetch_optional_int key m =
  match fetch_optional key m with
  | Some s -> Some (int_of_string s)
  | None -> None

let fetch_float key m =
  float_of_string (fetch key m)

(* debug helpers *)

let dump_attribute attr =
  let (ns, name), aval = attr in
  Format.fprintf Format.std_formatter "%s:%s = '%s'\n" ns name aval

let dump_attrs attrs =
  List.iter dump_attribute attrs


(* Real code starts here *)

let el tag childs =
  let (ns, name), attrs = tag in
  let attribute_map = map_attributes attrs in
  (* ignore(dump_attrs attrs); *)
  match name with
  | "model" ->
    Model {
      id = fetch "id" attribute_map;
      version = Datamodel.ArchiMate2_1;
      name = fetch "name" attribute_map;
      documentation = find_all_nodes is_documentation to_documentation childs;
      properties = find_all_nodes is_property to_property childs;
      elements = find_all_nodes is_element to_element childs;
      folders = find_all_nodes is_folder to_folder childs;
      relationships = find_all_nodes is_relationship to_relationship childs;
      diagrams = find_all_nodes is_diagram to_diagram childs;
    }
  | "documentation"
  | "purpose" ->
    Documentation {
        lang = fetch_optional "lang" attribute_map;
        content = data_child_content childs;
      }
  | "content" ->
    Data (data_child_content childs)
  | "folder" ->
    Folder {
      id = fetch "id" attribute_map;
      name = fetch "name" attribute_map;
      folder_type = fetch_optional "type" attribute_map;
      items = folder_items childs;
      documentation = find_all_nodes is_documentation to_documentation childs;
      properties = find_all_nodes is_property to_property childs;
      folders = find_all_nodes is_folder to_folder childs;
    }
  | "element" -> (
      let t = fetch_ns "http://www.w3.org/2001/XMLSchema-instance" "type" attribute_map in
      match t with
      | "archimate:AccessRelationship"
      | "archimate:AggregationRelationship"
      | "archimate:AssignmentRelationship"
      | "archimate:AssociationRelationship"
      | "archimate:CompositionRelationship"
      | "archimate:FlowRelationship"
      | "archimate:InfluenceRelationship"
      | "archimate:RealisationRelationship"
      | "archimate:SpecialisationRelationship"
      | "archimate:TriggeringRelationship"
      | "archimate:UsedByRelationship" ->
        Relationship {
          id = fetch "id" attribute_map;
          name = fetch_optional "name" attribute_map;
          (* TODO: strip off the "archimate:" prefix from type *)
          relationship_type = fetch_ns "http://www.w3.org/2001/XMLSchema-instance" "type" attribute_map;
          source = fetch "source" attribute_map;
          target = fetch "target" attribute_map;
          documentation = find_all_nodes is_documentation to_documentation childs;
          properties = find_all_nodes is_property to_property childs;
        }
      | "archimate:SketchModel"
      | "archimate:ArchimateDiagramModel" ->
        Diagram {
          id = fetch "id" attribute_map;
          name = fetch "name" attribute_map;
          viewpoint = fetch_optional "viewpoint" attribute_map;
          documentation = find_all_nodes is_documentation to_documentation childs;
          properties = find_all_nodes is_property to_property childs;
          children = find_all_nodes is_child to_child childs;
          connection_router_type = fetch_optional_int "connectionRouterType" attribute_map;
          diagram_type = fetch_optional "diagramType" attribute_map;
        }
      | "archimate:AndJunction"
      | "archimate:Junction"
      | "archimate:OrJunction"
      | "archimate:ApplicationCollaboration"
      | "archimate:ApplicationComponent"
      | "archimate:ApplicationFunction"
      | "archimate:ApplicationInteraction"
      | "archimate:ApplicationInterface"
      | "archimate:ApplicationService"
      | "archimate:Artifact"
      | "archimate:Assessment"
      | "archimate:BusinessActor"
      | "archimate:BusinessCollaboration"
      | "archimate:BusinessEvent"
      | "archimate:BusinessFunction"
      | "archimate:BusinessInteraction"
      | "archimate:BusinessInterface"
      | "archimate:BusinessObject"
      | "archimate:BusinessProcess"
      | "archimate:BusinessRole"
      | "archimate:BusinessService"
      | "archimate:CommunicationPath"
      | "archimate:Constraint"
      | "archimate:Contract"
      | "archimate:DataObject"
      | "archimate:Deliverable"
      | "archimate:Device"
      | "archimate:Driver"
      | "archimate:Gap"
      | "archimate:Goal"
      | "archimate:InfrastructureFunction"
      | "archimate:InfrastructureInterface"
      | "archimate:InfrastructureService"
      | "archimate:Location"
      | "archimate:Meaning"
      | "archimate:Network"
      | "archimate:Node"
      | "archimate:Plateau"
      | "archimate:Principle"
      | "archimate:Product"
      | "archimate:Representation"
      | "archimate:Requirement"
      | "archimate:Stakeholder"
      | "archimate:SystemSoftware"
      | "archimate:Value"
      | "archimate:WorkPackage" ->
        Element {
          id = fetch "id" attribute_map;
          element_type = fetch_optional "type" attribute_map;
          label = fetch_optional "label" attribute_map;
          documentation = find_all_nodes is_documentation to_documentation childs;
          properties = find_all_nodes is_property to_property childs;
        }
      | _ ->
        ignore(invalid_arg "Unsupported element type " ^ t);
        Data ("Unexpected element type " ^ t)
    )
  | "bendpoint" ->
    Bendpoint {
      start_x = fetch_optional_float "startX" attribute_map;
      start_y = fetch_optional_float "startY" attribute_map;
      end_x = fetch_optional_float "endX" attribute_map;
      end_y = fetch_optional_float "endY" attribute_map;
    }
  | "bounds" ->
    Bounds {
      x = fetch_optional_float "x" attribute_map;
      y = fetch_optional_float "y" attribute_map;
      width = fetch_float "width" attribute_map;
      height = fetch_float "height" attribute_map;
    }
  | "child" ->
    Child {
      id = fetch "id" attribute_map;
      child_type = fetch_ns "http://www.w3.org/2001/XMLSchema-instance" "type" attribute_map;
      model = fetch_optional "model" attribute_map;
      name = fetch_optional "name" attribute_map;
      target_connections = fetch_optional "targetConnections" attribute_map;
      archimate_element = fetch_optional "archimateElement" attribute_map;
      bounds = find_node is_bounds to_bounds childs;
      style = find_optional_node is_style to_style childs;
      children = find_all_nodes is_child to_child childs;
      source_connections = find_all_nodes is_source_connection to_source_connection childs;
      documentation = find_all_nodes is_documentation to_documentation childs;
      properties = find_all_nodes is_property to_property childs;
    }
  | "sourceConnection" ->
    Source_connection {
      id = fetch "id" attribute_map;
      source = fetch "source" attribute_map;
      target = fetch "target" attribute_map;
      relationship = fetch_optional "relationship" attribute_map;
      name = fetch_optional "name" attribute_map;
      source_connection_type = fetch_optional "sourceConnectionType" attribute_map;
      bendpoints = find_all_nodes is_bendpoint to_bendpoint childs;
      documentation = find_all_nodes is_documentation to_documentation childs;
      properties = find_all_nodes is_property to_property childs;
      style = find_optional_node is_style to_style childs;
    }
  | "property" ->
    Property {
      key = fetch "key" attribute_map;
      value = fetch_optional "value" attribute_map;
    }
  | _ -> Format.fprintf Format.std_formatter "Element: %s\n" name; Unknown name

let data s =
  Data s


let in_archimate21_model src =
  let i = Xmlm.make_input ~strip:true src in
  Xmlm.input_doc_tree ~el ~data i

(**************************************************************************************)
(* Testing below here *)
(**************************************************************************************)

(* let file = "test/Archisurance.archimate" *)
let file = "/Users/mmorga/work/team/enterprise-architecture/archimate/Rackspace.archimate"
let () =
  let ic = open_in file in
  let dtd, tree_model = in_archimate21_model (`Channel ic) in
  let model =
    match tree_model with
    | Model m -> m
    | _ -> failwith "Whelp, I didn't expect that"
  in
  (* ignore(in_archimate21_model (`Channel ic)); *)
  Format.fprintf Format.std_formatter "Model loaded\n";
  Format.fprintf Format.std_formatter "Element count: %d\n" (List.length model.elements);
  Format.fprintf Format.std_formatter "Folder count: %d\n" (List.length model.folders);
  Format.fprintf Format.std_formatter "Documentation count: %d\n" (List.length model.documentation);
  Format.fprintf Format.std_formatter "Th th that's all ffolks\n";
