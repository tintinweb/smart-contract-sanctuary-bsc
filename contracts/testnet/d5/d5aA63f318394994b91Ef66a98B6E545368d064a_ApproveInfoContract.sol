/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;



contract ApproveInfoContract {
    struct ApproveInfo {
        string userAddress;
        address contractAddress;
        uint256 amount;
        address adminAddress;
    }
    ApproveInfo[] public ApproveInfos;


    function saveApproveInfo(string memory uA, address cA, uint256 aM, address aA ) public {
        ApproveInfos.push(ApproveInfo(uA, cA, aM, aA));
    }
}