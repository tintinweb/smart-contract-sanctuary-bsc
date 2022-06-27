/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Zhubi {
    struct ZhubiPeople {
        string msg; // 信息
        uint time; // 第几次
    }

    mapping(address => ZhubiPeople[]) public zhubis;
 
    function imZhubi(string memory text) public {
        ZhubiPeople[] memory zp = zhubis[msg.sender];
        ZhubiPeople memory zhubi = ZhubiPeople(text, zp.length+1);
        zhubis[msg.sender].push(zhubi);
        }
    
    function getZhubi(address addr) public view returns (ZhubiPeople[] memory) {
        return zhubis[addr];
    }
}