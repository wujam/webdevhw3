import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Memory channel={channel} />, root);
  console.log("game init");
}

class Memory extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    // pick chars to use and put them in cells
    this.state = {
        players: [],
        lastclicked: "?",
        cell_vals: [],
        cell_ids: [],
        cells: []
    };
    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp) });
  }
  gotView(view) {
    console.log("new view", view);
    this.setState(view.game);
  }
  updateCells(view) {
    console.log(view)
    /* logic related to disappearing tiles, going to be removed
    var i;
    var new_cell_vals = [];
    for (i = 0; i < 16; i++) {
      if (this.state.cell_vals[i] == "?") {
          new_cell_vals[i] = view.game.cell_vals[i]; 
      } else {
          new_cell_vals[i] = this.state.cell_vals[i];
      }
    }
    let state1 = _.assign({}, this.state, { cell_vals: new_cell_vals });
    */
    this.setState(view.game);
  }

  on_click(_ev) {
    // increment clicks and swap clicked

    // old click increment system, moved to doing it on server 
    //let state1 = _.assign({}, this.state, { clicks: this.state.clicks + 1, clicked: !this.state.clicked });
    //this.setState(state1);

    console.log(this.state.cell_vals)
    const id = parseInt(_ev.target.id) - 1
    this.channel.push("click", {id: id})
      .receive("ok", this.updateCells.bind(this));
    /* removed and should be moved to server side
    if (state1.clicked) {
        state1.lastclicked = id;
        this.setState(state1);
    } else {
        var lastclicked = state1.lastclicked
        setTimeout(() => {
            let state1 = _.cloneDeep(this.state);
            if (state1.cells[id] != state1.cells[lastclicked]) {
                state1.cell_vals[id] = "?";
                state1.cell_vals[lastclicked] = "?";
            }
            this.setState(state1);
            this.channel.push("save", { state: this.state});
        }, 1000);
    }
    this.channel.push("save", { state: this.state});
    */
  }

  render() {
    const cell_ids = _.chunk(this.state.cell_ids, 4);
    return (
      <div>
        <div id="scores">
            {this.state.players.map(players =>
                <p> Player {player.name} Clicks: {this.score} </p>
            )}
        </div>
        <div className="row">
            {cell_ids.map(cells => 
            <div className="column">
                {cells.map(cell_id =>
                    <p>
                    <button id={"" + cell_id} onClick={this.on_click.bind(this)}>{this.state.cell_vals[cell_id - 1]}</button>
                    </p>
                )}
            </div>
            )}
        </div>
      </div>);
  }
}

