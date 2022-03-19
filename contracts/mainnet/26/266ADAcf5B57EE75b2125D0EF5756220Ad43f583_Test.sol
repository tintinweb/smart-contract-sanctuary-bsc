/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

contract Test{
    struct RecommInfo{
        uint invitedNum;       //invited num
        uint[3] inviteRewardAmt;  //total reward meat
    }
    mapping(address => RecommInfo) public recommInfos; 

    function set(address a,uint inv ,uint u0,uint u1,uint u2) public  {
        recommInfos[a].invitedNum = inv;
        if (u0>0) 
            recommInfos[a].inviteRewardAmt[0] = u0;
        if (u1>0) 
            recommInfos[a].inviteRewardAmt[1] = u1;
        if (u2>0) 
            recommInfos[a].inviteRewardAmt[2] = u2;
    }

}