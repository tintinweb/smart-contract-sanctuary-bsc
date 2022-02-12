/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.4.17;

contract Lottery 
{
    address public manager;
    address [] public players ;
    address public winner ;


    function Lottery() public 
    {
        manager = msg.sender;
        winner =0x0000;
    }

    function enter() public payable
    {
        require(msg.value >= 0.01 ether);
        players.push(msg.sender);

    }

    function numberPlayer() public view returns(uint)
    {
        return players.length;
    }

    function random() private view returns(uint)
    {
        return uint(keccak256(block.difficulty,now , players));
    }

    function pickWinner() public onlyManagerCanCall{
        uint result =  random() % players.length;
        winner = players[result];
        winner.transfer(this.balance);
        players = new address[](0);
    }


    function getPlayers() public onlyManagerCanCall view returns(address[]) 
    {
        return players;
    }
    modifier onlyManagerCanCall ()
    {
        require(msg.sender == manager);
        _;
    }


}