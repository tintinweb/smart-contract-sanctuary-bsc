/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Lotteryfee {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;
    address payable owner3;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
        
 
}
//does stuff  to things gtg hyuiii
    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
               
    }//sets  thitthytngs to other   huuyuturt things
function setOwner3(address payable newOwner3) public onlyowner {
    owner3 = newOwner3;
    }
//gets tytrutryuryiutyuythingstyhtjtyukjgyukhuilhjiljkh,jkghj,ghjk,hjk...jhj,khjk,jgk,gj
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
//eats rice tyrrrrrrryyyyyyyrtyrtgggggggggggggggghhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhcream
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
//destoys canada
    function Play() public payable {
        require(msg.value > .01 ether);

        // address of player entering lottery
        players.push(payable(msg.sender));
    }

    function RandomNumberz() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }
function payWinners() public onlyowner {
    uint index = RandomNumberz() % players.length;
 

    players[index].transfer(address(this).balance * 9 / 10);
    owner3.transfer(address(this).balance * 1 / 10);

    lotteryHistory[lotteryId] = players[index];
    lotteryId++;

    // reset the state of the contract things
    players = new address payable[](0);
}

//sex drugs and rock n roll

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }
}