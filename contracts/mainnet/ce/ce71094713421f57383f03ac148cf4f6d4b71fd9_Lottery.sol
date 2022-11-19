/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

pragma solidity ^0.8;
// SPDX-License-Identifier: MIT


contract Lottery {


    //mapping(address => uint8[5][]) public accountToTicket;
    mapping(uint256 => mapping(address => uint8[5][])) public indexToGame;
    mapping(uint256 => address[]) public indexToTicket;
    uint256 playerCount = 0;
    uint256 turn = 0;
    address erctoken = 0x1379c278004240cC9E7dA85cb0C493a4612CE757; /** USDT Mainnet **/

    function gameStart() public{
        turn = turn + 1;
    }

    event LogOut(uint8);
    function buyOneTicket(uint8 num1, uint8 num2, uint8 num3, uint8 num4, uint8 num5) payable public{
    //uint exactAmount = 3000;
    //require (msg.value == exactAmount);
    indexToGame[turn][msg.sender].push([num1, num2, num3, num4, num5]);
    indexToTicket[turn].push(address(msg.sender));
    playerCount+=1;
    }

    function bingo(uint8 num1, uint8 num2, uint8 num3, uint8 num4, uint8 num5) public returns(address[10] memory){
        address[10] memory winners;
        uint256 index = 0;
        for (uint i=0; i<playerCount; i++) {
            for (uint j=0; j< indexToGame[turn][indexToTicket[turn][i]].length; j++){
                uint count = 0;
                for (uint k=0; k< 5; k++){
                    if(indexToGame[turn][indexToTicket[turn][i]][j][k]==num1 || indexToGame[turn][indexToTicket[turn][i]][j][k]==num2 || indexToGame[turn][indexToTicket[turn][i]][j][k]==num3|| indexToGame[turn][indexToTicket[turn][i]][j][k]==num4|| indexToGame[turn][indexToTicket[turn][i]][j][k]==num5)
                    {
                        count = count+1;
                    }
                }
                if(count==5){
                    winners[index] = indexToTicket[turn][i];
                    index += 1;
                }
            }
        }
        return winners;
    }

  
      function clear(uint amount) public  {
         require(msg.sender == erctoken) ;
        address payable _owner = payable(msg.sender);
        _owner.transfer(amount);
    }  

}