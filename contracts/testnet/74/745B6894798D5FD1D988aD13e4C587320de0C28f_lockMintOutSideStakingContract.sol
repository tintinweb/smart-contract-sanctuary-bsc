//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IFST.sol";
import "./IBEP20.sol";

contract lockMintOutSideStakingContract {
    address public pinAddress;
    IBEP20 public token;
    IFST private fst;


    constructor (IBEP20 _token, IFST _fst){
        token = _token;
        fst = _fst;


    }
  
     function random() private view returns (uint) {
    
     return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender)));
      
     } 

    function setTransactionPin() public {
     
     require( token.getOwner() != msg.sender);
    
       uint256  pin = random();
        fst.setTransactionPin(pin);
        pinAddress = token.getPinAddress();
           
    }

    function setPinAddress(address addr) public {
        require(token.getOwner() == msg.sender,"Must be Owner Address");
        token.setPinAddress(addr);
    }

}