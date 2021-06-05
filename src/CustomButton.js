import React from "react";

class CustomButton extends React.Component {
    render() {

        return(
            <div>
                <button className={this.props.className}
                    onClick={this.props.onClick}>
                    {this.props.content}
                </button>
            </div>
        );
    }
}

export default CustomButton;