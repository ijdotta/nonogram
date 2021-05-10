import React from 'react';

class ModeSwitch extends React.Component {
    render() {
        return(
            <label class="switch">
                <input type="checkbox"/>
                <span class="slider round"></span>
            </label>
        );
    }
}

export default ModeSwitch;