open Archimate21_reader
open Datamodel
open ANSITerminal

let stats archifile =
  let model = Archimate21_reader.read archifile in
  let in_layer l el =
    el.layer = l
  in
  printf [Underlined; yellow] "%s ArchiMate Model Statistics\n\n" model.name;
  print_string [Reset] "Elements:\n";
  printf [black;on_yellow] "Business        %7d" (List.filter (in_layer BusinessLayer) model.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_blue] "Application     %7d" (List.filter (in_layer ApplicationLayer) model.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_green] "Technology      %7d" (List.filter (in_layer TechnologyLayer) model.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_magenta] "Motivation      %7d" (List.filter (in_layer MotivationLayer) model.elements |> List.length);
  print_string [Reset] "\n";
  printf [Reset;black;on_cyan] "Strategy        %7d" (List.filter (in_layer StrategyLayer) model.elements |> List.length);
  print_string [Reset] "\n";
  printf [] "Total Elements: %7d\n" (List.length model.elements);
  printf [] "Relationships:  %7d\n" (List.length model.relationships);
  printf [] "Diagrams:       %7d\n\n" (List.length model.diagrams);
