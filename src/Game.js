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
      waiting: false
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
      }
    });
  }

  handleClick(i, j) {
    // No action on click if we are waiting.
    if (this.state.waiting) {
      return;
    }
    const squaresS = JSON.stringify(this.state.grid).replaceAll('"_"', "_"); // Remove quotes for variables.
    const cClues = JSON.stringify(this.state.rowClues);
    const rClues = JSON.stringify(this.state.rowClues);

    const queryCheckTodo = 'check_todo('+rClues+','+ cClues +','+ squaresS + ')';
    this.setState({
      waiting: true
    });
    // Preguntar si se gano el juego
    this.pengine.query(queryCheckTodo, (success, response) => {
      console.log("Juego completado?: "+success);
      if (success) {
        // Hacer cambios para juego ganado       
      
        this.setState({          
          waiting: false
        });
      } else { // Si todavia no se gano el juego

        // Build Prolog query to make the move, which will look as follows:
        // put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)

        const queryS = 'put("' + this.state.mode +'", [' + i + ',' + j + ']' + ', [], [],' + squaresS + ', GrillaRes, FilaSat, ColSat)';

        this.pengine.query(queryS, (success, response) => { // Put
          if (success) {
            this.setState({ // Por ahora seteo la nueva grilla
              grid: response['GrillaRes'],
              waiting: false
            });
            
            const nGrilla = JSON.stringify(response['GrillaRes']).replaceAll('"_"', "_"); // Nueva grilla en string.
            // Check de las pistas en la fila y columna del Square clickeado.
            const queryCheckFila = 'check_pistas_fila('+i+','+ rClues +','+ nGrilla + ')';
            const queryCheckColumna = 'check_pistas_columna('+j+','+ cClues +','+ nGrilla + ')';

            // Check fila
            this.pengine.query(queryCheckFila, (success, response) => { 
              const newCheckedRowClues = this.state.checkedRowClues.slice();
              newCheckedRowClues[i] = success;
              this.setState({checkedRowClues: newCheckedRowClues});

              console.log("Checked rows: " + this.state.checkedRowClues);
            });            

            // Check columna
            this.pengine.query(queryCheckColumna, (success, response) => {
              const newCheckedColClues = this.state.checkedColClues.slice();
              newCheckedColClues[j] = success;
              this.setState({checkedColClues: newCheckedColClues});

              console.log("Checked cols: " + this.state.checkedColClues);
            });          


            this.setState({
              waiting: false
            });
          }
        });

        this.setState({          
          waiting: false
        });
        
      }

    });
  }

  numeralHC(){
    this.setState({mode: "#"});
  }

  cruzHC(){
    this.setState({mode: "X"});
  }

  switchMode() {
    if (this.props.mode === "#") {
      this.setState({mode: "X"});
    }
    else {
      this.setState({mode: "#"});
    }
  }

  render() {
    if (this.state.grid === null) {
      return null;
    }
    const statusText = 'Keep playing!';
    const modeText = 'Mode';

    return (
      
      <div className="game center">
        <p>
          <Board
            grid={this.state.grid}
            rowClues={this.state.rowClues}
            colClues={this.state.colClues}
            checkedRowClues={this.state.checkedRowClues}
            checkedColClues={this.state.checkedColClues}
            onClick={(i, j) => this.handleClick(i,j)}
          />
          
          <div className="gameInfo">
            {statusText}
          </div>
        
          <div className="modeInfo">
            {modeText}
          </div>

          <div className="modoSelect">
            <ModeSelector  
              grid = {[['X','#']]}
              mode = {this.state.mode}
              onCruzClick={() => this.cruzHC()}
              onNumeralClick={() => this.numeralHC()}
              onClick={(i, j) => this.mBhandleClick(i,j)}
            />
          </div>

        </p>
      </div>
    );
  }
}

export default Game;