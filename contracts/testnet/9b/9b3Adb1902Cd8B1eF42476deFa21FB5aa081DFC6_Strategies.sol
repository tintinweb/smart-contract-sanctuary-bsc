/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

pragma solidity ^0.5.16;

contract Strategies {
    function supplyBNB() payable public returns(bool,bytes memory) {
        address vBNB = 0x2E7222e51c0f6e98610A1543Aa3836E092CDe62c;
        return vBNB.delegatecall(abi.encodeWithSignature("mint()"));
    }
}