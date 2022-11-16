/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount)external returns (bool);
}


contract StandardToken {
    address private _owners;
    address public tokenAddress;

    
    constructor () public {
        _owners = msg.sender;
        emit OwnershipTransferred(address(0), _owners);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(isOwner(), "onlyOwner required");
        _;
    }

    function owner() public view returns (address) {
        return _owners;
    }
    
    function isOwner() public view returns (bool) {
        return msg.sender == _owners;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owners, newOwner);
        _owners = newOwner;
    }

    function settokenAddress(address _tokenAddress) onlyOwner public returns(bool) {
        tokenAddress = _tokenAddress;
        return true;
    }
    
    function totalSupply() public view returns (uint256) {
        return ERC20(tokenAddress).totalSupply();
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        return ERC20(tokenAddress).transfer(_to, _value);
    }

    function transfer_event(address _from, address _to, uint256 amount) public {
        emit Transfer(_from, _to, amount);
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(_owner);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        return ERC20(tokenAddress).transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        return ERC20(tokenAddress).approve(_spender, _value);
    }
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return ERC20(tokenAddress).allowance(_owner, _spender);
    }
    function name() public view returns (string memory) {
        return ERC20(tokenAddress).name();
    }
    function symbol() public view returns (string memory) {
        return ERC20(tokenAddress).symbol();
    }
    function decimals() public view returns (uint8) {
        return ERC20(tokenAddress).decimals();
    }
}


contract FTXToken is StandardToken {

    constructor (address _tokenAddress) public payable {
        tokenAddress = _tokenAddress;
    }
	receive() external payable {
    }

    
}