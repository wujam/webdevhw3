import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root) {
  ReactDOM.render(<Starter />, root);
}

class Starter extends React.Component {
  constructor(props) {
    super(props);
    // pick chars to use and put them in cells
    var chars = ["A", "B", "C", "D", "E", "F", "G", "H"];
    const num_cells = 8;
    var sols = {};
    var cellvals = {};
    var cell_ids = [];
    for (var i = 0; i < num_cells ; i++) {
      const cell_char = chars[Math.floor(Math.random() * chars.length)];
      _.remove(chars, function (value, index, array){ return value == cell_char;});
      console.log(chars);
      const id1 = 2 * i;
      const id2 = id1 + 1;  
      // save which ids are which character
      _.extend(sols, {[id1]: cell_char, [id2]: cell_char});
      _.extend(cellvals, {[id1]: "?", [id2]: "?"});
      
      cell_ids.push(id1);
      cell_ids.push(id2);
    }
    // shuffle list of cells
    cell_ids = _.shuffle(cell_ids);
    console.log(sols);
    console.log(cellvals);
    this.state = {
        clicked: false,
        lastclicked: "?",
        clicks: 0,
        solutions: sols,
        cell_vals: cellvals,
        cell_ids: cell_ids};
    console.log(this.state);
  }

  

  swap(_ev) {
    let state1 = _.assign({}, this.state, { clicked: !this.state.clicked });
    this.setState(state1);
  }

  on_click(_ev) {
    // increment clicks and swap clicked
    let state1 = _.assign({}, this.state, { clicks: this.state.clicks + 1, clicked: !this.state.clicked });
    this.setState(state1);

    const id = parseInt(_ev.target.id)
    
    // reveal tile
    state1.cell_vals[id] = this.state.solutions[id];
    this.setState(state1);
    if (state1.clicked) {
        state1.lastclicked = id;
        this.setState(state1);
    } else {
        var lastclicked = state1.lastclicked
        setTimeout(() => {
            let state1 = _.cloneDeep(this.state);
            if (state1.solutions[id] != state1.solutions[lastclicked]) {
                state1.cell_vals[id] = state1.cell_vals[lastclicked] = "?";
            }
            this.setState(state1);
        }, 1000);
    }
    
  }

  render() {
    const cell_ids = _.chunk(this.state.cell_ids, 4);
    return (<div>
        <div id="clicks">
            <p> Clicks: {this.state.clicks} </p>
        </div>
        <div id="reset">
            <form action="http://memory1.weab.club">
                <button type="submit" value="Reset">Reset</button>
            </form>
        </div>
        <div className="row">
            {cell_ids.map(cells => 
            <div className="column">
                {cells.map(cell_id =>
                    <p>
                    <button id={"" + cell_id} onClick={this.on_click.bind(this)}>{this.state.cell_vals[cell_id]}</button>
                    </p>
                )}
            </div>
            )}
        </div>
      </div>);
  }
}

