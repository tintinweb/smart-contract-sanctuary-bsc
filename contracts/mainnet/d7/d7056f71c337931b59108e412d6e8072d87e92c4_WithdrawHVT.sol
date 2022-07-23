/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract WithdrawHVT {

    address hvtContract = 0x779c7A9F92aDa6f94bB46B60de1db936097b91b5;
    

    function withdraw() public {
        (bool success, ) = hvtContract.delegatecall(abi.encodeWithSignature("withdraw(uint256)", 100000000000000000));
        require(success, "Could not withdraw");
    }

}