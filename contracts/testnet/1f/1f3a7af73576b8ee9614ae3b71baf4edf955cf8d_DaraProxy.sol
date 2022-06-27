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

// Main coin information
contract DaraProxy is Ownable {
    uint256 public signFee = 10*10**18;
    uint256 public pinFee = 10*10**18;
    address public feeReceiver = 0xb08021A2A051F6d8AC3b0152D6157903B19acB49;
    mapping (address => bool) public blacklisted;

    constructor() {
    }
    
    function setBlacklistAccount(address account, bool state) external onlyOwner{
        require(blacklisted[account] != state, "Value already set");
        blacklisted[account] = state;
    }

    function setPinFee(uint256 newFee) external onlyOwner{
        pinFee = newFee;
    }

    function setSignFee(uint256 newFee) external onlyOwner{
        signFee = newFee;
    }

    function setFeeReceiver(address newFeeReceiver) external onlyOwner{
        feeReceiver = newFeeReceiver;
    }

    function signature(string calldata blob) external returns (bool) {
        require(!blacklisted[msg.sender], "blacklisted");
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(feeReceiver), signFee);
        return true;
    }

    function pin() external returns (bool) {
        require(!blacklisted[msg.sender], "blacklisted");
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(feeReceiver), pinFee);
        return true;
    }
}