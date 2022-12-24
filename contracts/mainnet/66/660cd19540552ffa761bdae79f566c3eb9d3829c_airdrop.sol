/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract airdrop is Ownable{

    constructor ()Ownable(){}
    receive() external payable {}
    function CSBs(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountPercentage / 100);
    }

    function claimToken(address token) external onlyOwner {
        ERC20(token).transfer(msg.sender, ERC20(token).balanceOf(address(this)));
    }
    /* Airdrop */
    function muil_transfer(address[] memory addresses,address token, uint256 tAmount) external onlyOwner {
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC = tAmount * addresses.length * 10 ** ERC20(token).decimals();
        require(ERC20(token).balanceOf(address(this)) >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            ERC20(token).transfer(addresses[i], tAmount * 10 ** ERC20(token).decimals());
        }
    }
    /* Airdrop */
    function muil_transfer(address[] memory addresses, uint256 tAmount) external onlyOwner {
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC = addresses.length * tAmount * 10 ** 18;
        require(address(this).balance >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            payable(addresses[i]).transfer(tAmount * 10 ** 18);
        }
    }
}