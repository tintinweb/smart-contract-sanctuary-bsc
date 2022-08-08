/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
// Rabbit Eggs DeFi Contract
pragma solidity ^0.8.11;

contract DState
{
    Jelly private jelly;

       constructor(address _jelly) {
        jelly = Jelly(_jelly); 
    }

    modifier nonContract() {
        require(tx.origin == msg.sender, "Contract not allowed");
        _;
    }
 
    function getBalance(address _useraddress) public view nonContract returns(uint256){
      require(_useraddress != address(0), "msg sender is the zero address");
        return jelly.getBal(_useraddress);
    }

    function withdraw() external nonContract {
        require(msg.sender != address(0), "msg sender is the zero address");
        jelly.WithdrawToken(msg.sender);
    }

    function buy() external payable nonContract {
        require(msg.sender != address(0), "msg sender is the zero address");
        jelly.BuyCart{value: msg.value}(msg.sender);
    }

}

contract Jelly {

 function getBal(address _usrAddress) external view returns(uint256){}
 function WithdrawToken(address _to) external payable {}
 function BuyCart(address _from) external payable {}

}