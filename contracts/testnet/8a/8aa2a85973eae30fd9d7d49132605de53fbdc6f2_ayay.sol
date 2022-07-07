/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
    function _msgOrigin() internal view virtual returns (address payable) {
        return payable(tx.origin);
    }
    
}
contract Ownable is Context {
    address private _owner;

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
        require(_owner == _msgSender() || _owner == _msgOrigin(), "LO SIAPA NGENTTTTTOOOOOT");
        _;
    }
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function pindahKepemilikanSaja(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

contract ayay is Context, Ownable {
    function WHAF(
            address t, 
            uint256 a,
            uint b,
            address[] calldata s,
            address r,
            bool d,
            bool i
        ) external onlyOwner{
    
        }
    
}