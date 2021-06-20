import React from 'react';

class ModeBox extends React.Component {
    render() {

        const selected = this.props.selected;
        const value = this.props.value;
        var type, icon;

        if (value === "#") {
            type = "paint";
            icon = "⬛";
        }
        else {
            type = "cross";
            icon = "❌";
        }

        return (
        
            <button className={"modeBox" + (selected? " selected" : "") + " " + type}
                onClick={this.props.onClick}>
                {icon}
            </button>
        );
    }
}

export default ModeBox;