import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import ModeSelector from './ModeSelector';
import CustomButton from './CustomButton';

class Game extends React.Component {

  pengine;

  constructor(props) {
    super(props);
    this.state = {
      mode: "#",
      unveilCellMode: false,
      showingSolution: false,
      levels: null,
      level: 0,
      maxLevelIndex: 0,
      grid: null,
      rowClues: null,
      colClues: null,
      solvedGrid: null,
      savedGrid: null,
      checkedRowClues: null,
      checkedColClues: null,
      waiting: false,
      endGame: true,
      gameStatus: '¡Empieza a jugar!'
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {
    const queryS = 'init(Inits)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {

        const nLevels = response['Inits'].slice();

        this.setState(
          {
            levels: nLevels,
            maxLevelIndex: nLevels.length - 1
          },
          this.nextLevel // Callback que espera a setState
        )

      }
    });
  }

  /**
   * Avanza al siguiente nivel disponible o finaliza el juego.
   */
  nextLevel() {

    if (!this.state.endGame){
      return;
    }

    this.setState({
      waiting: true,
      solvedGrid: null
    });


    const nLevel = this.state.level;

    console.log("MaxLevel / currentLevel :: " + this.state.maxLevelIndex + "/" + nLevel);
    if (nLevel > this.state.maxLevelIndex) {
      this.setState({
        gameStatus: "¡Has completado todos los niveles!"
      })
      return;
    }

    const levelData = this.state.levels[nLevel].slice();

    /**
     * Level data format:
     *  [rowClues, colClues, grid]
     */
    this.setState(
      {
        rowClues: levelData[0],
        colClues: levelData[1],
        grid: levelData[2],
        checkedRowClues: Array(levelData[0].length).fill(false),
        checkedColClues: Array(levelData[1].length).fill(false),
        level: (nLevel + 1),
        unveilCellMode: false,
        endGame: false
      },
      this.getSolution
      //this.initialGridCheck //Callback function (espera al setState para no chequear sobre el tablero anterior)
    );

    this.setState({
      waiting: false
    });

  }

  /**
   * Recupera la solución para las pistas del nivel actual.
   */
  getSolution() {

    this.setState({
      waiting: true,
      gameStatus: "Calculando la solución..."
    })

    const rClues = JSON.stringify(this.state.rowClues).replaceAll('"_"', "_"); // Remove quotes for variables.
    const cClues = JSON.stringify(this.state.colClues).replaceAll('"_"', "_"); // Remove quotes for variables.
    
    const querySolve = 'solve(' + rClues + ', ' + cClues + ', SolvedGrid)';

    this.pengine.query(querySolve, (success, response) => {
      if (success) {
        this.setState(
          {
            solvedGrid: response['SolvedGrid'],
            gameStatus: "¡Comienza a jugar!",
            waiting: false
          },
          this.initialGridCheck
        )
      }
    });
  }

  handleClick(i, j) {

    console.log("EndGame: " + this.state.endGame);

    if (this.state.waiting || this.state.endGame) {
      return;
    }
    else if (this.state.unveilCellMode) {

      this.setState({waiting: true})

      this.unveilCell(i, j);

      this.setState({waiting: false})

      return;
    }

    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const rClues = JSON.stringify(this.state.rowClues).replaceAll('"_"', "_"); // Remove quotes for variables.
    const cClues = JSON.stringify(this.state.colClues).replaceAll('"_"', "_"); // Remove quotes for variables.
    
    const queryS = 'put("' + this.state.mode +'", [' + i + ',' + j + '], ' + rClues + ', ' + cClues + ',' + squaresS + ', GrillaRes, FilaSat, ColSat)';

    console.log("QUERY: " + queryS);

    // Put
    this.pengine.query(queryS, (success, response) => {
      console.log("Put success: " + success);
      if (success) {
        
        //Check: para pintar clue boxes (filas)
        const newCheckedRowClues = this.state.checkedRowClues.slice();
        newCheckedRowClues[i] = response['FilaSat'] === 1;

        //Check: para pintar clue boxes (columnas)
        const newCheckedColClues = this.state.checkedColClues.slice();
        newCheckedColClues[j] = response['ColSat'] === 1;

        this.setState(
          {
            grid: response['GrillaRes'],
            checkedRowClues: newCheckedRowClues,
            checkedColClues: newCheckedColClues,
          },
          this.checkAll //Check: finalizar juego
        );
      }
    });

    this.setState({          
      waiting: false,
      gameStatus: "¡Sigue jugando!"
    });
  }

  /**
   * Revela el contenido correcto de la celda (i,j) y actualiza el estado de las pistas
   * @param {*} i 
   * @param {*} j 
   */
  unveilCell(i, j) {

    if (this.state.waiting) {
      return;
    }

    //const newGrid = this.state.grid.slice();
    const newGrid = this.state.grid.map((x) => x.map((y) => y));
    newGrid[i][j] = this.state.solvedGrid[i][j];

    // callback function para check new cell
    const checkCell = () => {

      console.log("Current grid before check: ");
      for (let i = 0; i < this.state.grid.length; i++) {
        const element = this.state.grid[i];
        console.log(element + " ; ")
      }

      var newCheckedRowClues = this.state.checkedRowClues.slice();
      var newCheckedColClues = this.state.checkedColClues.slice();

      newCheckedRowClues[i] = this.checkRow(i);
      newCheckedColClues[j] = this.checkCol(j);

      this.setState(
        {
          checkedRowClues: newCheckedRowClues,
          checkedColClues: newCheckedColClues
        },
        this.checkAll
      )
    }

    this.setState(
      {grid: newGrid},
      checkCell
    )
  }

  /**
   * Muestra la solución del juego
   */
  showSolution() {

    // copia en profundidad de la matriz.
    const nSavedGrid = this.state.grid.map((x) => x.map((y) => y));
    // copia superficial de solved.
    const solvedGrid = this.state.solvedGrid.slice();

    this.setState({
      grid: solvedGrid,
      savedGrid: nSavedGrid
    });
  }

  /**
   * Reestablece la grilla de juego para dejar de mostrar la solución
   */
  restoreGameGrid() {
    const gameGrid = this.state.savedGrid.slice();

    this.setState({
      grid: gameGrid,
      savedGrid: null
    });
  }

  setPaintingState() {
    if (this.state.waiting) {
      return;
    }

    this.setState({
      mode: "#",
      gameStatus: "¡Sigue jugando!"
    });
  }

  setCrossingState(){
    if (this.state.waiting) {
      return;
    }
    
    this.setState({
      mode: "X",
      gameStatus: "¡Sigue jugando!"
    });
  }

  /**
   * Check inicial del grid: permite marcar como verificadas
   * las pistas que ya son correctas desde el inicio.
   */
  initialGridCheck() {

    var newCheckedRowClues = this.state.checkedRowClues.slice();
    var newCheckedColClues = this.state.checkedColClues.slice();

    for (var i = 0; i < this.state.rowClues.length; i++){
      newCheckedRowClues[i] = this.checkRow(i);
    }

    for (var j = 0; j < this.state.colClues.length; j++){
      newCheckedColClues[j] = this.checkCol(j);
    }

    this.setState(
      {
        checkedRowClues: newCheckedRowClues,
        checkedColClues: newCheckedColClues
      },
      // Asumiendo que es posible que el estado incial del juego esté completamente bien:
      this.checkAll
    )

    
    //this.checkAll();

  }

  /**
   * Verifica si la grilla está correctamente completa y finaliza el nivel.
   */
  checkAll() {

    this.setState({waiting: true});

    const checkedRowClues = this.state.checkedRowClues;
    const checkedColClues = this.state.checkedColClues;

    var checked = true;

    for (let i = 0; i < checkedRowClues.length && checked; i++) {
      checked = checkedRowClues[i];
    }

    for (let i = 0; i < checkedColClues.length && checked; i++) {
      checked = checkedColClues[i];
    }

    console.log("endGame? " + checked);
    
    var msg;
    if (checked) {
      msg = this.state.level <= this.state.maxLevelIndex? "¡Avanza al siguiente nivel!" : "¡Has completado todos los niveles!";
    }
    else {
      msg = this.state.gameStatus;
    } 

    this.setState({
      endGame: checked,
      gameStatus: msg,
      waiting: false
    })

  }

  /*
      Grid = array of rows
  */

  checkRow(i) {

    const currentGrid = this.state.grid.slice();
    const solvedGrid = this.state.solvedGrid.slice();

    var checked = true;

    for (let j = 0; j < currentGrid[i].length && checked; j++) {
      checked = solvedGrid[i][j] === "#"? currentGrid[i][j] === "#" : currentGrid[i][j] !== "#";
    }

    console.log("CheckedRowClues: " + this.state.checkedRowClues);

    return checked;
  }

  checkCol(i) {

    const currentGrid = this.state.grid.slice();
    const solvedGrid = this.state.solvedGrid.slice();

    var checked = true;
    
    for (let j = 0; j < currentGrid.length && checked; j++) {
      checked = solvedGrid[j][i] === "#"? currentGrid[j][i] === "#" : currentGrid[j][i] !== "#";
    }

    console.log("CheckedColClues: " + this.state.checkedColClues);
    
    return checked;
  }

  showHideSolution() {

    if (this.state.solvedGrid === null) {
      return;
    }

    const showingSolutionState = this.state.showingSolution;
    if (showingSolutionState) {
      this.restoreGameGrid();
      this.setState({
        waiting: false,  // enable interaction after restoring gameGrid
        gameStatus: "Has vuelto al tablero de juego"
      })
    }
    else {
      this.showSolution();
      this.setState({
        waiting: true, // disable interaction while showing solution
        gameStatus: "Estás viendo la solución"
      })
    }

    this.setState({
      showingSolution: !showingSolutionState
    });
  }

  toggleUnveilCellMode() {

    if (this.state.waiting) {
      return;
    }

    const unveilCellMode = this.state.unveilCellMode;
    var msg = unveilCellMode? "¡Sigue jugando!" : "¡Revelando celdas!";

    this.setState({
      unveilCellMode: !unveilCellMode,
      gameStatus: msg
    })
  }

  render() {

    const gameStatus = this.state.gameStatus;
    const waiting = this.state.waiting;
    var hide = " hidden";

    console.log("GAMESTATUS: " + gameStatus); 

    if (this.state.grid === null) {
      return null;
    }
    else if (this.state.endGame && this.state.level <= this.state.maxLevelIndex) {
      hide = "";
    }

    return (
      
      <div className="game center">
        
        <div className="gameStatus">{gameStatus}</div>

          <Board
            grid={this.state.grid}
            rowClues={this.state.rowClues}
            colClues={this.state.colClues}
            checkedRowClues={this.state.checkedRowClues}
            checkedColClues={this.state.checkedColClues}
            onClick={(i, j) => this.handleClick(i,j)}
          />

          <div className="buttons">

            <CustomButton
              className={"hintBtn showHideSolutionBtn modeBox"}
              content={"▣"}
              selected={(this.state.showingSolution === true)}
              onClick={() => this.showHideSolution()}
            />

            <div className="modeSelect">
              <ModeSelector
                mode = {this.state.mode}
                setCrossingState={() => this.setCrossingState()}
                setPaintingState={() => this.setPaintingState()}
              />
            </div>

            <CustomButton
              className={"hintBtn unveilCellBtn modeBox"}
              content={"💡"}
              selected={(this.state.unveilCellMode)}
              onClick={(i,j) => this.toggleUnveilCellMode()}
            />

            

          </div>

          <div className={"nextLevelBtnContainer" + hide}>
              <CustomButton
                className={"nextLevelBtn"}
                onClick={() => this.nextLevel()}
                content={'⮕'}
              />
          </div>
        
      </div>
    );
  }
}

export default Game;