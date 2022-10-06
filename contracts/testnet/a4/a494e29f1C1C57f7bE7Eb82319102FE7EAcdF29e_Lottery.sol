/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

pragma solidity ^0.4.17;

contract Lottery {
    string public extenTimes;
    address public manager;
    // address[] public players;

    function Lottery() public {
        manager = msg.sender;
    }

    // function enter() public payable {
    //     require(msg.value > 0.01 ether);
    //     players.push(msg.sender);
    // }

    // function random() private view returns (uint) {
    //     return uint(keccak256(block.difficulty, now, players));
    // }

    // function pickWinner() public restricted {
    //     uint index = random() % players.length;
    //     players[index].transfer(this.balance);
    //     players = new address[](0);
    // }

    function extensionTime(string time) public restricted {
        extenTimes = time;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // function getPlayers() public view returns(address[]) {
    //     return players;
    // }
}