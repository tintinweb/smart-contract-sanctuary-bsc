// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


interface testNFT {
    function mint() external payable;
}

contract roopMint {

    address public testNFTAddress;
    testNFT mintContract;


    function setInterface(address  _testNFTAddress) external {
        testNFTAddress = _testNFTAddress;
        mintContract = testNFT(testNFTAddress);
    }

    function mint () external payable {
        mintContract.mint();
    }



}