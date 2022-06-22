/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// contracts/TUSD.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Strategy {
    function delegateAddLiquidity(uint amountA, uint amountB) public {
        address c = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        address t1 = 0x51d117EeffaF297275A0A92B8c8DfB5deFB27247;
        address t2 = 0x90C45D8EA2bE12a0572A64eAdA3db8D240AB14c6;
        uint deadline = block.timestamp + 60;
        (bool success,) = c.delegatecall(abi.encodeWithSignature("addLiquidity(address,address,uint,uint,uint,uint,address,uint)",t1,t2,amountA,amountB,amountA,amountB,msg.sender,deadline));
        require(success, 'DelegateCall Failure!');
    }
}