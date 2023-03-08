/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity ^0.4.17;

// Contract address: 0x67Fca8BA86Fef99929f6a4eAD44d19d1A8115d56

contract Lottery {
    address public manager;
    address[] public players;
    address         winner;
    
    function Lottery() public {
        manager = msg.sender;
    }
    
    function enter() public payable {
        require(msg.value > .01 ether);
        players.push(msg.sender);
    }
    
    function random() private view returns (uint) {
        return uint(keccak256(block.difficulty, now, players));
    }
    
    function pickWinner() public restricted {
        uint index = random() % players.length;
        players[index].transfer(this.balance);
        winner = players[index];

        players = new address[](0);
    }
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    function getPlayers() public view returns (address[]) {
        return players;
    }

    function getWinner() public view returns(address) {
        return winner;
    }
}