/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
// pragma solidity 0.8.14;



// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract sendEther{

    constructor() payable{}
    receive() external payable{}



    function sendViaTransfer(address payable _to) external payable{
        _to.transfer(100);
    }
}

contract receiveEth{
    event Log(uint amount, uint gas);

    receive() external payable{
    emit Log(msg.value, gasleft());

    }



}