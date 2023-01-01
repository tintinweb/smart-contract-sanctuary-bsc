/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

pragma solidity 0.5.1;

contract MyContract {
    enum State { Waiting, Ready, Active }
    State public state;
    address payable  wallet;
    uint256 smartAmount;

    constructor(address payable _wallet) public payable {
        state = State.Waiting;
        wallet = _wallet;
    }

    function activate() public {
        state = State.Active;
    }

    function isActive() public view returns(bool) {
        return state == State.Active;
    }

    function sendValue() public payable returns(uint256) {
        smartAmount = msg.value;
        wallet.transfer(msg.value);
        return smartAmount;
    }

    function getValue() public view returns(uint256)  {
        return smartAmount;
    }
}