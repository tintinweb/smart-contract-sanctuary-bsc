/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

pragma solidity ^0.8.0;

contract Lottery{
    //manager is in charge of the contract 
    address public manager;
    //new player in the contract using array[] to unlimit number 
    address[] public players;


    constructor() { 
      manager = msg.sender;
    }


    function setManager(address _address) public restricted{
        manager = _address; 
    }


    //to call the enter function we add them to players
    function enter() public payable{
        //each player is compelled to add a certain ETH to join
        require(msg.value >= 100000000000000000);
        players.push(msg.sender);
    }
    //creates a random hash that will become our winner
    function random() private view returns(uint){
        return  uint (keccak256(abi.encode(block.timestamp,  players)));
    }
    function pickWinner() public restricted{
        //only the manager can pickWinner
        //require(msg.sender == manager);
        //creates index that is gotten from func random % play.len
        uint index = random() % players.length;
        //pays the winner picked randomely(not fully random)
        uint prizee = ((address(this).balance) / 5) * 4;
        uint fees = (address(this).balance) / 5;
        payable (players[index]).transfer(prizee);
        payable (manager).transfer(fees);
        //empies the old lottery and starts new one
        players = new address[](0);
    }

    modifier restricted(){
        require(msg.sender == manager);
        _;

    }
    function counter(address add) public view returns(uint){
        uint x=0;
        for (uint i = 0; i < players.length; i++) {
            if(players[i]==add){
                x++;
            }
        }
        return  uint(x);
    }

    function prize() public view returns(uint){
        return uint(address(this).balance);
    }

}