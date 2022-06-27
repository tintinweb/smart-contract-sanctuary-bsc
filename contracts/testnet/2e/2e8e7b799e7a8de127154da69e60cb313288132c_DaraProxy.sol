/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

// Current Version of solidity
pragma solidity ^0.8.7;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Ownable{    
  address private _owner;
  
  constructor(){
    _owner = msg.sender;
  }
  
  function owner() public view returns(address){
    return _owner;
  }
  
  modifier onlyOwner(){
    require(isOwner(), "Function accessible only by the owner !!");
    _;
  }
  
  function isOwner() public view returns(bool){
    return msg.sender == _owner;
  }
}

// Main coin information
contract DaraProxy is Ownable {
    uint256 public signingFee = 10*10**18;

    event Signature(string date, string hash, string name, string size, string filetype, string url);
    
    constructor() {
    }
    
    function setSigningFee(uint256 newFee) external onlyOwner{
        signingFee = newFee;
    }

    function signature(string memory date, string memory hash, string memory name, string memory size, string memory filetype, string memory url) external returns (bool) {
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(this), signingFee);
        emit Signature(date, hash, name, size, filetype, url);
        return true;
    }
}