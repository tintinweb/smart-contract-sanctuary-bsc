// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


interface testNFT {
    function mint() external payable;
}

contract roopMint {

    uint mintPrice = 2*10**16;

    address public testNFTAddress = 0xa3d4cBbaD0b951e2A531F2264D910EB79bc841Ed;
    testNFT mintContract = testNFT(testNFTAddress);




    function mint () external payable {
        //require(msg.value >= mintPrice);
        mintContract.mint();
    }



}