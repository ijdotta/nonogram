:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY).
%
% XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%
/* ej.
?- put(		"#",						% Contenido
			[4,1],						% Pos
			[[5], [1], [1], [1], [1]],	% PistasFilas
			[[5], [1], [1], [1], [1]], 	% PistasColumnas

		   [["#","#","#","#","#"], 		
			["#", _ , _ , _ , _ ],
			["#", _ , _ , _ , _ ],		% Grilla
			["#", _ , _ , _ , _ ],
			[ _ , _ , _ , _ , _ ]],
			
			GrillaRes,
			FilaSat,
			ColSat).

ColSat = 0,
FilaSat = 1,
GrillaRes = [[ "#" ,  "#" ,  "#" ,  "#" ,  "#" ],
			 [ "#" , _2150, _2156, _2162, _2168],
			 [ "#" , _2192, _2198, _2204, _2210],
			 [ "#" , _2234, _2240, _2246, _2252],
			 [_2264,  "#" , _2282, _2288, _2294]]
*/
put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, FilaSat, ColSat):-
	% NewGrilla es el resultado de reemplazar la fila Row en la posición RowN de Grilla
	% (RowN-ésima fila de Grilla), por una fila nueva NewRow.
	replace(Row, RowN, NewRow, Grilla, NewGrilla),

	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Conenido.	 
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Contenido 
		;
	replace(_Cell, ColN, Contenido, Row, NewRow)),
	% Luego de tener la nueva grilla, verificar si la fila y columna afectadas satisfacen las pistas.
	check_pistas_fila(RowN, PistasFilas, NewGrilla, FilaSat),
	check_pistas_columna(ColN, PistasColumnas, NewGrilla, ColSat).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_columna(+Nro_col, +PistasCol, +Grilla, -ColSat).
%
% Asume 0 como posicion inicial de una lista.
% ColSat devuelve 1 si la columna en la posicion Nro_col respeta las pistas, 0 caso contrario.
%
/*	ej.

?- check_pistas_columna( 	0,							% Nro_col
							[[5], [1], [1], [1], [1]], 	% PistasCol

						   [["#","#","#","#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]],
							
							ColSat).

 ColSat = 1.
*/
check_pistas_columna(Nro_col, PistasCol, Grilla, ColSat):-
    obtener_columna(Nro_col, Grilla, ColumnaRes),
    nth0(Nro_col, PistasCol, PistasRes), % obtener pistas
    check_pistas(PistasRes, ColumnaRes, ColSat).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_fila(+Nro_fil, +PistasFil, +Grilla, -FilaSat).
%
% Asume 0 como posicion inicial de una lista.
% FilaSat devuelve 1 si la fila en la posicion Nro_fil respeta las pistas, 0 caso contrario.
%
/*	ej.

?- check_pistas_fila( 		0,							% Nro_fil
							[[5], [1], [1], [1], [1]], 	% PistasFil

						   [["#","#","#","#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]],
							
							FilaSat).

 FilaSat = 1.
*/
check_pistas_fila(Nro_fil, PistasFil, Grilla, FilaSat):-
    nth0(Nro_fil, Grilla, FilaRes), % obtener fila
    nth0(Nro_fil, PistasFil, PistasRes), % obtener pistas
    check_pistas(PistasRes, FilaRes, FilaSat).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_todo(+PistasFil, +PistasCol, +Grilla).
%
% true si toda la grilla respeta todas las pistas, falso caso contrario
%
/* ej.

?- check_todo( 		  [[5], [1], [1], [1], [1]],	% PistasFil
                      [[5], [1], [1], [1], [1]], 	% PistasCol

                      [["#","#","#","#","#"], 		
                       ["#", _ , _ , _ , _ ],
                       ["#", _ ,"#", _ , _ ],		% Grilla
                       ["#", _ , _ , _ , _ ],
                       ["#", _ , _ , _ , _ ]]).

false.					   
*/
check_todo(PistasFil, PistasCol, [H|Grilla]):- % Tomo la primer fila de la grilla para despues saber la cantidad de columnas.
    length([H|Grilla], Cant_fil),
    Cant_fil_aux is Cant_fil - 1,
    check_todas_filas(Cant_fil_aux, PistasFil, [H|Grilla]),
    length(H, Cant_col),
    Cant_col_aux is Cant_col - 1,
    check_todas_columnas(Cant_col_aux, PistasCol, [H|Grilla]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_todas_columnas(+Nro_col, +PistasCol, +Grilla).
%
% Asume 0 es la primer columna
% true si toda la grilla respeta todas las pistas, falso caso contrario
%
/* ej.

?- check_todas_columnas( 	4,							% Nro_col
							[[5], [1], [1], [1], [1]], 	% PistasCol

						   [["#","#", _ ,"#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ ,"#", _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]]).

true.					   
*/
check_todas_columnas(-1, _PistasCol, _Grilla).
check_todas_columnas(Nro_col, PistasCol, Grilla):-
    check_pistas_columna(Nro_col, PistasCol, Grilla, ColSat),
	ColSat == 1, % Si la columna satisface, continuar.
    Nro_col_aux is Nro_col -1,
    check_todas_columnas(Nro_col_aux, PistasCol, Grilla).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_todas_filas(+Nro_fil, +PistasFil, +Grilla).
%
% Asume 0 es la primer fila
% true si toda la grilla respeta todas las pistas, falso caso contrario
%
/* ej.

?- check_todas_filas( 		4,							% Nro_fil
							[[5], [1], [1], [1], [1]], 	% PistasFil

						   [["#","#", _ ,"#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ ,"#", _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]]).

false.					   
*/
check_todas_filas(-1, _PistasFil, _Grilla).
check_todas_filas(Nro_fil, PistasFil, Grilla):-
    check_pistas_fila(Nro_fil, PistasFil, Grilla, FilaSat),
	FilaSat == 1, % Si la fila satisface, continuar.
    Nro_fil_aux is Nro_fil -1,
    check_todas_filas(Nro_fil_aux, PistasFil, Grilla).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% obtener_columna(+Nro_col, +Grilla, -ColumnaRes).
%
% Devuelve una lista con los elementos de la columna que indica Nro_col.
%
/* ej.

?- obtener_columna( 		0,							% Nro_col
						   [["#","#","#","#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]],

							ColumnaRes).

ColumnaRes = ["#", "#", "#", "#", "#"].
*/
obtener_columna(_Nro_col, [], []).
obtener_columna(Nro_col, [H|Grillita], [E|Columnita]):-
    nth0(Nro_col,H,E), % obtener elemento de la columna
    obtener_columna(Nro_col, Grillita, Columnita).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas(+Pistas, +Lista, -Satisface).
%
% Satisface devuelve 1 si la lista respeta las pistas, 0 caso contrario.
% 
% Esta parte busca la primer celda pintada,
% de la Lista se ignoran las celdas no pintadas, dejandola con un "#" al principio.
%
/* ej.

?- check_pistas( 	[1,1,1],				% Pistas
					["#", _ ,"#", _ ,"#"], 	% Lista
				
					Satisface).

Satisface = 1.
*/
check_pistas(Pistas,[H2|Listita], Satisface):- %Si encuentro celda pintada, asegurarme que respete la secuencia de las pistas.
    H2 == "#",    
    check_pistas_secuencia(Pistas, [H2|Listita], Satisface).
check_pistas(Pistas,[H2|Listita], Satisface):- %Si encuentro celda no pintada, avanzo en la lista.
    H2 \== "#",
    check_pistas(Pistas, Listita, Satisface).
check_pistas([],[], 1). %Si no hay pistas y recorrí toda la lista sin encontrar una celda, satisface, devuelvo 1.
check_pistas(_Pistas,[], 0). %Si habian pistas y recorrí toda la lista sin encontrar una celda, no satisface, devuelvo 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_secuencia(+Pistas, +Lista, -Satisface).
%
% Satisface = 1 si la Lista recorrida por check_pistas/2 comienza con N de celdas pintadas, 0 caso contrario.
% donde N es la primer pista en Pistas.
%
% Esta parte al encontrar la secuencia, remueve la primer pista en Pistas y devuelve
% la Lista sin la secuencia encontrada.
%
/* ej.

?- check_pistas_secuencia( 	[5],					% Pistas
							["#","#","#","#", _ ], 	% Lista
							Satisface).

Satisface = 0.
*/
check_pistas_secuencia([0],[],1). %Si recorri toda la lista y no hay mas pistas, terminé, devuelvo 1.
check_pistas_secuencia([0],Listita, Satisface):- check_pistas_aux(Listita, Satisface). % Cuando agoto todas las pistas, y todavia hay elementos en la lista me fijo que no queden celdas pintadas en el resto de la lista.
check_pistas_secuencia([0|Pistitas],[H|Listita], Satisface):- %Cuando agoto una pista, aseguro que haya un espacio entre pistas, remuevo la pista agotada de Pistas.
    H \== "#",
    check_pistas(Pistitas,Listita, Satisface).
check_pistas_secuencia([H1|Pistitas], [H2|Listita], Satisface):- % Por cada celda pintada se disminuye la pista.
    H2 == "#",
    H1_aux is H1 -1,
    check_pistas_secuencia([H1_aux|Pistitas], Listita, Satisface).
check_pistas_secuencia(_Pistas,_Listas, 0). % Si falla en alguna parte del check, devolver 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_aux(+Lista, -Satisface).
%
% true si la Lista no tiene celdas pintadas, false caso contrario.
%
/* ej.

?- check_pistas_aux( 	[ _ , _ ,"X", _ , _ ] 	% Lista

						Satisface).

Satisface = 1.
*/
check_pistas_aux([], 1). 		% No habia celdas pintadas, devolver 1.
check_pistas_aux([H|Listita], Satisface):- % Ver si hay celdas pintadas.
    H \== "#",
    check_pistas_aux(Listita, Satisface).
check_pistas_aux([H|_Listita], 0):- 	% Si hay una celda pintada, devolver 0.
	H == "#".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% resolverGrilla(+RowClues, +ColClues, -GrillaRes)
%
% Devuelve una grilla que respete las pistas.
%
% ***Comentario***
% Se utiliza reverse/2 para invertir la lista de pistas, esto
% es una cuestion de comodidad nada mas, ya que en generarGrilla/3
% cuando se van generando las lineas a partir de las pistas,
% en el predicado, se toma la ultima pista de la lista de pistas y
% la linea se inserta al principio de la grilla, inviertiendo
% entonces evita el uso de append/3.
%
/* ej.
?- resolverGrilla(	    [[1],[1],[1]], %RowClues
						[[1],[1],[1]], %ColClues
					GrillaRes).

GrillaRes = [["#", "X", "X"],
			 ["X", "#", "X"],
			 ["X", "X", "#"]]
*/
resolverGrilla(RowClues, ColClues, GrillaRes):-
    length(RowClues, RLength),
    length(ColClues, CLength),
    RLength_aux is (RLength - 1),
    CLength_aux is (CLength - 1),
    reverse(RowClues,RowCluesInverted), % Invierto las pistas para que en generarGrilla/3 el nth0/3 tome la primer pista para generar lineas. 
    generarGrilla(RowCluesInverted, CLength, RLength_aux, GrillaRes), %Generar 1 posible grilla
    check_todas_columnas(CLength_aux, ColClues, GrillaRes). %Chequear que la grilla sea valida
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% generarGrilla(+RowClues, +CLength, +RowIndex, -PosibleGrilla).
%
% genera una grilla que respeta las pistas de fila.
% 
/* ej.
?- generarGrilla(	   [[3],[1],[3]], 	%RowClues
						3, 				%CLength
						2,				%RowIndex
                  PosibleGrilla).

PosibleGrilla = [["#", "#", "#"],
				 ["#", "X", "X"],
				 ["#", "#", "#"]]

PosibleGrilla = [["#", "#", "#"],
				 ["X", "#", "X"],
				 ["#", "#", "#"]]

PosibleGrilla = [["#", "#", "#"],
				 ["X", "X", "#"],
				 ["#", "#", "#"]]			  
*/
generarGrilla(_RowClues, _CLength, -1, []). % Ya genere todas las filas, empiezo armando desde vacio.
generarGrilla(RowClues, CLength, RowIndex, [PosibleLinea|PosibleGrillita]):-
    nth0(RowIndex, RowClues, Clues), % Busco las pistas para la linea RowIndex
    generarLinea(Clues, CLength, PosibleLinea), % Genero una posible solucion a la linea
    RowIndex_aux is (RowIndex - 1),
    generarGrilla(RowClues, CLength, RowIndex_aux, PosibleGrillita). % Buscar siguiente posible linea

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% generarLinea(+Pistas, +Longitud, -PosibleLinea).
%
% Devuelve una o varias soluciones de una linea segun sus Pistas
%
/* ej.
?- generarLinea(	[1,1], 	%Pistas
               		 4, 	%Longitud
                  PosibleLinea).

PosibleLinea = ["#", "X", "#", "X"]

PosibleLinea = ["#", "X", "X", "#"]

PosibleLinea = ["X", "#", "X", "#"]
*/

% No hay pistas y la Lista alcanzo la longitud maxima
% devuelvo una lista vacia
generarLinea([], 0, []):- !.
% No hay pistas y la Lista no alcanzo la longitud maxima
% relleno con cruces.
generarLinea([], Longitud, Lista):-
    subRelleno("X", Longitud, Lista),!.

% Hay solo 1 pista, junto lo generado en el ultimo paso con una secuencia pintada sin separar
%(ya se que en la recursividad me duelve una lista vacia o
% lo que faltaba para rellenar con cruces).
generarLinea([Pista], Longitud, Lista):-
    Pista =< Longitud,
    Longitud_aux is Longitud - Pista,
    generarLinea([], Longitud_aux, Listita),    
    subRelleno("#", Pista, Pintado),
    append(Pintado,Listita,Lista).

% Hay multiples pistas, junto la nueva secuencia pintada con la sub-lista de
% la recursion, las separo con una Cruz.
generarLinea([Pista|Pistitas], Longitud, Lista):-
    Pistitas \= [], % esto es para que en el backtracking no intente resolver dos veces lo mismo en el caso de que haya 1 pista.
    Pista + 1 =< Longitud,
    Longitud_aux is Longitud - (Pista+1),
    generarLinea(Pistitas, Longitud_aux, Listita),    
    subRelleno("#", Pista, Pintado),
    append(Pintado,["X"|Listita],Lista).

% Hay pistas, agrego una Cruz al principio de cualquier sub-lista generada
% es esencial para generar las distintas variantes.
generarLinea(Pistas, Longitud, ["X"|Listita]):-
    Longitud \= 0,
    Longitud_aux is Longitud - 1,
    generarLinea(Pistas, Longitud_aux, Listita).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% subRelleno(+Simbolo, +Cantidad, -LineaRellena)
%
% Crea una lista llena de un simbolo de una longitud determinada.
%
/* ej.
?- subRelleno(	"#", 	%Simbolo
           		 5,		%Cantidad
           LineaPintada).

LineaPintada = ["#", "#", "#", "#", "#"]
*/
subRelleno(_Simbolo, 0, []).
subRelleno(Simbolo, Longitud, [Simbolo|SubListita]):-
    Longitud_aux is Longitud - 1,
    subRelleno(Simbolo, Longitud_aux, SubListita),!.		