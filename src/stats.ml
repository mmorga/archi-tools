open Archimate21_reader
open Datamodel
open ANSITerminal

let stats archifile =
  let model = Archimate21_reader.read archifile in
  let in_layer l el =
    el.node.layer = l
  in
  printf [Underlined; yellow] "%s ArchiMate Model Statistics\n\n" model.node.name;
  print_string [Reset] "Elements:\n";
  printf [black;on_yellow] "Business        %7d" (List.filter (in_layer BusinessLayer) model.node.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_blue] "Application     %7d" (List.filter (in_layer ApplicationLayer) model.node.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_green] "Technology      %7d" (List.filter (in_layer TechnologyLayer) model.node.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_magenta] "Motivation      %7d" (List.filter (in_layer MotivationLayer) model.node.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_cyan] "Strategy        %7d" (List.filter (in_layer StrategyLayer) model.node.elements |> List.length);
  print_string [Reset] "\n";
  printf [] "Total Elements: %7d\n" (List.length model.node.elements);
  printf [] "Relationships:  %7d\n" (List.length model.node.relationships);
  printf [] "Diagrams:       %7d\n\n" (List.length model.node.diagrams);
