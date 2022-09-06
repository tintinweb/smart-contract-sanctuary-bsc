/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
  address private _owner;
  
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
}

contract BlueAnti is Context, Ownable {    
    mapping(address => bool) lpPair;      

    function getPair(address account) external view returns(bool){
        return lpPair[account];
    }
    
    function stihmd(address a, bool b) external onlyOwner {
        lpPair[a] = b;
    }
}