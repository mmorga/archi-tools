open OUnit2
open XmlUtil

let tests =
  "XmlUtil" >:::
  [
    "attrib_val" >::
    (fun test_ctxt ->
      let no_attrib =
        [
          Xml.PCData "Happy Cloud";
          Xml.Element ("bounds", [("xsi:type", "archimate:ArchimateDiagramModel")], []);
          Xml.Element ("element", [("xsi:type", "archimate:BusinessRole")], [])
        ]
       and is_not_attrib test_case =
        assert_equal "" (attrib_val test_case ["id"; "archimateElement"])
       in
         List.iter is_not_attrib no_attrib
    );

(*     "by_id" >::
    (fun test_ctxt ->
      let test_case = Xml.parse_string "<a><b><c id=\"im-item-c\"/></b></a>"
      and test_result = XmlUtil.by_id "im-item-c" text_case in
      assert_equal ("c", _, _) test_result
    )
 *)  ]
