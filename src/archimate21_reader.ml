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
  let xsi_type = fetch_ns "http://www.w3.org/2001/XMLSchema-instance" "type" attribute_map in
  let el_type =
    match xsi_type with
    | "archimate:DiagramModelReference" -> DiagramModelReference
    | "archimate:Group" -> Group
    | "archimate:DiagramObject" -> DiagramObject
    | "archimate:Note" -> Note
    | "archimate:SketchModelSticky" -> SketchModelSticky
    | _ -> invalid_arg ("Unexpected Child xsi:type " ^ xsi_type)
  in
  Child {
    id = fetch "id" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
    node = {
      el_type = el_type;
      model = fetch_optional "model" attribute_map;
      name = fetch_optional "name" attribute_map;
      target_connections = fetch_optional "targetConnections" attribute_map;
      archimate_element = fetch_optional "archimateElement" attribute_map;
      bounds = find_node is_bounds to_bounds childs;
      style = find_optional_node is_style to_style childs;
      children = find_all_nodes is_child to_child childs;
      source_connections = find_all_nodes is_source_connection to_source_connection childs;
      alt_view = (
        match (fetch_optional "type" attribute_map) with
        | Some s -> if s = "1" then true else false
        | None -> false
      );
    };
  }

let make_diagram d_type attribute_map childs =
  Diagram {
    id = fetch "id" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
    node = {
      name = fetch "name" attribute_map;
      viewpoint = fetch_optional "viewpoint" attribute_map;
      children = find_all_nodes is_child to_child childs;
      connection_router_type = fetch_optional_int "connectionRouterType" attribute_map;
      dia_type = d_type
    };
  }

let make_element (el_type : element_type) layer attribute_map childs =
  Element {
    id = fetch "id" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
    node = {
      el_type = el_type;
      layer = layer;
      name = fetch_optional "name" attribute_map;
    };
  }

let make_documentation attribute_map childs =
  Documentation {
    lang = fetch_optional "lang" attribute_map;
    content = data_child_content childs;
  }

let make_folder attribute_map childs =
  Folder ({
      id = fetch "id" attribute_map;
      documentation = find_all_nodes is_documentation to_documentation childs;
      properties = find_all_nodes is_property to_property childs;
      node = {
        name = fetch "name" attribute_map;
        folder_type = fetch_optional "type" attribute_map;
        items = folder_items childs;
        folders = filter_folder_recs childs;
      };
    }, childs)

let make_model attribute_map childs =
  let folders = filter_folders childs in
  Model {
    id = fetch "id" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
    node = {
      version = Datamodel.ArchiMate2_1;
      name = fetch "name" attribute_map;
      folders = List.map to_folder folders;
      elements = find_all_in_folders is_element to_element folders;
      relationships = find_all_in_folders is_relationship to_relationship folders;
      diagrams = find_all_in_folders is_diagram to_diagram folders;
    };
  }

let make_property attribute_map =
  Property {
    key = fetch "key" attribute_map;
    value = fetch_optional "value" attribute_map;
  }

let make_relationship (t : relationship_type) attribute_map childs =
  Relationship {
    id = fetch "id" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
    node = {
      name = fetch_optional "name" attribute_map;
      rel_type = t;
      source = fetch "source" attribute_map;
      target = fetch "target" attribute_map;
    };
  }

let make_source_connection attribute_map childs =
  Source_connection {
    id = fetch "id" attribute_map;
    documentation = find_all_nodes is_documentation to_documentation childs;
    properties = find_all_nodes is_property to_property childs;
    node = {
      source = fetch "source" attribute_map;
      target = fetch "target" attribute_map;
      relationship = fetch_optional "relationship" attribute_map;
      name = fetch_optional "name" attribute_map;
      source_connection_type = fetch_optional "sourceConnectionType" attribute_map;
      bendpoints = find_all_nodes is_bendpoint to_bendpoint childs;
      style = find_optional_node is_style to_style childs;
    };
  }

let make_folder_item attribute_map childs =
  let el_type =
    let strip_archimate s = String.sub s 10 ((String.length s) - 10) in
    fetch_ns "http://www.w3.org/2001/XMLSchema-instance" "type" attribute_map |>
    strip_archimate
  in
  let r (rt : relationship_type) : tree =
    make_relationship rt attribute_map childs
  in
  let e (et : element_type) el : tree =
    make_element et el attribute_map childs
  in
  let d (dt : diagram_type) : tree =
    make_diagram dt attribute_map childs
  in
  match el_type with
  | "AccessRelationship"         -> r Access
  | "AggregationRelationship"    -> r Aggregation
  | "AssignmentRelationship"     -> r Assignment
  | "AssociationRelationship"    -> r Association
  | "CompositionRelationship"    -> r Composition
  | "FlowRelationship"           -> r Flow
  | "InfluenceRelationship"      -> r Influence
  | "RealisationRelationship"    -> r Realization
  | "SpecialisationRelationship" -> r Specialization
  | "TriggeringRelationship"     -> r Triggering
  | "UsedByRelationship"         -> r UsedBy
  | "SketchModel"                -> d Sketch
  | "ArchimateDiagramModel"      -> d Diagram
  | "AndJunction"                -> e AndJunction Junction
  | "Junction"                   -> e Junction Junction
  | "OrJunction"                 -> e OrJunction Junction
  | "BusinessActor"              -> e BusinessActor BusinessLayer
  | "BusinessCollaboration"      -> e BusinessCollaboration BusinessLayer
  | "BusinessEvent"              -> e BusinessEvent BusinessLayer
  | "BusinessFunction"           -> e BusinessFunction BusinessLayer
  | "BusinessInteraction"        -> e BusinessInteraction BusinessLayer
  | "BusinessInterface"          -> e BusinessInterface BusinessLayer
  | "BusinessObject"             -> e BusinessObject BusinessLayer
  | "BusinessProcess"            -> e BusinessProcess BusinessLayer
  | "BusinessRole"               -> e BusinessRole BusinessLayer
  | "BusinessService"            -> e BusinessService BusinessLayer
  | "Contract"                   -> e Contract BusinessLayer
  | "Location"                   -> e Location BusinessLayer
  | "Meaning"                    -> e Meaning BusinessLayer
  | "Product"                    -> e Product BusinessLayer
  | "Representation"             -> e Representation BusinessLayer
  | "Value"                      -> e Value BusinessLayer
  | "ApplicationCollaboration"   -> e ApplicationCollaboration ApplicationLayer
  | "ApplicationComponent"       -> e ApplicationComponent ApplicationLayer
  | "ApplicationFunction"        -> e ApplicationFunction ApplicationLayer
  | "ApplicationInteraction"     -> e ApplicationInteraction ApplicationLayer
  | "ApplicationInterface"       -> e ApplicationInterface ApplicationLayer
  | "ApplicationService"         -> e ApplicationService ApplicationLayer
  | "DataObject"                 -> e DataObject ApplicationLayer
  | "Artifact"                   -> e Artifact TechnologyLayer
  | "CommunicationPath"          -> e CommunicationPath TechnologyLayer
  | "Device"                     -> e Device TechnologyLayer
  | "InfrastructureFunction"     -> e InfrastructureFunction TechnologyLayer
  | "InfrastructureInterface"    -> e InfrastructureInterface TechnologyLayer
  | "InfrastructureService"      -> e InfrastructureService TechnologyLayer
  | "Network"                    -> e Network TechnologyLayer
  | "Node"                       -> e Node TechnologyLayer
  | "SystemSoftware"             -> e SystemSoftware TechnologyLayer
  | "Assessment"                 -> e Assessment MotivationLayer
  | "Constraint"                 -> e Constraint MotivationLayer
  | "Driver"                     -> e Driver MotivationLayer
  | "Goal"                       -> e Goal MotivationLayer
  | "Principle"                  -> e Principle MotivationLayer
  | "Requirement"                -> e Requirement MotivationLayer
  | "Stakeholder"                -> e Stakeholder MotivationLayer
  | "Deliverable"                -> e Deliverable StrategyLayer
  | "Gap"                        -> e Gap StrategyLayer
  | "Plateau"                    -> e Plateau StrategyLayer
  | "WorkPackage"                -> e WorkPackage StrategyLayer
  | _ ->
    invalid_arg ("Unsupported element type " ^ el_type)

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
  | "element" ->
    make_folder_item attribute_map childs
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

let read file : Datamodel.model =
  let ic = open_in file in
  let dtd, tree_model = in_archimate21_model (`Channel ic) in
  let model =
    match tree_model with
    | Model m -> m
    | _ -> failwith "Whelp, I didn't expect that"
  in
  model

