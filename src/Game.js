import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import ModeSelector from './ModeSelector';

class Game extends React.Component {

  pengine;

  constructor(props) {
    super(props);
    this.state = {
      mode: "#",
      grid: null,
      rowClues: null,
      colClues: null,
      checkedRowClues: null,
      checkedColClues: null,
      waiting: false,
      endGame: false
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {
    const queryS = 'init(PistasFilas, PistasColumns, Grilla)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response['Grilla'],
          rowClues: response['PistasFilas'],
          colClues: response['PistasColumns'],
          checkedRowClues: Array(response['PistasFilas'].length).fill(false),
          checkedColClues: Array(response['PistasColumns'].length).fill(false)
        });

        this.initialGridCheck();

      }
    });
  }

  handleClick(i, j) {

    if (this.state.waiting) {
      return;
    }

    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const queryS = 'put("' + this.state.mode +'", [' + i + ',' + j + '], [], [],' + squaresS + ', GrillaRes, FilaSat, ColSat)';

    // Put
    this.pengine.query(queryS, (success, response) => { 
      if (success) {
        this.setState({ // Por ahora seteo la nueva grilla
          grid: response['GrillaRes'],
          waiting: false
        });

        //Check: para pintar clue boxes
        this.checkRow(i);
        this.checkCol(j);

        //Check: para finalizar el juego
        this.checkAll();
      }
    });

    this.setState({          
      waiting: false
    });
  }

  numeralHC(){
    this.setState({mode: "#"});
  }

  cruzHC(){
    this.setState({mode: "X"});
  }

  /**
   * Check inicial del grid: permite marcar como verificadas
   * las pistas que ya son correctas desde el inicio.
   */
  initialGridCheck() {

    for (var i = 0; i < this.state.rowClues.length; i++){
      this.checkRow(i);
    }

    for (var j = 0; j < this.state.colClues.length; j++){
      this.checkCol(j);
    }

    // Asumiendo que es posible que el estado incial del juego esté completamente bien:
    this.checkAll();

  }

  /**
   * Verifica si la grilla está correctamente completa y finaliza el nivel.
   */
  checkAll() {

    this.setState({waiting: true});

    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const cClues = JSON.stringify(this.state.colClues);
    const rClues = JSON.stringify(this.state.rowClues);

    const queryCheckAll = 'check_todo('+rClues+','+ cClues +','+ squaresS + ')';

    this.pengine.query(queryCheckAll, (success, response) => {
      console.log("Juego completado?: "+success);

      if (success) {     
        this.setState({endGame: true});
      }

      this.setState({waiting: false});
    });
  }

  checkRow(i) {
    const nGrilla = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Nueva grilla en string.
    const rClues = JSON.stringify(this.state.rowClues);
    const queryCheckFila = 'check_pistas_fila('+i+','+ rClues +','+ nGrilla + ')';
    // Check fila
    this.pengine.query(queryCheckFila, (success, response) => { 
      const newCheckedRowClues = this.state.checkedRowClues.slice();
      newCheckedRowClues[i] = success;
      this.setState({checkedRowClues: newCheckedRowClues});
      console.log("Checked rows: " + this.state.checkedRowClues);
    });
  }

  checkCol(i) {
    const nGrilla = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Nueva grilla en string.
    const cClues = JSON.stringify(this.state.colClues);
    const queryCheckColumna = 'check_pistas_columna('+i+','+ cClues +','+ nGrilla + ')';

    // Check columna
    this.pengine.query(queryCheckColumna, (success, response) => {
      const newCheckedColClues = this.state.checkedColClues.slice();
      newCheckedColClues[i] = success;
      this.setState({checkedColClues: newCheckedColClues});
      console.log("Checked cols: " + this.state.checkedColClues);
    });
  }

  render() {
    if (this.state.grid === null) {
      return null;
    }
    else if (this.state.endGame) {
      return (
        <div>
          <img src="src/img/stageclear.jpg"></img>
          <p>FIN DE JUEGO</p>
        </div>
      );
    }

    return (
      
      <div className="game center">
        
          <Board
            grid={this.state.grid}
            rowClues={this.state.rowClues}
            colClues={this.state.colClues}
            checkedRowClues={this.state.checkedRowClues}
            checkedColClues={this.state.checkedColClues}
            onClick={(i, j) => this.handleClick(i,j)}
          />

          <div className="modeSelect">
            <ModeSelector
              mode = {this.state.mode}
              onCruzClick={() => this.cruzHC()}
              onNumeralClick={() => this.numeralHC()}
              onClick={(i, j) => this.mBhandleClick(i,j)}
            />
          </div>

        
      </div>
    );
  }
}

export default Game;