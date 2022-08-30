/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract gasTest {
	
	struct taoCan{
		uint256 id;
		//uint256 time;
		//address belong;
	}
	taoCan[] public taocans;
	
	struct selling{
		uint256 id;
		taoCan tc;
		address ads;
	}
	
	selling[] public sellings;
	
	struct subscribe{
		uint256 id;
		uint256 time;
		address ads;
	}
	subscribe[] public subscribes;
	
	struct Order{
		uint256 id;
		uint256 time;
		address sell;
		address buy;
		taoCan tc;
	}

	Order[] public orders;
	
	function initTaoCan() public{
		taoCan memory tc1;
		for(uint256 i=0; i<50; i++){
			tc1 = taoCan(i);
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
		taoCan memory tc2;
		for(uint256 i=0; i<50; i++){
			tc2 = taoCan(i);
			sg = selling(i, tc2,msg.sender);
			sellings.push(sg);
		}
	}
	function domatching() public{
		selling memory sg;
		subscribe memory se;
		Order memory or;
		for(uint256 i=0; i<50; i++){
           sg = sellings[i];
		   se = subscribes[i];
		   or = Order(i, block.timestamp, sg.ads, se.ads,sg.tc);
		   orders.push(or);
		}

	}

  
	
}