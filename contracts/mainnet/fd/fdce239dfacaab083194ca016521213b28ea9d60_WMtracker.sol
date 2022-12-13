/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

pragma solidity ^0.8.13;
// SPDX-License-Identifier: MIT

interface WM{
    function UsersKey(address _userAddress) external view returns (UserV1 memory);
}

//libraries
struct UserV1 {
    uint256 startDate;
    uint256 divs;
    uint256 refBonus;
    uint256 totalInits;
    uint256 totalWiths;
    uint256 totalAccrued;
    uint256 lastWith;
    uint256 timesCmpd;
    uint256 keyCounter;
}

contract WMtracker {
    WM public wm;

    constructor(){
        wm = WM(0x9B9C918FAC2DFCCaFff3B95b4f46FD9A5D9D701b);
    }

    function getV1UsersKey(address _userAddress) public view returns (UserV1 memory){
        return wm.UsersKey(_userAddress);
    }
}