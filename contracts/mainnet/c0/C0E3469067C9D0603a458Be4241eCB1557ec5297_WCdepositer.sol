/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

interface IWhalesCandy {
    function buyShareFromAuction () external payable returns (bool);
}

interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

contract WCdepositer {

    address payable public dev = payable (0x9a27Da147a89871171c06b98944cB4AE6d5Eca43);
    address public WCcontract = 0x05214b6D7Fa41eA946023734829b18CC15231d28;
    IWhalesCandy WC;
    

    constructor () {
       WC = IWhalesCandy(WCcontract); 
    }

    // to make the contract being able to receive ETH
    receive() external payable {}

    // function to call the auction entry function in WCcontract
    // to enter the auction with either the msg.value or the contracts ETH balance
    function deposit () public payable {
        uint256 rawAmount = 0;

        if(msg.value != 0) {
           rawAmount = msg.value; 
        } else {
           rawAmount = address(this).balance;
        }
        
        WC.buyShareFromAuction{value: rawAmount}();
    }

    // function for DEV to set the WCcontract address
    function setWCcontract (address newWCcontract) public {
        require (msg.sender == dev, "you are not the DEV!");
        WCcontract = newWCcontract;
    }

    // function for DEV to receive all ETH from thiscontract
    function getFunds () public {
        require (msg.sender == dev, "you are not the DEV!");
        uint256 balance = address(this).balance;
        dev.transfer(balance);
    }

    // function for DEV to receive all balance of any token from this contract
    function getAnyToken (address Token) public {
        require (msg.sender == dev, "you are not the DEV!");
        uint256 balanceToken = IERC20(Token).balanceOf(address(this));
        IERC20(Token).transfer(dev, balanceToken);
    }

}