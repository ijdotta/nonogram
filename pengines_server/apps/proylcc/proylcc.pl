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
% replace(?X, +XIndex, +Y, +Xs, -XsY)
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
% puedePintar(+Grid, +PistasColumnas)
%
puedePintar(Grid, PistasColumnas) :-
	contarCasillerosPintar(PistasColumnas, CantAPintar),
	contarPintadas(Grid, CantPintadas),
	CantPintadas < CantAPintar.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% contarCasillerosPintar(+PistasColumnas, -CantidadAPintar)
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
% contarPintadas(+GrillaActual, -CantidadPintadas)
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
	nonvar(C),
	C = "#",
	contarPintadasFila(Cs, CantPintadasSubFila),
	CantPintadasFila is CantPintadasSubFila + 1.

contarPintadasFila([_C | Cs], CantPintadasFila) :-
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
% predicado()
%
check_pistas_columna(Nro_col, PistasCol, Grilla):-
    obtener_columna(Nro_col, Grilla, Columna),
    obtener_pistas(Nro_col, PistasCol, Pistas),
    check_pistas(Pistas, Columna).

check_pistas_fila(Nro_fil, PistasFil, Grilla):-
    obtener_fila(Nro_fil, Grilla, Fila),
    obtener_pistas(Nro_fil, PistasFil, Pistas),
    check_pistas(Pistas, Fila).

% Indica si la grilla respeta todas las pistas
check_todo(PistasFil, PistasCol, Grilla):-
    contar_filas(Grilla, Cant_fil),
    Cant_fil_aux is Cant_fil - 1,
    check_todas_filas(Cant_fil_aux, PistasFil, Grilla),
    contar_columnas(Grilla, Cant_col),
    Cant_col_aux is Cant_col - 1,
    check_todas_columnas(Cant_col_aux, PistasCol, Grilla).
    
obtener_columna(_Nro_col, [], []).
obtener_columna(Nro_col, [H|Grillita], [E|Columnita]):-
    buscar_pos(Nro_col,H,E),
    obtener_columna(Nro_col, Grillita, Columnita).

obtener_fila(Nro_fil, Grilla, Fila):- buscar_pos(Nro_fil, Grilla, Fila).

obtener_pistas(Pos, PistasCol, Pistas):- buscar_pos(Pos, PistasCol, Pistas).

buscar_pos(0,[H|_T],H).
buscar_pos(Pos, [_H|T], E):-
    PosAux is Pos - 1,
    buscar_pos(PosAux,T, E).


check_pistas([H1|Pistitas],[H2|Listita]):- %Si encuentro celda pintada, asegurarme que respete la secuencia de las pistas.
    H2 == "#",    
    check_pistas_secuencia([H1|Pistitas], [H2|Listita]).
check_pistas([H1|Pistitas],[H2|Listita]):- %Si encuentro celda no pintada, avanzo en la lista.
    H2 \== "#",
    check_pistas([H1|Pistitas], Listita).

% Se asegura que haya una secuencia pintada como indica la pista
check_pistas_secuencia([0],[]). %Si recorri toda la lista y no hay mas pistas, devuelvo true.
check_pistas_secuencia([0],Listita):- check_pistas_aux(Listita). % Cuando agoto todas las pistas, me fijo que no queden celdas pintadas en el resto de la lista.
check_pistas_secuencia([0|Pistitas],[H|Listita]):- %Cuando agoto una pista, avanzo a siguiente pista, me fijo que no haya una celda pintada.
    H \== "#",
    check_pistas(Pistitas,Listita).
check_pistas_secuencia([H1|Pistitas], [H2|Listita]):-
    H2 == "#",
    H1_aux is H1 -1,
    check_pistas_secuencia([H1_aux|Pistitas], Listita).

% Devuelve false si encuentra una celda pintada.
check_pistas_aux([]).
check_pistas_aux([H|Listita]):-
    H \== "#",
    check_pistas_aux(Listita).

contar_filas(Grilla, Cant_col):- contar_elementos(Grilla, Cant_col).
    
contar_columnas([H|_Grillita], Cant_fil):- contar_elementos(H, Cant_fil).


contar_elementos([],0).
contar_elementos([_H|T], Cant_elem):-
    contar_elementos(T, Cant_elem_aux),
    Cant_elem is Cant_elem_aux + 1.

check_todas_columnas(-1, _PistasCol, _Grilla).
check_todas_columnas(Nro_col, PistasCol, Grilla):-
    check_pistas_columna(Nro_col, PistasCol, Grilla),
    Nro_col_aux is Nro_col -1,
    check_todas_columnas(Nro_col_aux, PistasCol, Grilla).

check_todas_filas(-1, _PistasFil, _Grilla).
check_todas_filas(Nro_fil, PistasFil, Grilla):-
    check_pistas_fila(Nro_fil, PistasFil, Grilla),
    Nro_fil_aux is Nro_fil -1,
    check_todas_filas(Nro_fil_aux, PistasFil, Grilla).