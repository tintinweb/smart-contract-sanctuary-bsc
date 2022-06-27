/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

// Current Version of solidity
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

contract Ownable 
{    
  // Variable that maintains 
  // owner address
  address private _owner;
  
  // Sets the original owner of 
  // contract when it is deployed
  constructor()
  {
    _owner = msg.sender;
  }
  
  // Publicly exposes who is the
  // owner of this contract
  function owner() public view returns(address) 
  {
    return _owner;
  }
  
  // onlyOwner modifier that validates only 
  // if caller of function is contract owner, 
  // otherwise not
  modifier onlyOwner() 
  {
    require(isOwner(),
    "Function accessible only by the owner !!");
    _;
  }
  
  // function for owners to verify their ownership. 
  // Returns true for owners otherwise false
  function isOwner() public view returns(bool) 
  {
    return msg.sender == _owner;
  }
}

// Main coin information
contract DaraProxy is Ownable {
    IERC20 daraToken;

    address public feeWallet;// = 0xb08021A2A051F6d8AC3b0152D6157903B19acB49; 
    address public token;// = 0xB9209b547fd051D9b9717dA386f2eD6113561468;
    uint256 public signingFee;// = 0xB9209b547fd051D9b9717dA386f2eD6113561468;
    // Transfers
    event Signature(string signature);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
        daraToken = IERC20(token);
        feeWallet = 0xb08021A2A051F6d8AC3b0152D6157903B19acB49;
        token = 0xB9209b547fd051D9b9717dA386f2eD6113561468;
        signingFee = 10*10**18;
    }
    
    function setFeeWallet(address newWallet) external onlyOwner{
        feeWallet = newWallet;
    }

    function setToken(address newToken) external onlyOwner{
        token = newToken;
    }

    function signature(string memory data) external returns (bool) {
        daraToken.transferFrom(address(msg.sender), feeWallet, signingFee);
        emit Signature(data);
        return true;
    }
}