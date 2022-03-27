/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: AGPL-3.0-or-later



pragma solidity ^0.8.0;
pragma abicoder v2;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IBlackSupport {
    function referee(address _teamLeaderAddress) external;
}


// BlackHole Referral And Donate Function
contract InviteDetail {
    uint public  recordId;

    struct TeamLeader {
        uint referredNumber;
        string name;
        // save png(base64 encoded) string here
        string logo;
    }

    // Donate Record related
    struct DonateRecord {
        uint id;
        address donorAddress;
        uint donorType; // 1 teamleader 2 person 3 institute
        uint starTime;
        uint endTime;
        uint donateBUSDAmount;
        uint claimableBUSDAmount;
        uint claimableBHOAmount;
        uint claimedBUSD;
        uint claimedBHO;
        uint claimedBHOValue;
        uint currentIndex;
    }

    address public supportAddress;

    // for ranking
    mapping(address => address[]) public addressOfTeam;

    // refer related
    struct User {
        bool referred;
        address teamLeaderAddress;
    }

    address public usdtAddress;

    constructor(address _supportAddress) {
        supportAddress = _supportAddress;
    }

    function referee(address _teamLeaderAddress) public {
        IBlackSupport support = IBlackSupport(supportAddress);
        support.referee(_teamLeaderAddress);
        addressOfTeam[_teamLeaderAddress].push(msg.sender);
    }
}