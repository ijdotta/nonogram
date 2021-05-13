:- module(proylcc,
	[  
		put/8,
		contarPintadas/2, %Solo para testing, remover en la versión final.
		contarCasillerosPintar/2, %Testing
		puedePintar/2 %Testing
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

put(Contenido, [RowN, ColN], _PistasFilas, _PistasColumnas, Grilla, NewGrilla, 0, 0):-
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
	replace(_Cell, ColN, Contenido, Row, NewRow)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% puedePintar(+Grid, +PistasColumnas).
%
puedePintar(Grid, PistasColumnas) :-
	contarCasillerosPintar(PistasColumnas, CantAPintar),
	contarPintadas(Grid, CantPintadas),
	CantPintadas < CantAPintar.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% contarCasillerosPintar(+PistasColumnas, -CantidadAPintar).
%
contarCasillerosPintar([], 0).

contarCasillerosPintar([Col | Cols], CantidadAPintar) :-
	contarCasillerosPintarCol(Col, CantidadAPintarCol),
	contarCasillerosPintar(Cols, CantidadAPintarCols),
	CantidadAPintar is CantidadAPintarCol + CantidadAPintarCols.

contarCasillerosPintarCol([], 0).

contarCasillerosPintarCol([C | Cs], CantidadAPintar) :-
	contarCasillerosPintarCol(Cs, CantidadAPintarSubCol),
	CantidadAPintar is C + CantidadAPintarSubCol.
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% contarPintadas(+GrillaActual, -CantidadPintadas).
%
% Observación: recordar que el formato de consulta de la grilla es con las 'X' y los '#' entre comillas dobles
%				y los espacios vacíos se representan como variables anónimas (i.e. SIN COMILLAS).
% esto es solo para testing, dado que el cliente del servidor convierte automáticamente al formato de consulta.

% ejemplo: contarPintadas([["#","#","#"], ["X", _, _], [_, _, "#"]]).

contarPintadas([], 0).

contarPintadas([R | Rs], CantPintadas) :-
	contarPintadasFila(R, CantPintadasFila),
	contarPintadas(Rs, CantPintadasSubGrid),
	CantPintadas is CantPintadasFila + CantPintadasSubGrid.

contarPintadasFila([], 0).

contarPintadasFila([C | Cs], CantPintadasFila) :-
	C == "#",
	contarPintadasFila(Cs, CantPintadasSubFila),
	CantPintadasFila is CantPintadasSubFila + 1.

contarPintadasFila([C | Cs], CantPintadasFila) :-
	C \== "#",
	contarPintadasFila(Cs, CantPintadasSubFila),
	CantPintadasFila is CantPintadasSubFila.

% Con lo que está arriba se pueden pedir múltiples soluciones con ";" pero SOLO ES VÁLIDA LA PRIMERA.
% Si se usan los predicados de abajo, solo calcula UNA solución válida.

/*	
contarPintadasFila([C | Cs], CantPintadasFila) :-
	C \= "#",
	contarPintadasFila(Cs, CantPintadasSubFila),
	CantPintadasFila is CantPintadasSubFila.

contarPintadasFila([C | Cs], CantPintadasFila) :-
	var(C),
	contarPintadasFila(Cs, CantPintadasSubFila),
	CantPintadasFila is CantPintadasSubFila.
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_columna(+Nro_col, +PistasCol, +Grilla).
%
% Asume 0 como posicion inicial de una lista.
% true si la columna en la posicion Nro_col respeta las pistas, false caso contrario.
%
/*	ej.

?- check_pistas_columna( 	0,							% Nro_col
							[[5], [1], [1], [1], [1]], 	% PistasCol

						   [["#","#","#","#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]]).

 true.
*/
check_pistas_columna(Nro_col, PistasCol, Grilla):-
    obtener_columna(Nro_col, Grilla, ColumnaRes),
    obtener_pistas(Nro_col, PistasCol, PistasRes),
    check_pistas(PistasRes, ColumnaRes).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_fila(+Nro_fil, +PistasFil, +Grilla).
%
% Asume 0 como posicion inicial de una lista.
% true si la fila en la posicion Nro_fil respeta las pistas, falso caso contrario.
%
/*	ej.

?- check_pistas_fila( 		0,							% Nro_fil
							[[5], [1], [1], [1], [1]], 	% PistasFil

						   [["#","#","#","#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]]).

 true.
*/
check_pistas_fila(Nro_fil, PistasFil, Grilla):-
    obtener_fila(Nro_fil, Grilla, FilaRes),
    obtener_pistas(Nro_fil, PistasFil, PistasRes),
    check_pistas(PistasRes, FilaRes).

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
check_todo(PistasFil, PistasCol, Grilla):-
    contar_filas(Grilla, Cant_fil),
    Cant_fil_aux is Cant_fil - 1,
    check_todas_filas(Cant_fil_aux, PistasFil, Grilla),
    contar_columnas(Grilla, Cant_col),
    Cant_col_aux is Cant_col - 1,
    check_todas_columnas(Cant_col_aux, PistasCol, Grilla).

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
    check_pistas_columna(Nro_col, PistasCol, Grilla),
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
    check_pistas_fila(Nro_fil, PistasFil, Grilla),
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
    buscar_pos(Nro_col,H,E),
    obtener_columna(Nro_col, Grillita, Columnita).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% obtener_fila(Nro_fil, Grilla, -FilaRes).
%
% Devuelve una lista con los elementos de la columna que indica Nro_fil.
%
/* ej.

?- obtener_fila( 		   0,							% Nro_fil
						   [["#","#","#","#","#"], 		
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ],		% Grilla
							["#", _ , _ , _ , _ ],
							["#", _ , _ , _ , _ ]],

							FilaRes).

FilaRes = ["#", "#", "#", "#", "#"].
*/
obtener_fila(Nro_fil, Grilla, FilaRes):- buscar_pos(Nro_fil, Grilla, FilaRes).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% obtener_pistas(+Pos, +PistasFull, -PistasRes).
%
% Asume 0 como posicion inicial.
% Devuelve la lista de pistas en la posicion Pos.
% PistasFull puede ser PistasCol o PistasFil.
%
/* ej.

?- obtener_pistas( 		1,													% Pos
						[[1], [2,2], [3,3,3], [4,4,4,4], [5,5,5,5,5]], 		% PistasCol o PistasFil

						PistasRes).

PistasRes = [2, 2].
*/
obtener_pistas(Pos, PistasFull, PistasRes):- buscar_pos(Pos, PistasFull, PistasRes).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% buscar_pos(+Pos, +Lista, -ElementoRes).
%
% Asume 0 como posicion inicial.
% Devuelve el elemento en la posicion Pos de la Lista.
%
/* ej.

?- obtener_pistas( 		1,					% Pos
						[a,b,c,d,e], 		% Lista

						ElementoRes).

ElementoRes = b.
*/
buscar_pos(0,[H|_T],H).
buscar_pos(Pos, [_H|T], ElementoRes):-
    PosAux is Pos - 1,
    buscar_pos(PosAux,T, ElementoRes).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas(+Pistas, +Lista).
%
% true si la lista respeta las pistas, false caso contrario.
% 
% Esta parte busca la primer celda pintada,
% de la Lista se ignoran las celdas no pintadas, dejandola con un "#" al principio.
%
/* ej.

?- check_pistas( 	[1,1,1],				% Pistas
					["#", _ ,"#", _ ,"#"] 	% Lista
				).

true.
*/
check_pistas(Pistas,[H2|Listita]):- %Si encuentro celda pintada, asegurarme que respete la secuencia de las pistas.
    H2 == "#",    
    check_pistas_secuencia(Pistas, [H2|Listita]).
check_pistas(Pistas,[H2|Listita]):- %Si encuentro celda no pintada, avanzo en la lista.
    H2 \== "#",
    check_pistas(Pistas, Listita).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_secuencia(+Pistas, +Lista).
%
% true si la Lista recorrida por check_pistas/2 comienza con N de celdas pintadas, false caso contrario.
% donde N es la primer pista en Pistas.
%
% Esta parte al encontrar la secuencia, remueve la primer pista en Pistas y devuelve
% la Lista sin la secuencia encontrada.
%
/* ej.

?- check_pistas_secuencia( 	[5],					% Pistas
							["#","#","#","#", _ ] 	% Lista
						).

false.
*/
check_pistas_secuencia([0],[]). %Si recorri toda la lista y no hay mas pistas, terminé, devuelvo true.
check_pistas_secuencia([0],Listita):- check_pistas_aux(Listita). % Cuando agoto todas las pistas, y todavia hay elementos en la lista me fijo que no queden celdas pintadas en el resto de la lista.
check_pistas_secuencia([0|Pistitas],[H|Listita]):- %Cuando agoto una pista, aseguro que haya un espacio entre pistas, remuevo la pista agotada de Pistas.
    H \== "#",
    check_pistas(Pistitas,Listita).
check_pistas_secuencia([H1|Pistitas], [H2|Listita]):- % Por cada celda pintada se disminuye la pista.
    H2 == "#",
    H1_aux is H1 -1,
    check_pistas_secuencia([H1_aux|Pistitas], Listita).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_pistas_aux(+Lista).
%
% true si la Lista no tiene celdas pintadas, false caso contrario.
%
/* ej.

?- check_pistas_aux( 	[ _ , _ ,"X", _ , _ ] 	% Lista

					).

true.
*/
check_pistas_aux([]).
check_pistas_aux([H|Listita]):-
    H \== "#",
    check_pistas_aux(Listita).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% contar_filas(+Grilla, -Cant_fil).
%
% Devuelve la cantidad de filas que tiene la grilla.
%
/* ej.

?- contar_filas(   [["#","#","#","#","#"], 		
					["#", _ , _ , _ , _ ],
					["#", _ , _ , _ , _ ],		% Grilla
					["#", _ , _ , _ , _ ],
					["#", _ , _ , _ , _ ]],

					Cant_fil).

Cant_fil = 5.
*/
contar_filas(Grilla, Cant_fil):- contar_elementos(Grilla, Cant_fil).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% contar_columnas(+Grilla, -Cant_col).
%
% Devuelve la cantidad de columnas que tiene la grilla.
%
/* ej.

?- contar_columnas(    [["#","#","#","#","#"], 		
						["#", _ , _ , _ , _ ],
						["#", _ , _ , _ , _ ],		% Grilla
						["#", _ , _ , _ , _ ],
						["#", _ , _ , _ , _ ]],

						Cant_col).

Cant_col = 5.
*/    
contar_columnas([H|_Grillita], Cant_col):- contar_elementos(H, Cant_col).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% contar_elementos(+Lista, -Cant_elem).
%
% Devuelve la cantidad de elementos en la Lista.
%
/* ej.

?- contar_elementos(    [a,b,c,d,e], % Lista

						Cant_elem).

Cant_elem = 5.
*/  
contar_elementos([],0).
contar_elementos([_H|T], Cant_elem):-
    contar_elementos(T, Cant_elem_aux),
    Cant_elem is Cant_elem_aux + 1.