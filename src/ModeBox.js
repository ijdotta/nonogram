import React from 'react';

class ModeBox extends React.Component {
    render() {

        const selected = this.props.selected;
        const value = this.props.value;

        const type = value === "#"? "paint" : "cross";

        return (
        
            <button className={"modeBox" + (selected? " selected" : "") + " " + type}
                onClick={this.props.onClick}>
                {value}
            </button>
        );
    }
}

export default ModeBox;