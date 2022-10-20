/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.8.0;

contract TX {
    struct info {
        uint256 id;
        uint256 me;
        uint256 ptype;
    }

//    info[] public b;

    mapping(address => info[]) public addrList;

    function f() public {
        for(uint256 i=0; i<3; i++) {
            addrList[msg.sender].push(info(i,i,i));
        }
    }


    function getlist2(address user) public view   returns(info[] memory aaa) {
        aaa = new info[](addrList[user].length);
        for(uint256 i =0;i<addrList[user].length;i++){
            aaa[i]=addrList[user][i];
        }
    }

    function getlist3(address user) public view   returns(info[] memory) {
        info[] memory aaa = addrList[user];
        return aaa;
    }

}