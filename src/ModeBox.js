import React from 'react';

class ModeBox extends React.Component {
    render() {
        return (
            <button className="modeBox" onClick={this.props.onClick}>
                {this.props.value}
            </button>
        );
    }
}

export default ModeBox;