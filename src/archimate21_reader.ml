open Datamodel
open AttributeMap

(* debug helpers *)

let dump_attribute attr =
  let (ns, name), aval = attr in
  Format.fprintf Format.std_formatter "%s:%s = '%s'\n" ns name aval

let dump_attrs attrs =
  List.iter dump_attribute attrs


(* Real code starts here *)
let make_bendpoint attribute_map =
  Bendpoint {
    start_x = fetch_optional_float "startX" attribute_map;
    start_y = fetch_optional_float "startY" attribute_map;
    end_x = fetch_optional_float "endX" attribute_map;
    end_y = fetch_optional_float "endY" attribute_map;
  }

let make_bounds attribute_map =
  Bounds {
    x = fetch_optional_float "x" attribute_map;
    y = fetch_optional_float "y" attribute_map;
    width = fetch_float "width" attribute_map;
    height = fetch_float "height" attribute_map;
  }

let make_child attribute_map childs =
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

let make_diagram attribute_map childs =
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

let make_element attribute_map layer childs =
  Element {
    id = fetch "id" attribute_map;
    element_type = fetch_optional "type" attribute_map;
    layer = layer;
    label = fetch_optional "label" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
  }

let make_documentation attribute_map childs =
  Documentation {
    lang = fetch_optional "lang" attribute_map;
    content = data_child_content childs;
  }

let make_folder attribute_map childs =
  Folder ({
      id = fetch "id" attribute_map;
      name = fetch "name" attribute_map;
      folder_type = fetch_optional "type" attribute_map;
      items = folder_items childs;
      documentation = find_all_nodes is_documentation to_documentation childs;
      properties = find_all_nodes is_property to_property childs;
      folders = filter_folder_recs childs;
    }, childs)

let make_model attribute_map childs =
  let folders = filter_folders childs in
  Model {
    id = fetch "id" attribute_map;
    version = Datamodel.ArchiMate2_1;
    name = fetch "name" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
    folders = List.map to_folder folders;
    elements = find_all_in_folders is_element to_element folders;
    relationships = find_all_in_folders is_relationship to_relationship folders;
    diagrams = find_all_in_folders is_diagram to_diagram folders;
  }

let make_property attribute_map =
  Property {
    key = fetch "key" attribute_map;
    value = fetch_optional "value" attribute_map;
  }

let make_relationship attribute_map childs =
  Relationship {
    id = fetch "id" attribute_map;
    name = fetch_optional "name" attribute_map;
    (* TODO: strip off the "" prefix from type *)
    relationship_type = fetch_ns "http://www.w3.org/2001/XMLSchema-instance" "type" attribute_map;
    source = fetch "source" attribute_map;
    target = fetch "target" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
  }

let make_source_connection attribute_map childs =
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

(* called by Xmlm.input_doc_tree for each XML element in the file *)
let el tag childs =
  let (ns, name), attrs = tag in
  let attribute_map = map_attributes attrs in
  match name with
  | "model" ->
    make_model attribute_map childs
  | "documentation"
  | "purpose" ->
    make_documentation attribute_map childs
  | "content" ->
    Data (data_child_content childs)
  | "folder" ->
    make_folder attribute_map childs
  | "element" -> (
      let el_type =
        let strip_archimate s = String.sub s 10 ((String.length s) - 10) in
        fetch_ns "http://www.w3.org/2001/XMLSchema-instance" "type" attribute_map |>
        strip_archimate
      in
      match el_type with
      | "AccessRelationship"
      | "AggregationRelationship"
      | "AssignmentRelationship"
      | "AssociationRelationship"
      | "CompositionRelationship"
      | "FlowRelationship"
      | "InfluenceRelationship"
      | "RealisationRelationship"
      | "SpecialisationRelationship"
      | "TriggeringRelationship"
      | "UsedByRelationship" ->
        make_relationship attribute_map childs
      | "SketchModel"
      | "ArchimateDiagramModel" ->
        make_diagram attribute_map childs
      | "AndJunction"
      | "Junction"
      | "OrJunction" ->
        make_element attribute_map Junction childs
      | "BusinessActor"
      | "BusinessCollaboration"
      | "BusinessEvent"
      | "BusinessFunction"
      | "BusinessInteraction"
      | "BusinessInterface"
      | "BusinessObject"
      | "BusinessProcess"
      | "BusinessRole"
      | "BusinessService"
      | "Contract"
      | "Meaning"
      | "Product"
      | "Representation"
      | "Value" ->
        make_element attribute_map BusinessLayer childs
      | "ApplicationCollaboration"
      | "ApplicationComponent"
      | "ApplicationFunction"
      | "ApplicationInteraction"
      | "ApplicationInterface"
      | "ApplicationService"
      | "DataObject" ->
        make_element attribute_map ApplicationLayer childs
      | "Artifact"
      | "CommunicationPath"
      | "Device"
      | "InfrastructureFunction"
      | "InfrastructureInterface"
      | "InfrastructureService"
      | "Network"
      | "Node"
      | "SystemSoftware" ->
        make_element attribute_map TechnologyLayer childs
      | "Assessment"
      | "Constraint"
      | "Driver"
      | "Goal"
      | "Principle"
      | "Requirement"
      | "Stakeholder" ->
        make_element attribute_map MotivationLayer childs
      | "Deliverable"
      | "Gap"
      | "Location"
      | "Plateau"
      | "WorkPackage" ->
        make_element attribute_map StrategyLayer childs
      | _ ->
        invalid_arg ("Unsupported element type " ^ el_type)
    )
  | "bendpoint" ->
    make_bendpoint attribute_map
  | "bounds" ->
    make_bounds attribute_map
  | "child" ->
    make_child attribute_map childs
  | "sourceConnection" ->
    make_source_connection attribute_map childs
  | "property" ->
    make_property attribute_map
  | _ -> invalid_arg ("Unsupported Element: " ^ name)

(* Called by XMLM.input_doc_tree for each data (string) node in the XML document *)
let data s =
  Data s


let in_archimate21_model src =
  let i = Xmlm.make_input ~strip:true src in
  Xmlm.input_doc_tree ~el ~data i

(**************************************************************************************)
(* Testing below here *)
(**************************************************************************************)

let () =
  let file = match Array.length Sys.argv with
    | 2 -> Sys.argv.(1)
    | 1 -> "test/Archisurance.archimate"
    | _ -> invalid_arg "Expected one Archi file argument"
  in
  let ic = open_in file in
  let dtd, tree_model = in_archimate21_model (`Channel ic) in
  let model =
    match tree_model with
    | Model m -> m
    | _ -> failwith "Whelp, I didn't expect that"
  in
  Format.fprintf Format.std_formatter "Model loaded\n";
  Format.fprintf Format.std_formatter "Element count: %d\n" (List.length model.elements);
  Format.fprintf Format.std_formatter "Relationship count: %d\n" (List.length model.relationships);
  Format.fprintf Format.std_formatter "Diagram count: %d\n" (List.length model.diagrams);
  Format.fprintf Format.std_formatter "Folder count: %d\n" (List.length model.folders);
  Format.fprintf Format.std_formatter "Documentation count: %d\n" (List.length model.documentation);
  Format.fprintf Format.std_formatter "Th th that's all ffolks\n";
