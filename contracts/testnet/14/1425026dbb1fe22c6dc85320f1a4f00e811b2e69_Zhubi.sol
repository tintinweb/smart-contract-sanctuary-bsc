/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Zhubi {
    struct ZhubiPeople {
        string msg; // 信息
        uint time; // 次数
    }

    mapping(address => ZhubiPeople) public zhubis;
 
    function imZhubi(string memory text) public {
        zhubis[msg.sender].time++;
        zhubis[msg.sender].msg = text;
        }
    
    function getZhubi(address addr) public view returns (ZhubiPeople memory) {
        return zhubis[addr];
    }
}