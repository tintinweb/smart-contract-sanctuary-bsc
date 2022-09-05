/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract paraTest {
	
	struct selling{
		uint256 id;
		address ads;
	}
	
	selling[] public sellings; //sell数组

    uint256 initid = 0;
    address constant HEAD = address(1);
    address public LastAddress;

	mapping(address=>address) public nextbuys;  //map买单排序

    constructor() {
		nextbuys[HEAD] = address(1);
		LastAddress = nextbuys[HEAD];
	}
	
	function doSubscribe() public{//map 排序
		nextbuys[LastAddress] = msg.sender;
		LastAddress = msg.sender;
	}

	function doSell() public{ //数组排序
        initid +=1;
		selling memory sg;
		sg = selling(initid, msg.sender);
		sellings.push(sg);
	}
	
	
}