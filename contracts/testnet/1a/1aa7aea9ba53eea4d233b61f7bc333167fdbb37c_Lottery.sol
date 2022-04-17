/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: GPL-3.0
// @FernandoArielRodriguez
pragma solidity ^0.8.11;

contract Lottery {
    address public owner;
    //list of players with payable modifier
    address payable[] public players;
    // lotteryID
    uint lotteryID;
    mapping(uint => address payable) public lotteryHistory; 
    
    constructor(){
        owner = msg.sender;
        lotteryID = 1;
    }

    // returns the balance
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    // returns the actual lotteryID
    function getLotteryId() public view returns(uint) {
        return lotteryID;
    }

    // function that return the players
    function getPlayers() public view returns(address payable[] memory) {
        return players;
    }

    // enter Lottery Function
    function enter() public payable {
        // require to inforce a restriction, ether does mean that the unit is Ether
        require(msg.value >= .01 ether,"Dont have enough Ether");
        // take the caller address and push into the players array
        players.push(payable(msg.sender));
    }

    // Function that returns a random number, based on keccak256 hash algorithm
    // the keccak256 only accepts one parameter, so in order to use it we concatenate 
    // the address of the owner with the blockTimestamp with abi.encodePack
    function getRandomNumber() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }
    // function for pick a winner
    function pickWinner() public onlyowner {
        // we generate a rmostly random number
        uint index = getRandomNumber() % players.length;
        // transfer balance to the winner
        players[index].transfer(address(this).balance);

        // keeps a history of winners
        lotteryHistory[lotteryID] = players[index];

        // PROTECTION OF REENTRANCY ATTACK
        lotteryID ++;

        // reset the state of the contract
        players = new address payable[](0);
    }

    function getWinnerByLottery(uint lottery) public view returns(address payable){
        return lotteryHistory[lottery];
    }

}