/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20{
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
    uint256 public signingFee;
    uint256 public pinningFee;
    address public tokenAddress;
    address public feeReceiver;

    mapping (address => bool) public blacklisted;

    constructor() {
    }
    
    function setBlacklisted(address account, bool state) external onlyOwner{
        require(blacklisted[account] != state, "Value already set");
        blacklisted[account] = state;
    }

    function setPinningFee(uint256 newFee) external onlyOwner{
        pinningFee = newFee;
    }

    function setSigningFee(uint256 newFee) external onlyOwner{
        signingFee = newFee;
    }

    function setFeeReceiver(address newFeeReceiver) external onlyOwner{
        feeReceiver = newFeeReceiver;
    }

    function setTokenAddress(address newTokenAddress) external onlyOwner{
        tokenAddress = newTokenAddress;
    }

    function signBlob(string memory blob) external returns (bool){
        require(!blacklisted[msg.sender], "blacklisted");
        IERC20(tokenAddress).transferFrom(address(msg.sender), address(feeReceiver), signingFee);
        return true;
    }

    function pinUpload() external returns (bool){
        require(!blacklisted[msg.sender], "blacklisted");
        IERC20(tokenAddress).transferFrom(address(msg.sender), address(feeReceiver), pinningFee);
        return true;
    }
}