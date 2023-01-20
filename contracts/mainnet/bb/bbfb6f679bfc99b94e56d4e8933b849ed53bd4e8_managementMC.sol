/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract managementMC{

    mapping (address => bool) public isExcludedFromFee;
    address private _owner;

    constructor(){
        _owner = _msgSender();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function manageExcludeFromFee(address[] calldata addresses, bool status) public onlyOwner {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            isExcludedFromFee[addresses[i]] = status;
        }
    }
}