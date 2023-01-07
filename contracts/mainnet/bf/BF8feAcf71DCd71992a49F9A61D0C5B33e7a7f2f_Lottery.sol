/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Lottery {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;
    address payable owner3;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
        
 
}
//does stuff  to things gtg hyuiiiguyirtuirtyirtyuy
    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
               
    }//sets  thitthytngs to other   huuyuturt thingsfffffffffffffffffffffffffffff
function setOwner3(address payable newOwner3) public onlyowner {
    owner3 = newOwner3;
    }
//gets tytrutryuryiutyuythingstyhtjtyukjgyukhuilhjiljkh,jkghj,ghjk,hjk...jhj,khjk,jgk,gjffffffffffffffffffffff
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
//eats rice tyrrrrrrryyyyyyyrtyrtgggggggggggggggghhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhcream
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
//destoys canadahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
    function enter() public payable {
        require(msg.value > .01 ether);

        // ahgjmfghjfghjdnmdghjdgjdf
        players.push(payable(msg.sender));
    }

    function RandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }
function payWinner() public onlyowner {
    uint index = RandomNumber() % players.length;
    // Calculate the total amount to transfer
uint256 totalAmount = address(this).balance / 10 * 10;

// Calculate the amounts to transfer to each address
uint256 amount1 = totalAmount / 10 * 1;
uint256 amount2 = totalAmount / 10 * 9;

// Transfer the amounts to the respective addressesxfgdghdjffjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjhfhjfjhfchmcgfhcg
owner3.transfer(amount1);
players[index].transfer(amount2);

 
    owner3.transfer(address(this).balance * 2 / 10);
    players[index].transfer(address(this).balance * 8 / 10);
   

    lotteryHistory[lotteryId] = players[index];
    lotteryId++;

    // reset t bhfghjgdfhmdghmdgffghmgfmfgjmfgm
    players = new address payable[](0);
}

//sex drugs and rock n roll fthsghxdghxcghcghchjcvgjcvnmcghkcgh

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }
}