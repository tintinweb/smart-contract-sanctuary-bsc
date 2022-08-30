/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract gasTest2 {
	
	struct taoCan{
		uint256 id;
		uint128 time;
        uint64 status;
        uint64 orderid;
        address belong;
        address sell;
        address buy;
	}

	taoCan[] public taocans;
	
	struct selling{
		uint256 id;
		uint256 tcid;
		address ads;
	}
	
	selling[] public sellings;
	
	struct subscribe{
		uint256 id;
		uint256 time;
		address ads;
	}
	subscribe[] public subscribes;
	
	function initTaoCan() public{
		taoCan memory tc1;
		for(uint256 i=0; i<50; i++){
			tc1 = taoCan(i, uint128(block.timestamp), 0, 0, msg.sender, address(0), address(0));
			taocans.push(tc1);
		}
	}
	function initSubscribe() public{
		subscribe memory se;
		for(uint256 i=0; i<60; i++){
			se = subscribe(i, block.timestamp, msg.sender);
			subscribes.push(se);
		}
	}
	function initselling() public{
		selling memory sg;
		for(uint256 i=0; i<50; i++){
			sg = selling(i, i,msg.sender);
			sellings.push(sg);
		}
	}

    function domatching() public{
		selling memory sg;
		subscribe memory se;

		for(uint256 i=0; i<50; i++){
           sg = sellings[i];
		   se = subscribes[i];
		   taocans[i].time = uint128(block.timestamp);
		   taocans[i].status = 1; //sell and buy
           taocans[i].orderid = uint64(i);
           taocans[i].sell = sg.ads;
           taocans[i].buy = se.ads;
		}

	}
  
	
}