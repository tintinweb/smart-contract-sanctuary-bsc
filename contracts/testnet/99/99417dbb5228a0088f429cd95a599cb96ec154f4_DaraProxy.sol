/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

// ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
// ██░▄▄▀█░▄▄▀██░▄▄▀█░▄▄▀██
// ██░██░█░▀▀░██░▀▀▄█░▀▀░██
// ██░▀▀░█░██░██░██░█░██░██
// ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

pragma solidity ^0.8.7;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Ownable {    
  address private _owner;
  
  constructor(){
    _owner = msg.sender;
  }
  
  function owner() public view returns(address){
    return _owner;
  }
  
  modifier onlyOwner(){
    require(isOwner(),
    "Function accessible only by the owner !!");
    _;
  }
  
  function isOwner() public view returns(bool){
    return msg.sender == _owner;
  }
}

contract DaraProxy is Ownable {
    IERC20 daraToken;
    address public feeWallet;
    address public token;
    event Signature(string signature);
    
    constructor(){
        daraToken = IERC20(token);
        feeWallet = 0xb08021A2A051F6d8AC3b0152D6157903B19acB49;
        token = 0xB9209b547fd051D9b9717dA386f2eD6113561468;
    }
    
    function setFeeWallet(address newWallet) external onlyOwner{
        feeWallet = newWallet;
    }

    function setToken(address newToken) external onlyOwner{
        token = newToken;
    }

    function signature(string memory data, uint256 fee) external returns (bool){
        daraToken.transferFrom(address(msg.sender), feeWallet, fee);
        emit Signature(data);
        return true;
    }
}