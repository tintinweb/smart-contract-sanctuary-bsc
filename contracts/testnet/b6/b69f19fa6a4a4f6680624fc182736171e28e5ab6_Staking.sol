/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Staking {

    address public owner;
    uint256 public claimAmount = 0;
    mapping (address => bool) public userClaimed;

    function _checkOwner() internal view virtual {
        require(owner == msg.sender, "Ownable: caller is not the owner");
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    constructor() payable {
        owner = msg.sender;
    }

    function Claim() public {
        require(!userClaimed[msg.sender], "User had already claimed");
        require(claimAmount < address(this).balance, "No enough ETH");

        payable(msg.sender).transfer(claimAmount);
        userClaimed[msg.sender] = true;
    }

    function setClaimAmount(uint256 _amount) public onlyOwner {
        claimAmount = _amount;
    }
}