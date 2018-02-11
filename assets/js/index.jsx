import React from 'react';
import ReactDOM from 'react-dom';
import { Button, Form, Input, Label } from 'reactstrap';

export default function run_index(root) {
  ReactDOM.render(<Index />, root);
}

class Index extends React.Component {
  constructor(props) {
    super(props);

    this.state = { gamename: null }
    this.handleInput = this.handleInput.bind(this);
  }

  handleInput(i) {
    this.setState({
      gamename: i.target.value,
    });
  }

  render() {
    let url = '/';
    if (this.state.gamename) {
      url = '/games/' + this.state.gamename;
    }

    return (
      <Form>
        <Label>Give your game a name:</Label>
        <Input onChange={this.handleInput} placeholder={'Type a name'} />
        <br></br>
        <Button color='primary' href={url}>Join the Game</Button>
      </Form>
    );
  }
}
