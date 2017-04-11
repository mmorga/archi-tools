(* Include resources/svg_template.svg.mustache *)
let svg = 
  "\
  <?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n\
  <!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n\
  <svg xmlns=\"http://www.w3.org/2000/svg\"\n\
  \     xmlns:xlink=\"http://www.w3.org/1999/xlink\"\n\
  \     version=\"1.1\"\n\
  \     width=\"{{ width }}\"\n\
  \     height=\"{{ height }}\"\n\
  \     viewBox=\"{{ min_x }} {{ min_y }} {{ width }} {{ height }}\">\n\
  \    <style type=\"text/css\" >\n\
  \      <![CDATA[\n\
  \       {{{ stylesheet }}}\n\
  \     ]]>\n\
  \    </style>\n\
  \    <defs>\n\
  \      <!-- Badges -->\n\
  \      <symbol id=\"archimate-material-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1;stroke-linejoin:miter\" d=\"M 15.443383,8.5890552 5.0182941,17.265414 -7.7081977,12.575201 -10.0096,-0.7913701 0.41548896,-9.4677289 13.141981,-4.7775163 Z\" transform=\"matrix(0.59818877,-0.22354387,0.22387513,0.59808805,7.5647066,7.7263348)\" />\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter\" d=\"M 4.5472185,10.333586 8.1220759,4.0990346\"/>\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter\" d=\"m 12.154515,4.0418369 3.51766,6.2917491\"/>\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter\" d=\"m 6.5491386,14.223031 7.0925174,-0.0572\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-distribution-network-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round\" d=\"M 5.8847321,2.5480283 1.4964611,6.7745197 5.7431749,10.596562\"/>\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter\" d=\"m 3.5995956,4.8129424 12.6592514,0\"/>\n\
  \        <path d=\"m 3.5995956,8.6754298 13.2861464,0\" style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter\"/>\n\
  \        <path d=\"m 14.314928,2.7502528 4.388271,4.2264914 -4.246714,3.8220418\" style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linecap:round;stroke-linejoin:round\" />\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-facility-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1px;stroke-linejoin:miter\" d=\"m 2.1449144,17.940882 0,-15.7007732 2.1735133,0 0,10.2383912 4.5472185,-2.7740891 0,2.8598861 4.4900208,-2.888485 0,2.74549 4.51862,-2.6882923 0,8.2078723 z\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-equipment-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <g transform=\"translate(0,-7)\">\n\
  \          <circle cx=\"8\" cy=\"18.7\" r=\"2.432014\" style=\"fill:none;stroke:inherent;stroke-width:0.7\"/>\n\
  \          <circle cx=\"13.7\" cy=\"12.6\" r=\"2.0318091\" style=\"fill:none;stroke:inherent;stroke-width:0.7\"/>\n\
  \          <path d=\"m 10.419829,13.456928 -1.089422,-0.143227 0.049633,-1.333107 1.038029,-0.147302 0.341694,-0.73592 -0.57155,-0.843058 0.841528,-0.8648267 0.957991,0.4937924 0.912018,-0.3836763 0.17842,-0.962147 1.316037,-0.019985 0.101237,0.9711183 0.869824,0.3547524 0.771707,-0.6499933 0.91403,0.8676982 -0.566748,0.882319 0.356276,0.832942 0.930473,0.02346 0.06356,1.262322 -1.035165,0.180358 -0.419167,0.824685 0.690443,0.793236 -0.972585,0.907704 -0.733596,-0.578471 -0.952142,0.360765 -0.169839,0.993647 -1.356163,-0.0029 -0.122641,-0.947842 -0.848419,-0.378029 -0.857761,0.70726 -0.979897,-0.985107 0.737388,-0.77599 z\" style=\"fill:none;stroke:inherit;stroke-width:0.8;stroke-linejoin:bevel\"/>\n\
  \          <path style=\"fill:none;stroke:inherit;stroke-width:0.8;stroke-linejoin:bevel\" d=\"m 3.5980557,18.939362 -1.3122324,-0.550291 0.5156318,-1.650873 1.3468917,0.16932 0.6772813,-0.804271 -0.4271363,-1.249401 1.3455665,-0.795275 1.0287534,0.944094 1.2699024,-0.169321 0.550291,-1.142912 1.6508729,0.423301 -0.203979,1.2494 0.965921,0.740114 1.185242,-0.550291 0.846601,1.396892 -1.00825,0.91076 0.161649,1.163414 1.154418,0.346312 -0.350147,1.600872 -1.354562,-0.12699 -0.804272,0.888931 0.592621,1.227572 L 9.9052376,23.764991 9.1856262,22.791399 7.8733938,22.918389 7.3231027,24.103632 5.6298996,23.638001 5.7992199,22.410428 4.8679581,21.648487 3.5557257,22.241108 2.666794,20.674895 3.8520362,19.955284 Z\"/>\n\
  \        </g>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-resource-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 20\">\n\
  \        <rect style=\"fill:none;stroke:inherit;stroke-width:0.7\" width=\"1.6\" height=\"3.3\" x=\"17\" y=\"5\" ry=\"0.8\" rx=\"0.8\"/>\n\
  \        <rect style=\"fill:none;stroke:inherit;stroke-width:0.7\" width=\"14\" height=\"9\" x=\"3\" y=\"2\" ry=\"1.2\" />\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1\" d=\"m 6,4 v 4.4 m 3 -4.4 v 4.4 m 3 -4.4 v 4.4\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-outcome-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <circle style=\"fill:none;stroke:inherit;stroke-width:0.9;stroke-linecap:round;stroke-linejoin:round\" cx=\"9.0192108\" cy=\"11.324571\" r=\"1.718908\" />\n\
  \        <circle style=\"fill:none;stroke:inherit;stroke-width:0.9;stroke-linecap:round;stroke-linejoin:round\" cx=\"9.1405458\" cy=\"11.304347\" r=\"3.5591507\" />\n\
  \        <circle style=\"fill:none;stroke:inherit;stroke-width:0.9;stroke-linecap:round;stroke-linejoin:round\" cx=\"9.0798788\" cy=\"11.324571\" r=\"5.2982812\" />\n\
  \        <path style=\"fill:inherit;stroke:inherit;stroke-width:0.6;stroke-linecap:butt;stroke-linejoin:round\" d=\"M 8.7563195,11.547017 9.4236603,8.0485339 12.598584,10.940344 Z\"/>\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:1.4;stroke-linecap:round;stroke-linejoin:miter\" d=\"M 16.097068,4.2264914 10.920121,9.6258847\"/>\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:0.9;stroke-linecap:round;stroke-linejoin:miter\" d=\"M 14.742164,2.2244692 13.811931,6.3296259\"/>\n\
  \        <path style=\"fill:none;stroke:inherit;stroke-width:0.9;stroke-linecap:round;stroke-linejoin:miter\" d=\"M 18.200202,5.0151668 13.953489,6.5318504\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-course-of-action-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <circle style=\"fill:inherit;stroke:inherit;stroke-width:1\" cx=\"14.5\" cy=\"6\" r=\"1\" />\n\
  \        <circle style=\"fill:none;stroke:inherit;stroke-width:1\" cx=\"14.5\" cy=\"6\" r=\"2.8\" />\n\
  \        <circle style=\"fill:none;stroke:inherit;stroke-width:1\" cx=\"14.5\" cy=\"6\" r=\"4.6\" />\n\
  \        <path style=\"fill:inherit;stroke:inherit;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter\" d=\"M 1.1664063,14.167969 C 2.5664063,12.167969 4.1,10.95 5.6,9.85 L 4.5,9 C 4.3,8.25 4.54,7.9 5.25,7.9 l 4.5,0.6 c -0.5108623,0.013713 1.081001,-0.037861 0.5,1.1 l -3,3.7 c -0.6,0.4 -1,0.25 -1.2,-0.15 L 6.01,11.75 C 4.5,12.5 3.5,14 2.5,15 1.83125,15.09375 1.1875,14.617188 1.1703125,14.171875 Z\"/>\n\
  \      </symbol>\n\
  \       <symbol id=\"archimate-capability-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <rect x=\"4\" y=\"11.5\" width=\"5\" height=\"5\" style=\"fill:none;stroke:#423f30\"/>\n\
  \        <rect x=\"9\" y=\"11.5\" width=\"5\" height=\"5\" style=\"fill:none;stroke:#423f30\"/>\n\
  \        <rect x=\"14\" y=\"11.5\" width=\"5\" height=\"5\" style=\"fill:none;stroke:#423f30\"/>\n\
  \        <rect x=\"9\" y=\"6.5\" width=\"5\" height=\"5\" style=\"fill:none;stroke:#423f30\"/>\n\
  \        <rect x=\"14\" y=\"6.5\" width=\"5\" height=\"5\" style=\"fill:none;stroke:#423f30\"/>\n\
  \        <rect x=\"14\" y=\"1.5\" width=\"5\" height=\"5\" style=\"fill:none;stroke:#423f30\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-diagram-model-reference-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <rect x=\"1\" y=\"0.5\" width=\"7\" height=\"7\" style=\"fill:none;stroke:#1c6aa9\"/>\n\
  \        <rect x=\"2\" y=\"1.5\" width=\"4.5\" height=\"4.5\" style=\"fill:#c2e8fe;stroke:#c2e8fe\"/>\n\
  \        <path d=\"M11 4 h7\" style=\"fill:none;stroke:#c2e8fe\"/>\n\
  \        <path d=\"M11 5 h7\" style=\"fill:none;stroke:#1c6aa9\"/>\n\
  \n\
  \        <rect x=\"12\" y=\"8.5\" width=\"2\" height=\"2\" style=\"fill:none;stroke:#1c6aa9\"/>\n\
  \        <path d=\"M15 9.5 h3\" style=\"fill:none;stroke:#1c6aa9\"/>\n\
  \n\
  \        <rect x=\"1\" y=\"11.7\" width=\"7\" height=\"7\" style=\"fill:none;stroke:#1c6aa9\"/>\n\
  \        <rect x=\"2\" y=\"12.7\" width=\"4.5\" height=\"4.5\" style=\"fill:#c2e8fe;stroke:#c2e8fe\"/>\n\
  \        <path d=\"M11 14.7 h7\" style=\"fill:none;stroke:#c2e8fe\"/>\n\
  \        <path d=\"M11 15.7 h7\" style=\"fill:none;stroke:#1c6aa9\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-actor-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <path d=\"M 11 18 l 4 -5 l 4 5 m -4 -5 v -3 h -4 h 8 h -4 v -3 a 3 3 0 1 0 0 -6 a 3 3 0 1 0 0 6\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-assessment-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m4.5 13 l 5 -5 a 4 4 0 1 0 8 -8 a 4 4 0 1 0 -8 8\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-collaboration-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\" preserveAspectRatio=\"xMaxYMin meet\">\n\
  \        <path d=\"m7.5 14 a 6.5 6.5 0 0 1 0 -13 a 6.5 6.5 0 0 1 0 13 m 5 0 a 6.5 6.5 0 0 1 0 -13 a 6.5 6.5 0 0 1 0 13\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-communication-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m7.5 -1 l -6.5 6.5 l 6.5 6.5 m 5 -13 l 6.5 6.5 l -6.5 6.5 m -7 -6.5 h 3 m 3 0 h 3\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-constraint-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m6 -1 h 13 l -5 10 h -13 z m 4 0 l -5 10\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-device-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <rect x=\"2\" y=\"1\" width=\"16\" height=\"10\" rx=\"3\" ry=\"3\" style=\"fill:inherit;stroke:inherit;\"/>\n\
  \        <path d=\"M6 11 l -4.5 4 h 17 l -4.5 -4\" stroke=\"black\" style=\"fill:inherit;stroke:inherit;\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-driver-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m17.5 6.5 a 6.5 6.5 0 0 0 -13 0 a 6.5 6.5 0 0 0 13 0 m 2 0 h -17 m 8.5 -8.5 v 17 m -6.01 -2.49 l 12.02 -12.02 m 0 12.02 l -12.02 -12.02\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-function-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 20\" preserveAspectRatio=\"xMaxYMin meet\">\n\
  \        <path d=\"m7 15 l 0 -9 l 6 -5 l 6 5 l 0 9 l -6 -6 z\" style=\"fill:none;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-gap-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m4.5 5 a 6.5 6.5 0 0 0 13 0 a 6.5 6.5 0 0 0 -13 0 m -2 -1.5 h 17 m -17 3 h 17\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-goal-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <circle cx=\"12\" cy=\"6\" r=\"7\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \        <circle cx=\"12\" cy=\"6\" r=\"4.7\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \        <circle cx=\"12\" cy=\"6\" r=\"2\" style=\"fill:black;stroke:inherit;\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-interaction-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\" preserveAspectRatio=\"xMaxYMin meet\">\n\
  \        <path d=\"M11 14 a 5 6 0 0 1 0 -13 z\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \        <path d=\"M14 14 a 5 6 0 0 0 0 -13 z\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-interface-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\" preserveAspectRatio=\"xMaxYMin meet\">\n\
  \        <path d=\"m0.5 6 h 8.5 a 5 5 0 0 1 10 0 a 5 5 0 0 1 -10 0\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-location-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m10 6.5 a 5 5, 0, 1, 1, 8 0 l -4 7 z\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-network-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m9 9.5 a 2.5 2.5 0 0 0 -5 0 a 2.5 2.5 0 0 0 5 0 m -2 -2.5 l 1 -3 m 0.5 0 a 2.5 2.5 0 0 0 0 -5 a 2.5 2.5 0 0 0 0 5 m 2 -2.5 h 3.5 a 2.5 2.5 0 0 0 5 0 a 2.5 2.5 0 0 0 -5 0 m 2 2.5 l -1 3 m -0.5 0 a 2.5 2.5 0 0 0 0 5 a 2.5 2.5 0 0 0 0 -5 m -2 2.5 h -3.5\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-node-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <path d=\"M1 19 v -15 l 3 -3 h 15 v 15 l -3 3 z M 16 19 v -15 l 3 -3 m -3 3 h -15\" style=\"fill:none;stroke:inherit;stroke-linejoin:miter;\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-plateau-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m7 0 h 12 m -12 1 h 12 m -14 3 h 12 m -12 1 h 12 m -14 3 h 12 m -12 1 h 12\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-principle-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m8.5 -1 h 8 a 2 2 0 0 0 2 2 v 9 a 2 2 0 0 0 -2 2 h -8 a 2 2 0 0 0 -2 -2 v -9 a 2 2 0 0 0 2 -2 m 4 1 v7 m 1 -7 v7 m -1 1.5 v2 m 1 -2 v2\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-process-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m1 3 h 11 v -4 l 7 6 l -7 6 v -4 h -11 z\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-requirement-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m6 -1 h 13 l -5 10 h -13 z\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-role-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 20\">\n\
  \        <path d=\"m15 10.5 h -10 a 4.5 4.5 0 0 1 0 -9 h 10 a 4.5 4.5 0 0 1 0 9 a 4.5 4.5 0 0 1 0 -9\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-service-badge\" class=\"archimate-badge\" viewBox=\"0 0 20 20\">\n\
  \        <rect x=\"1\" y=\"1\" width=\"17\" height=\"10\" rx=\"5\" ry=\"5\" style=\"fill:inherit;stroke:inherit;\"/>\n\
  \      </symbol>\n\
  \      <symbol id=\"archimate-system-software-badge\" class=\"archimate-badge\"  viewBox=\"0 0 20 15\">\n\
  \        <path d=\"m9.5 1 a 5.5 5.5 0 0 1 0 11 a 5.5 5.5 0 0 1 0 -11    m -2.8 0.7    a 5.5 5.5 0 1 1 7.6 7.6\" style=\"fill:inherit;stroke:inherit\"/>\n\
  \      </symbol>\n\
  \n\
  \     <!-- Line Markers -->\n\
  \      <marker id=\"archimate-dot-marker\"\n\
  \        viewBox=\"0 0 10 10\" refX=\"4\" refY=\"4\"\n\
  \        markerUnits=\"strokeWidth\"\n\
  \        markerWidth=\"8\" markerHeight=\"8\">\n\
  \        <circle cx=\"4\" cy=\"4\" r=\"3\" fill=\"black\" stroke=\"black\" />\n\
  \      </marker>\n\
  \      <marker id=\"archimate-used-by-arrow\"\n\
  \        viewBox=\"0 0 10 10\"\n\
  \        refX=\"9\"\n\
  \        refY=\"5\"\n\
  \        markerUnits=\"strokeWidth\"\n\
  \        markerWidth=\"8\"\n\
  \        markerHeight=\"8\"\n\
  \        orient=\"auto\">\n\
  \        <path d=\"M 1 1 L 9 5 L 1 9\" fill=\"none\" stroke=\"black\" style=\"fill:none;stroke:black;\"/>\n\
  \      </marker>\n\
  \      <marker id=\"archimate-open-arrow\"\n\
  \        viewBox=\"0 0 10 10\" refX=\"9\" refY=\"5\"\n\
  \        markerUnits=\"strokeWidth\"\n\
  \        markerWidth=\"8\" markerHeight=\"8\"\n\
  \        orient=\"auto\">\n\
  \        <path d=\"M 1 1 L 9 5 L 1 9\" fill=\"none\" stroke=\"black\"/>\n\
  \      </marker>\n\
  \      <marker id=\"archimate-filled-arrow\"\n\
  \        viewBox=\"0 0 10 10\" refX=\"9\" refY=\"5\"\n\
  \        markerUnits=\"strokeWidth\"\n\
  \        markerWidth=\"12\" markerHeight=\"12\"\n\
  \        orient=\"auto\">\n\
  \        <polygon points=\"1,1 9,5 1,9\" fill=\"black\" stroke=\"black\"/>\n\
  \      </marker>\n\
  \      <marker id=\"archimate-hollow-arrow\"\n\
  \        viewBox=\"0 0 10 10\" refX=\"9\" refY=\"5\"\n\
  \        markerUnits=\"strokeWidth\"\n\
  \        markerWidth=\"12\" markerHeight=\"12\"\n\
  \        orient=\"auto\">\n\
  \        <polygon points=\"1,1 9,5 1,9\" fill=\"white\" stroke=\"black\"/>\n\
  \      </marker>\n\
  \      <marker id=\"archimate-filled-diamond\"\n\
  \        viewBox=\"0 0 10 10\" refX=\"1\" refY=\"5\"\n\
  \        markerUnits=\"strokeWidth\"\n\
  \        markerWidth=\"12\" markerHeight=\"12\"\n\
  \        orient=\"auto\">\n\
  \        <polygon points=\"5,2.5 9,5 5,7.5 1,5\" fill=\"black\" stroke=\"black\"/>\n\
  \      </marker>\n\
  \      <marker id=\"archimate-hollow-diamond\"\n\
  \        viewBox=\"0 0 10 10\" refX=\"1\" refY=\"5\"\n\
  \        markerUnits=\"strokeWidth\"\n\
  \        markerWidth=\"13\" markerHeight=\"13\"\n\
  \        orient=\"auto\">\n\
  \        <polygon points=\"5,2.5 9,5 5,7.5 1,5\" fill=\"white\" stroke=\"black\"/>\n\
  \      </marker>\n\
  \    </defs>\n\
  \    {{{ content }}}\n\
  </svg>\n\
  "
;;
(* Include resources/archimate.css *)
let css = 
  "\
  svg {\n\
  \    font-family: \"Lucida Grande\";\n\
  \    font-size: 11px;\n\
  }\n\
  \n\
  p {\n\
  \    fill: black;\n\
  \    margin: 0;\n\
  \    stroke: none;\n\
  }\n\
  \n\
  path {\n\
  \    fill: inherit;\n\
  \    stroke: inherit;\n\
  \    stroke-width: 1px;\n\
  }\n\
  \n\
  .entity-name {\n\
  \    text-align: center;\n\
  \    vertical-align: top;\n\
  }\n\
  \n\
  .entity>.properties {\n\
  \    visibility: hidden;\n\
  }\n\
  \n\
  .entity:hover>.properties {\n\
  \    visibility: visible;\n\
  \    z-index: 1000;\n\
  }\n\
  \n\
  table.properties {\n\
  \    background-color: whitesmoke;\n\
  \    border: 2px solid gray;\n\
  }\n\
  \n\
  table.properties>caption {\n\
  \    background-color: gray;\n\
  \    border: 2px solid gray;\n\
  \    border-top-left-radius: 8px;\n\
  \    border-top-right-radius: 8px;\n\
  }\n\
  \n\
  .archimate-decoration {\n\
  \    fill:rgba(0,0,0,0.1);\n\
  \    stroke: inherit;\n\
  }\n\
  \n\
  .archimate-badge {\n\
  \    fill: none;\n\
  \    stroke: black;\n\
  \    stroke-width: 1px;\n\
  }\n\
  \n\
  .archimate-badge-spacer {\n\
  \    float: right;\n\
  \    height: 20px;\n\
  \    width: 20px;\n\
  \    /*border: 1px solid red;*/\n\
  }\n\
  \n\
  .archimate-icon {\n\
  \    fill: none;\n\
  \    stroke: black;\n\
  }\n\
  \n\
  .archimate-default-element {\n\
  \    fill: #ddd;\n\
  \    stroke: #999;\n\
  }\n\
  \n\
  .archimate-strategy-background {\n\
  \    fill: #eddfac;\n\
  \    stroke: #44423b;\n\
  }\n\
  \n\
  .archimate-business-background {\n\
  \    fill: #fffeb9;\n\
  \    stroke: #b2b181;\n\
  }\n\
  \n\
  .archimate-business-decoration {\n\
  \    fill: rgb(229, 229, 162);\n\
  \    stroke: rgb(178, 178, 126);\n\
  }\n\
  \n\
  .archimate-application-background {\n\
  \    fill: #ccfdfe;\n\
  \    stroke: #80b2b2;\n\
  }\n\
  \n\
  .archimate-application-decoration {\n\
  \    fill: rgb(162, 229, 229);\n\
  \    stroke: rgb(126, 178, 178);\n\
  }\n\
  \n\
  .archimate-infrastructure-background {\n\
  \    fill: #cae6b9;\n\
  \    stroke: #8ca081;\n\
  }\n\
  \n\
  .archimate-infrastructure-decoration {\n\
  \    fill: #b4cfa4;\n\
  \    stroke: #9bb28d;\n\
  }\n\
  \n\
  .archimate-physical-background {\n\
  \    fill: #cdfeb2;\n\
  \    stoke: #313331;\n\
  }\n\
  \n\
  .archimate-motivation-background {\n\
  \    fill: #fecdfe;\n\
  \    stroke: #b18fb1;\n\
  }\n\
  \n\
  .archimate-motivation2-background {\n\
  \    fill: #cccdfd;\n\
  \    stroke: #8e8fb1;\n\
  }\n\
  \n\
  .archimate-implementation-background {\n\
  \    fill: #fee0e0;\n\
  \    stroke: #b19c9c;\n\
  }\n\
  \n\
  .archimate-implementation2-background {\n\
  \    fill: #e0ffe0;\n\
  \    stroke: #9cb29c;\n\
  }\n\
  \n\
  .archimate-implementation2-decoration {\n\
  \    fill: #c9e5c9;\n\
  \    stroke: #9cb29c;\n\
  }\n\
  \n\
  .archimate-note-background {\n\
  \    fill: #fff;\n\
  \    stroke: #b2b2b2;\n\
  }\n\
  \n\
  .archimate-group-background {\n\
  \    fill: #d2d7d7;\n\
  \    stroke: #939696;\n\
  }\n\
  \n\
  .archimate-sticky-background {\n\
  \    fill: #fffeb9;\n\
  \    stroke: #b2b181;\n\
  }\n\
  \n\
  .archimate-junction-background {\n\
  \    fill: black;\n\
  \    stroke: black;\n\
  }\n\
  \n\
  .archimate-or-junction-background {\n\
  \    fill: white;\n\
  \    stroke: black;\n\
  }\n\
  \n\
  .archimate-diagram-model-reference-background {\n\
  \    fill: #dcebeb;\n\
  \    stroke: #9aa4a4;\n\
  }\n\
  \n\
  .archimate-default-background {\n\
  \    fill: #ddd;\n\
  \    stroke: #999;\n\
  }\n\
  \n\
  /* Relationships */\n\
  .archimate-relationship {\n\
  \    fill: none;\n\
  \    stroke: black;\n\
  \    stroke-width: 1px;\n\
  }\n\
  \n\
  .archimate-relationship-name {\n\
  \    font-size: 9px;\n\
  }\n\
  \n\
  .archimate-assignment-relationship {\n\
  \    marker-end: url(#archimate-dot-marker);\n\
  \    marker-start: url(#archimate-dot-marker);\n\
  }\n\
  \n\
  .archimate-composition-relationship {\n\
  \    marker-start: url(#archimate-filled-diamond);\n\
  }\n\
  \n\
  .archimate-used-by-relationship {\n\
  \    marker-end: url(#archimate-used-by-arrow);\n\
  }\n\
  \n\
  .archimate-aggregation-relationship {\n\
  \    marker-start: url(#archimate-hollow-diamond);\n\
  }\n\
  \n\
  .archimate-access-relationship {\n\
  \    marker-end: url(#archimate-open-arrow);\n\
  \    stroke-dasharray: 2, 3;\n\
  }\n\
  \n\
  .archimate-realisation-relationship {\n\
  \    marker-end: url(#archimate-hollow-arrow);\n\
  \    stroke-dasharray: 5, 3;\n\
  }\n\
  \n\
  .archimate-specialisation-relationship {\n\
  \    marker-end: url(#archimate-hollow-arrow);\n\
  }\n\
  \n\
  /*.archimate-influence-relationship, .archimate-association-relationship {\n\
  }\n\
  */\n\
  .archimate-triggering-relationship {\n\
  \    marker-end: url(#archimate-filled-arrow);\n\
  }\n\
  \n\
  .archimate-flow-relationship {\n\
  \    marker-end: url(#archimate-filled-arrow);\n\
  \    stroke-dasharray: 3, 3;\n\
  }\n\
  \n\
  /*.archimate-default-connection {\n\
  }\n\
  */\n\
  "
;;
