pragma solidity ^0.5.16;

import "./VBNB.sol";

contract Strategies {

    VBNB vBNB;

    constructor() public{
        vBNB = VBNB(0x2E7222e51c0f6e98610A1543Aa3836E092CDe62c);
    }

    function supplyBNB() payable public  {
        address(vBNB).delegatecall(abi.encodeWithSignature("mint()"));
    }
}