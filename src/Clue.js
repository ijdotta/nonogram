import React from 'react';

class Clue extends React.Component {
    render() {
        const clue = this.props.clue;
        const checked = this.props.checked;
        console.log("Checked clue: " + checked);
        return (
            <div className={"clue" + (checked? " checked" : "")} >
                {clue.map((num, i) =>
                    <div key={i}>
                        {num}
                    </div>
                )}
            </div>
        );
    }
}

export default Clue;