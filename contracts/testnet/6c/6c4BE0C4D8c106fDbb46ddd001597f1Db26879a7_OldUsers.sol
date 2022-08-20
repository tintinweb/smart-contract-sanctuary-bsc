/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;

contract OldUsers {
    struct Node {
        uint256 leftDirect;
        uint256 rightDirect;
        uint256 ALLleftDirect;
        uint256 ALLrightDirect;
        uint256 todayCountPoint;
        uint256 depth;
        uint256 childs;
        uint256 leftOrrightUpline;
        address UplineAddress;
        address leftDirectAddress;
        address rightDirectAddress;
        bool hasTodayPoint;
    }

    address[] private UserAdd;
    Node[] private UserNode;
    uint256 private UserID;

    function Initialize(address Owner)
        external
        returns (
            address[] memory,

            uint256
        )
    {
        // address[] memory UserAdd;
        // Node[] memory UserNode;
        // uint256 UserID;

        UserAdd[0] = Owner;
        // UserNode[0] = Node(
        //     0,
        //     0,
        //     1,
        //     1,
        //     0,
        //     0,
        //     2,
        //     0,
        //     address(0),
        //     UserAdd[1],
        //     UserAdd[2],
        //     false
        // );
        UserAdd[1] = 0xf77aF59DFF41226E2c71eE3ea947227D296985d6;
        // UserNode[1] = Node(
        //     0,
        //     0,
        //     0,
        //     0,
        //     0,
        //     1,
        //     0,
        //     0,
        //     UserAdd[0],
        //     address(0),
        //     address(0),
        //     false
        // );
        UserAdd[2] = 0x3b43741283c4B0f4ad04e4ee678ff8740d85dbCf;
        // UserNode[2] = Node(
        //     0,
        //     0,
        //     0,
        //     0,
        //     0,
        //     1,
        //     0,
        //     1,
        //     UserAdd[0],
        //     address(0),
        //     address(0),
        //     false
        // );
        UserID = 3;

        // return (UserAdd);
         return (UserAdd, UserID);
    }

    function test() public pure returns (uint256) {
        return 3;
    }
}