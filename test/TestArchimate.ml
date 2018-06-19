open OUnit2
open Datamodel

let tests =
  "Datamodel" >:::
  [
    "is_diagram-not" >::
    (fun test_ctxt ->
      let not_diagrams =
        [
          Xml.PCData "Happy Cloud";
          Xml.Element ("bounds", [("xsi:type", "archimate:ArchimateDiagramModel")], []);
          Xml.Element ("element", [("xsi:type", "archimate:BusinessRole")], [])
        ]
       and is_not_diagram test_case =
        assert_equal false (is_diagram test_case)
       in
         List.iter is_not_diagram not_diagrams
    );
    "is_diagram" >::
    (fun test_ctxt ->
      let not_diagrams =
        [
          Xml.Element ("element", [("xsi:type", "archimate:ArchimateDiagramModel")], []);
          Xml.Element ("element", [("xsi:type", "archimate:ArchimateDiagramModel")], [])
        ]
       and is_diagram test_case =
        assert_equal true (is_diagram test_case)
       in
         List.iter is_diagram not_diagrams
    ) (* ); *)
(*     "find_diagrams" >::
    (fun test_ctxt ->
      let archi_doc = Xml.parse_file "Archisurance.archimate" in
      assert_equal 17 (List.length (find_diagrams [] archi_doc))
    )
 *)  ]
