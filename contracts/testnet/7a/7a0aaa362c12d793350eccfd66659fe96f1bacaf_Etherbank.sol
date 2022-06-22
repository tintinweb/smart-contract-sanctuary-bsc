/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
         _;
       _status = _NOT_ENTERED;
    }
}

contract Etherbank is ReentrancyGuard { 
    // using console for console.log; 
//    using Address for address payable;
  mapping(address=>uint) public  balances;

  function deposit()external payable{
      balances[msg.sender] +=msg.value;
  }
  function withdraw()external  nonReentrant { 
      require(balances[msg.sender]>0,"withdrawl amount is not enough");
    //   console.log("");
    //   console.log("victim balance",address(this).balance);
    //   console.log("Attacker  balance",balances[msg.sender]);
    //    console.log("");
    //    uint accountbalance=balances[msg.sender];
        // balances[msg.sender]=0;
    //  (bool sent,)=msg.sender.call{value:amount}("");
    //  require(sent,"failed to send Ether");
       payable(msg.sender).transfer(balances[msg.sender]);
       balances[msg.sender]=0;
      
  }
  function getbalance()public view returns(uint){
      return address(this).balance;
  }
}