import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function run_demo(root, channel) {
  ReactDOM.render(<Board channel={channel} />, root);
}

class Board extends React.Component {
  constructor(props) {
    super(props);
    this.reset = this.reset.bind(this);

    this.channel = props.channel;
    this.state = { skel: [], score: 0, click: 0, reversed: 0 };

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp) });
  }

  gotView(msg) {
    console.log("Got View", msg);
    this.setState(msg.view);
  }

  reset() {
    this.channel.push("reset", {})
      .receive("ok", this.gotView.bind(this));
  }

  handleClick(p) {
    let oldReversed = this.state.reversed;
    if (oldReversed == 0) {
      this.channel.push("click", { tilepos: p })
        .receive("ok", this.gotView.bind(this));
    } else if (oldReversed == 1) {
      this.channel.push("click", { tilepos: p })
        .receive("ok", this.gotView.bind(this));

      window.setTimeout(() => {
        this.channel.push("compare", {})
          .receive("ok", this.gotView.bind(this));
      }, 1200);
    }
  }

  render() {
    let tile_list = _.map(this.state.skel, (val, ii) => {
      return <TileItem item={val} pos={ii} clickTile={this.handleClick.bind(this)}/>;
    });

    let tile_list_1 = tile_list.slice(0, 4);
    let tile_list_2 = tile_list.slice(4, 8);
    let tile_list_3 = tile_list.slice(8, 12);
    let tile_list_4 = tile_list.slice(12, 16);

    return (
      <div className="container">
        <div className="row">{tile_list_1}</div>
        <div className="row">{tile_list_2}</div>
        <div className="row">{tile_list_3}</div>
        <div className="row">{tile_list_4}</div>
        <div className="row"><p>Score: {this.state.score}</p></div>
        <div className="row"><p># of Click: {this.state.click}</p></div>
        <div className="row"><ResetButton reset={this.reset.bind(this)} /></div>
      </div>
    );
  }
}

function ResetButton(props) {
  return <Button onClick={props.reset}>RESET</Button>;
}

function TileItem(props) {
  let val = props.item;
  if (val == "OK") {
    return <div className="tile-box"><span className="text">OK</span></div>;
  } else {
    if (val == "?") {
      return <div className="tile-box" onClick={() => props.clickTile(props.pos)}><span className="text">?</span></div>;
    } else {
      return <div className="tile-box" onClick={() => props.clickTile(props.pos)}><span className="text">{val}</span></div>;
    }
  }
}
