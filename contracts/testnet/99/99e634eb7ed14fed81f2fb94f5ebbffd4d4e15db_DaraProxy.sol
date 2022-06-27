/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

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

contract DaraProxy is Ownable {
    uint256 public signFee = 10*10**18;
    uint256 public pinFee = 10*10**18;

    event Signature(string blob);
    event Pin();
    
    constructor() {
    }
    
    function setPinFee(uint256 newFee) external onlyOwner{
        pinFee = newFee;
    }

    function setSignFee(uint256 newFee) external onlyOwner{
        signFee = newFee;
    }

    function signature(string memory blob) external returns (bool) {
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(this), signFee);
        emit Signature(blob);
        return true;
    }

    function pin() external returns (bool) {
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(this), pinFee);
        emit Pin();
        return true;
    }
}