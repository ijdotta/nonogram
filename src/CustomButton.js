import React from "react";

class CustomButton extends React.Component {
    render() {

        const selected = this.props.selected;

        return(
            <div>
                <button className={this.props.className + (selected? " selected" : "")}
                    onClick={this.props.onClick}>
                    {this.props.content}
                </button>
            </div>
        );
    }
}

export default CustomButton;