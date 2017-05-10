open Cmdliner

type verb = Normal | Quiet | Verbose
type copts = { debug : bool; verb : verb }

let str = Printf.sprintf
let opt_str sv = function None -> "None" | Some v -> str "Some(%s)" (sv v)
let opt_str_str = opt_str (fun s -> s)
let verb_str = function
  | Normal -> "normal" | Quiet -> "quiet" | Verbose -> "verbose"

let pr_copts oc copts = Printf.fprintf oc
    "debug = %b\nverbosity = %s\n"
    copts.debug (verb_str copts.verb)

let to_model archifile =
  Archimate21_reader.read archifile

let stats copts archifiles =
  let pr_stats archifile =
    Stats.stats archifile
  in
  List.iter pr_stats archifiles

let svgs copts outdir archifiles =
  let save_svgs outdir archifile =
    Svgs.svgs outdir (to_model archifile)
  in
  List.iter (save_svgs outdir) archifiles

let help copts man_format cmds = function
| None -> `Help (`Pager, None) (* help about the program. *)
| Some topic ->
    let topics = "topics" :: "patterns" :: "environment" :: cmds in
    let conv, _ = Cmdliner.Arg.enum (List.rev_map (fun s -> (s, s)) topics) in
    match conv topic with
    | `Error e -> `Error (false, e)
    | `Ok t when t = "topics" -> List.iter print_endline topics; `Ok ()
    | `Ok t when List.mem t cmds -> `Help (man_format, Some t)
    | `Ok t ->
        let page = (topic, 7, "", "", ""), [`S topic; `P "Say something";] in
        `Ok (Cmdliner.Manpage.print man_format Format.std_formatter page)

(* Help sections common to all commands *)

let help_secs = [
 `S Manpage.s_common_options;
 `P "These options are common to all commands.";
 `S "MORE HELP";
 `P "Use `$(mname) $(i,COMMAND) --help' for help on a single command.";`Noblank;
 `S Manpage.s_bugs; `P "Check bug reports at https://github.com/mmorga/archi-tools/issues.";]

(* Options common to all commands *)

let copts debug verb = { debug; verb }
let copts_t =
  let docs = Manpage.s_common_options in
  let debug =
    let doc = "Give only debug output." in
    Arg.(value & flag & info ["debug"] ~docs ~doc)
  in
  let verb =
    let doc = "Suppress informational output." in
    let quiet = Quiet, Arg.info ["q"; "quiet"] ~docs ~doc in
    let doc = "Give verbose output." in
    let verbose = Verbose, Arg.info ["v"; "verbose"] ~docs ~doc in
    Arg.(last & vflag_all [Normal] [quiet; verbose])
  in
  Term.(const copts $ debug $ verb)

(* Commands *)

let stats_cmd =
  let files = Arg.(value & (pos_all non_dir_file []) & info [] ~docv:"FILE") in
  let doc = "Show model statistics on an ArchiMate file." in
  let exits = Term.default_exits in
  let man = [
    `S Manpage.s_description;
    `P "Show model statistics on an ArchiMate model.";
    `Blocks help_secs; ]
  in
  Term.(const stats $ copts_t $ files),
  Term.info "stats" ~doc ~sdocs:Manpage.s_common_options ~exits ~man

let svgs_cmd =
  let files = Arg.(value & (pos_all non_dir_file []) & info [] ~docv:"FILE") in
  let outdir =
    let doc = "Output SVGs into $(docv)." in
    Arg.(value & opt file Filename.current_dir_name & info ["o"; "outdir"]
           ~docv:"DIR" ~doc)
  in
  let doc = "Generate SVG diagrams for an ArchiMate file." in
  let exits = Term.default_exits in
  let man = [
    `S Manpage.s_description;
    `P "Generate SVG diagrams for an ArchiMate file.";
    `Blocks help_secs; ]
  in
  Term.(const svgs $ copts_t $ outdir $ files),
  Term.info "svgs" ~doc ~sdocs:Manpage.s_common_options ~exits ~man

let help_cmd =
  let topic =
    let doc = "The topic to get help on. `topics' lists the topics." in
    Arg.(value & pos 0 (some string) None & info [] ~docv:"TOPIC" ~doc)
  in
  let doc = "display help about archi and archi commands" in
  let man =
    [`S Manpage.s_description;
     `P "Prints help about archi commands and other subjects...";
     `Blocks help_secs; ]
  in
  Term.(ret
          (const help $ copts_t $ Arg.man_format $ Term.choice_names $topic)),
  Term.info "help" ~doc ~exits:Term.default_exits ~man

let default_cmd =
  let doc = "ArchiMate model toolkit" in
  let sdocs = Manpage.s_common_options in
  let exits = Term.default_exits in
  let man = help_secs in
  Term.(ret (const (fun _ -> `Help (`Pager, None)) $ copts_t)),
  Term.info "archi" ~version:"v1.0.0" ~doc ~sdocs ~exits ~man

let cmds = [stats_cmd; svgs_cmd; help_cmd]

let () = Term.(exit @@ eval_choice default_cmd cmds)

