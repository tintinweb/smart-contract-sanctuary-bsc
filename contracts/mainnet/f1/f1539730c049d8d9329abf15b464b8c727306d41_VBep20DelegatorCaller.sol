/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

pragma solidity ^0.8.0;

interface IVBep20Delegator {
    function mint(uint mintAmount) external returns (uint);
}

contract VBep20DelegatorCaller {
    IVBep20Delegator private vBep20Delegator;

    constructor(address contractAddress) {
        vBep20Delegator = IVBep20Delegator(contractAddress);
    }

    function callMint(uint256 mintAmount) external returns (uint) {
        return vBep20Delegator.mint(mintAmount);
    }
}