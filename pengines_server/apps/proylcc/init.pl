
:- module(init, [ init/3 ]).

init(
[[1,3], [0], [1], [1], [1]],	% PistasFilas

[[1,3], [0], [1], [1], [1]], 	% PistasColumnas

[["X", _ , _ , _ , _ ], 		
 ["X", _ ,"X", _ , _ ],
 ["X", _ , _ , _ , _ ],		% Grilla
 ["#", _ , _ , _ , _ ],
 [ _ , _ ,"#","#","#"]
]
).

/* Original
init(
[[3], [1,2], [4], [5], [5]],	% PistasFilas

[[2], [5], [1,3], [5], [4]], 	% PistasColumnas

[["X", _ , _ , _ , _ ], 		
 ["X", _ ,"X", _ , _ ],
 ["X", _ , _ , _ , _ ],		% Grilla
 ["#","#","#", _ , _ ],
 [ _ , _ ,"#","#","#"]
]
).
*/