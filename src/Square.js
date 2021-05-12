import React from 'react';

class Square extends React.Component {
    render() {

        const value = this.props.value;
        var cell_state = "";
        if (value === "#") {
            cell_state = " painted";
        }
        else if (value === "X") {
            cell_state = " crossed";
        }

        return (
            <button className={"square" + cell_state} 
                onClick={this.props.onClick}>
                {value !== '_' ? value : null}
            </button>
        );
    }
}

export default Square;