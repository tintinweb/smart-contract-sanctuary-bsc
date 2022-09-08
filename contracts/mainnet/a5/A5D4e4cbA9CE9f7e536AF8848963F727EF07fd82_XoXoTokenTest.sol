/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// File: contracts/xoxointerface.sol

//SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface XoXoInterface {
    function getUserPoolData(address _user, uint16 _pool) external view returns (
        uint lastAction,
        uint slotLimit,
        uint earnAmount,
        uint loseAmount,
        uint earnByRef,
        uint[] memory slots
    );
    function addressToId(address _user) external view returns (uint id);
}
interface XoXoSatInterface {
    function getUserPoolData(address _user, uint _pool) external view returns (
        uint lastAction,
        uint slotLimit,
        uint earnAmount,
        uint loseAmount,
        uint earnByRef,
        uint[] memory slots
    );
}

contract XoXoTokenTest {
    address public constant XoXo = 0xbC8Fc04F00bB369A641f8324c141475F5AE56D72;
    address public constant XoXoPools = 0x27B790311298297D3B6F5CD528a2E36760f3D145;
    XoXoInterface XoXoContract = XoXoInterface(XoXo);
    XoXoSatInterface XoXoSatPools = XoXoSatInterface(XoXoPools);
    mapping(address => uint256) public airdropClaimed;

    function checkClaimAirdropAmount(address _user) external view returns(uint256 amount) {
        if (airdropClaimed[_user] > 0) return(0);
        uint _id = XoXoContract.addressToId(_user);
        (,,,,,uint[] memory _slotsPool2) = XoXoContract.getUserPoolData(_user, 2);
        (,,,,,uint[] memory _slotsPool3) = XoXoSatPools.getUserPoolData(_user, 1);
        (,,,,,uint[] memory _slotsPool4) = XoXoSatPools.getUserPoolData(_user, 2);
        uint256 allowedToClaim = 0;
        if (_id > 0) allowedToClaim += 5;
        if (_slotsPool2.length > 0) allowedToClaim += 10;
        if (_slotsPool3.length > 0) allowedToClaim += 100;
        if (_slotsPool4.length > 0) allowedToClaim += 600;
        allowedToClaim = allowedToClaim * 10 ** 18;
        return(allowedToClaim);
    }
}