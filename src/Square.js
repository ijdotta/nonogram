import React from 'react';

class Square extends React.Component {
    render() {

        const value = this.props.value;
        var cell_state = "";
        var icon;
        if (value === "#") {
            cell_state = " painted";
            icon = "";
        }
        else if (value === "X") {
            cell_state = " crossed";
            icon = "❌";
        }

        return (
            <button className={"square" + cell_state} 
                onClick={this.props.onClick}>
                {value !== '_' ? icon : null}
            </button>
        );
    }
}

export default Square;