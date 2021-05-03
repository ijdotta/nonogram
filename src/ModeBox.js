import React from 'react';
import Square from './Square';

class ModeBox extends React.Component {
    render() {
        const numOfRows = 1;
        const numOfCols = 2;
        console.log(this.props);
        return (
            <div className="modeSelect" 
                 style={{
                    gridTemplateRows: 'repeat(' + numOfRows + ', 40px)',
                    gridTemplateColumns: 'repeat(' + numOfCols + ', 40px)'
                 }}>

                    <Square
                        value={"X"}
                        onClick={() => this.props.onCruzClick()}
                        key={'mCruz'}
                        />

                        <Square
                        value={"#"}
                        onClick={() => this.props.onNumeralClick()}
                        key={'mNumeral'}
                        />
            </div>
        );
    }
}

export default ModeBox;