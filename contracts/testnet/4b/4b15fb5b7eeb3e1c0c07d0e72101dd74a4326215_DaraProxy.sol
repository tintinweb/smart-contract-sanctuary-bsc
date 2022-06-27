/**
 *Submitted for verification at BscScan.com on 2022-06-26
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
    address public feeReceiver;

    mapping (address => bool) public blacklisted;
    mapping (address => uint256) public credits;

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

    function buyCredits(uint256 amount) external returns (bool){
        require(!blacklisted[msg.sender], "blacklisted");
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(feeReceiver), amount);
        credits[address(msg.sender)] = amount;
        return true;
    }

    function signature(string calldata blob) external returns (bool){
        require(!blacklisted[msg.sender], "blacklisted");
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(feeReceiver), signingFee);
        return true;
    }

    function pin() external returns (bool){
        require(!blacklisted[msg.sender], "blacklisted");
        IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468).transferFrom(address(msg.sender), address(feeReceiver), pinningFee);
        return true;
    }
}