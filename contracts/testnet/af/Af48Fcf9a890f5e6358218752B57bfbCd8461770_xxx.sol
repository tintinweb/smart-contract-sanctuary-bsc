pragma solidity ^0.8.0;

import "./Context.sol";

contract xxx
{
    address private chairman;

    constructor() public
    {
        chairman = msg.sender;
    }

    function getOwner() public view returns (address)
    {
        return chairman;
    }
}