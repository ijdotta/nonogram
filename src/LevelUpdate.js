import React from "react";

class LevelUpdater extends React.Component {
    render() {


        return(
            <div>
                <button className="nextLevelBtn"
                    onClick={this.props.onClick}>
                    {this.props.content}
                </button>
            </div>
        );
    }
}

export default LevelUpdater;