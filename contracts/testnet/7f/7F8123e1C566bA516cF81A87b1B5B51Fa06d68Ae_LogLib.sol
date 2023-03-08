// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//Code by 9571  2023-02-27

contract LogLib {
    mapping(address => uint256) userCount;
    mapping(address => uint256) userCountTime;

    event debugstr(
        address contract_addr,
        address user_addr,
        uint256 time,
        string msg,
        string exec,
        uint256 num
    );
    event debugnum(
        address contract_addr,
        address user_addr,
        uint256 time,
        string msg,
        uint256 exec,
        uint256 num
    );
    event debugaddr(
        address contract_addr,
        address user_addr,
        uint256 time,
        address target_addr,
        string msg,
        uint256 exec,
        uint256 num
    );

    event debuggroup(
        address contract_addr,
        address user_addr,
        uint256 time,
        address target_addr,
        string msg1,
        string msg2,
        string msg3,
        string msg4,
        string msg5,
        uint256 num1,
        uint256 num2,
        uint256 num3
    );

    function LogStr(
        string memory value,
        string memory exec,
        uint256 num
    ) public {
        emit debugstr(
            address(msg.sender),
            tx.origin,
            block.timestamp,
            value,
            exec,
            num
        );
    }

    function LogNum(
        string memory value,
        uint256 exec,
        uint256 num
    ) public {
        emit debugnum(
            address(msg.sender),
            tx.origin,
            block.timestamp,
            value,
            exec,
            num
        );
    }

    function LogAddr(
        address target_addr,
        string memory value,
        uint256 exec,
        uint256 num
    ) public {
        emit debugaddr(
            address(msg.sender),
            tx.origin,
            block.timestamp,
            target_addr,
            value,
            exec,
            num
        );
    }

    function logGroup(
        address target_addr,
        string memory msg1,
        string memory msg2,
        string memory msg3,
        string memory msg4,
        string memory msg5,
        uint256 num1,
        uint256 num2,
        uint256 num3
    ) public {
        emit debuggroup(
            address(msg.sender),
            tx.origin,
            block.timestamp,
            target_addr,
            msg1,
            msg2,
            msg3,
            msg4,
            msg5,
            num1,
            num2,
            num3
        );
    }

    function userId() public returns (uint256) {
        uint256 id = userCount[tx.origin];
        userCount[tx.origin] += 1;
        return id;
    }

    function userSetTime() public {
        userCountTime[tx.origin] += block.timestamp;
    }

    function userQueryTime() public view returns (uint256) {
        return userCountTime[tx.origin];
    }
}

/*

interface LogLib  {
    function LogStr (string memory value,string memory exec,uint256 num ) external;
    function LogNum (string memory value,uint256 exec,uint256 num )  external ;
    function LogAddr (address target_addr,string memory value,uint256 exec,uint256 num )  external;
    function logGroup (address target_addr,string memory msg1,string memory msg2,string memory msg3,string memory msg4,string memory msg5,uint256 num1,uint256 num2,uint256 num3 ) external;

    function userId()          external returns (uint256);
    function userSetTime()     external;
    function userQueryTime()   external returns (uint);
    
}

*/