/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

//#SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.6 <0.8.0;

contract Main {
     bytes4 private constant SELECTOR_TRANSFER = 0xe43ca232;

//e43ca232
//0xe212a3648892101b7bcff37d66fcf620b4b747a3
    function MainCall(address token) external {
       
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR_TRANSFER)
        );

        

    }
}