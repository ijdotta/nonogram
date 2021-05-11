import React from 'react';
import ModeBox from './ModeBox';

class ModeSelector extends React.Component {
    render() {
        const numOfRows = 1;
        const numOfCols = 2;
        console.log(this.props);
        console.log("Mode: " + this.props.mode);
        return (
            <div className="modeSelector">

                <div>
                    <ModeBox
                        value={"X"}
                        selected={(this.props.mode === "X")}
                        onClick={() => this.props.onCruzClick()}
                        key={'mCruz'}
                    />
                </div>

                <div>
                    <ModeBox
                        value={"#"}
                        selected={(this.props.mode === "#")}
                        onClick={() => this.props.onNumeralClick()}
                        key={'mNumeral'}
                    />
                </div>
            </div>
        );
    }
}

export default ModeSelector;