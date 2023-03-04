/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}

contract ApeHome is Ownable {
    IBEP20 public apeToken = IBEP20(0x570f7a3DA918CB60105A68470e2b88E4dCa2c733);// PRO
    IBEP20 public usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);// PRO
    address public marketAddr = 0xba38Fc537618ef2F99EaF2b7932DE14c8f329D49;// PRO

    function rechargeUsdt(uint256 amount) public{
        usdtToken.transferFrom(address(msg.sender),marketAddr,amount);
    }

    function rechargeApe(uint256 amount) public{
        apeToken.transferFrom(address(msg.sender), marketAddr, amount);
    }
}