/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT AND GPL-3.0

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _manager;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _manager = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            _owner == _msgSender() || _manager == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Test is Ownable {
    uint256 private depositUsdt;
    address private depositAddress;

    function setDepositAddress(address _depositAddress) public onlyOwner {
        depositAddress = _depositAddress;
    }

    function setDepositUsdt(uint256 _depositUsdt) public onlyOwner {
        depositUsdt = _depositUsdt;
    }

    function getDepositUsdt() public view returns(uint256) {
        return depositUsdt;
    }

    function getDepositAddress() public onlyOwner view returns(address) {
        return depositAddress;
    }
}