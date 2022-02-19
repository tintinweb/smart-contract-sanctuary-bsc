/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

contract Bar {

    struct LockedPiggyBank {
        address userAddress;
        uint256 piggyBankID;
    }
    LockedPiggyBank[] public lockedPiggyBanks; // TODO: Implement Getter

    mapping(address => uint256[]) foo;

    function setLockPiggyBank(address _userAddress, uint256 _piggyBankID)  public {
        lockedPiggyBanks.push(LockedPiggyBank({
            userAddress: _userAddress,
            piggyBankID: _piggyBankID
        }));
    }

    function add(address addr, uint id) public {
        foo[addr].push(id);
    }

    function getAllLockedPiggyBanks() public view returns(LockedPiggyBank[] memory){
        return lockedPiggyBanks;
    }

    function get(address addr, uint256 id) public view returns(uint256){
        return foo[addr][id];
    }

    function getAll(address addr) public view returns(uint256[] memory){
        return foo[addr];
    }

    constructor() {}
}