import React from 'react';

class ModeBox extends React.Component {
    render() {

        const selected = this.props.selected;
        console.log("Selected: " + selected);

        return (
        
            <button className={"modeBox" + (selected? " selected" : "")}
                onClick={this.props.onClick}>
                {this.props.value}
            </button>
        );
    }
}

export default ModeBox;