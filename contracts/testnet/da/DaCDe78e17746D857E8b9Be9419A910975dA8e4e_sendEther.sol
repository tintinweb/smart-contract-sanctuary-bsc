/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
// pragma solidity 0.8.14;



// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract sendEther{

    mapping (address => uint256) private _balances;

    constructor() payable{}
    receive() external payable{}


    function sendViaTransfer(address payable _to, uint256 amount) external payable{
        
        // address sender = msg.sender;

        // _balances[sender] -=amount;
        _balances[_to] +=amount;


    }
}

contract receiveEth{
    event Log(uint amount, uint gas);

    receive() external payable{
    emit Log(msg.value, gasleft());

    }



}