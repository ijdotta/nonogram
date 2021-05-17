import React from 'react';
import ModeBox from './ModeBox';

class ModeSelector extends React.Component {
    render() {
        return (
            <div className="modeSelector">

                <div className="leftBox">
                    <ModeBox
                        value={"X"}
                        selected={(this.props.mode === "X")}
                        onClick={() => this.props.onCruzClick()}
                        key={'mCruz'}
                    />
                </div>

                <div className="rightBox">
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