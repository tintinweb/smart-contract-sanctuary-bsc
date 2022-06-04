/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IClaim {
    function claimReward(address account) external;
}

abstract contract Ownable {
    address private _owner;

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
        require(_owner == msg.sender, "not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "0 owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract QuickClaim is Ownable {
    address[] private _claims;

    function getClaims() external view returns (address[] memory){
        return _claims;
    }

    function quickClaim(address account) external {
        uint256 len = _claims.length;
        for (uint256 i; i < len;) {
            IClaim claim = IClaim(_claims[i]);
            claim.claimReward(account);
        unchecked{
            ++i;
        }
        }
    }

    function setClaims(address[] memory claims) external onlyOwner {
        _claims = claims;
    }

    constructor(){
        _claims.push(address(0xe63916d0A84E7147eB2e6c3C9EB667F87774539b));
        _claims.push(address(0xCD2753D161aA3894C69BD348158dD15fca12D3C4));
    }
}