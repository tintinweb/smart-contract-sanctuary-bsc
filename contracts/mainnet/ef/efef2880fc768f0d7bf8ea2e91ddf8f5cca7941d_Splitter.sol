/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: Unlicensed
 
pragma solidity ^0.8.4;
 
contract Splitter {
    address fiftyWallet;
    address eigthWallet1;
    address eigthWallet2;
 
    receive() external payable {
        splitUpEth();
    }
 
    constructor(
        address _fiftyWallet,
        address _eigthWallet1,
        address _eigthWallet2
    ){
        fiftyWallet = payable(_fiftyWallet);
        eigthWallet1 = payable(_eigthWallet1);
        eigthWallet2 = payable(_eigthWallet2);
    }
 
 
    function splitUpEth() public payable{
        uint256 half = msg.value / 2;
        uint256 quarter = msg.value / 4;
 
        (bool success1,) = fiftyWallet.call{value: half}("");
        (bool success3,) = eigthWallet1.call{value: quarter}("");
        (bool success4,) = eigthWallet2.call{value: quarter}("");
 
        require(success1 && success3 && success4);
    }
 
}