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

