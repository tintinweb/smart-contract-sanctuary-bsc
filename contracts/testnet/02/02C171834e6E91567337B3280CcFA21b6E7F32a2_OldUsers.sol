/**
 *Submitted for verification at BscScan.com on 2022-08-20
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

    mapping(uint256 => address) private _allUsersAddress;
    mapping(uint256 => Node) private UserNode;
    uint256 private UserID;

    constructor() {
        _allUsersAddress[0] = 0x9400F2b5DF259510ee952224dE9009D31b7ea03A;
        _allUsersAddress[1] = 0xf77aF59DFF41226E2c71eE3ea947227D296985d6;
        _allUsersAddress[2] = 0x3b43741283c4B0f4ad04e4ee678ff8740d85dbCf;

        UserID = 3;

        UserNode[0] = Node(
            0,
            0,
            1,
            1,
            0,
            0,
            2,
            0,
            address(0),
            _allUsersAddress[1],
            _allUsersAddress[2],
            false
        );
        UserNode[1] = Node(
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            _allUsersAddress[0],
            address(0),
            address(0),
            false
        );
        
        UserNode[2] = Node(
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            1,
            _allUsersAddress[0],
            address(0),
            address(0),
            false
        );
    }

    // function Initialize(address Owner) external returns (address[] memory) {
      
    // }

    function get_Last_UserId() public view returns (uint256) {
        return UserID;
    }

    function get_Last_UserAddress() public view returns (address[] memory) {
        address[] memory UserAdd1 = new address[](UserID);
        for (uint256 index = 0; index < UserID; index++) {
            UserAdd1[index] = _allUsersAddress[index];
        }
        return UserAdd1;
    }

    function get_Last_UserNodes() public view returns (Node[] memory) {
        Node[] memory UserNode1 = new Node[](UserID);
        for (uint256 index = 0; index < UserID; index++) {
            UserNode1[index] = UserNode[index];
        }
        return UserNode1;
    }

    // function test5() public view returns (Node memory) {
    //     return UserNode[0];
    // }

    // function test6() public view returns (Node memory) {
    //     Node[] memory UserAdd1 = new Node[](UserID);
    //     for (uint256 index = 0; index < UserID; index++) {
    //         UserAdd1[index] = UserNode[index];
    //     }
    //     return UserAdd1[0];
    // }

    // function test6()
    //     public
    //     view
    //     returns (
    //         address[] memory,
    //         Node[] memory,
    //         uint256
    //     )
    // {
    //     return (UserAdd, UserNode, UserID);
    // }

    // function test7() public {
    //     UserNode[0] = Node(
    //         0,
    //         0,
    //         1,
    //         1,
    //         0,
    //         0,
    //         2,
    //         0,
    //         address(0),
    //         UserAdd[1],
    //         UserAdd[2],
    //         false
    //     );
    //     // UserAdd[1] = 0xf77aF59DFF41226E2c71eE3ea947227D296985d6;
    //     UserNode[1] = Node(
    //         0,
    //         0,
    //         0,
    //         0,
    //         0,
    //         1,
    //         0,
    //         0,
    //         UserAdd[0],
    //         address(0),
    //         address(0),
    //         false
    //     );
    //     // UserAdd[2] = 0x3b43741283c4B0f4ad04e4ee678ff8740d85dbCf;
    //     UserNode[2] = Node(
    //         0,
    //         0,
    //         0,
    //         0,
    //         0,
    //         1,
    //         0,
    //         1,
    //         UserAdd[0],
    //         address(0),
    //         address(0),
    //         false
    //     );
    // }
}