import React from 'react';
import Square from './Square';
import ModeBox from './ModeBox';

class ModeSelector extends React.Component {
    render() {
        const numOfRows = 1;
        const numOfCols = 2;
        console.log(this.props);
        return (
            <div className="modeSelector" 
                 style={{
                    gridTemplateRows: 'repeat(' + numOfRows + ', 40px)',
                    gridTemplateColumns: 'repeat(' + numOfCols + ', 40px)'
                 }}>

                    <ModeBox
                        value={"X"}
                        onClick={() => this.props.onCruzClick()}
                        key={'mCruz'}
                        />

                        <ModeBox
                        value={"#"}
                        onClick={() => this.props.onNumeralClick()}
                        key={'mNumeral'}
                        />
            </div>
        );
    }
}

export default ModeSelector;