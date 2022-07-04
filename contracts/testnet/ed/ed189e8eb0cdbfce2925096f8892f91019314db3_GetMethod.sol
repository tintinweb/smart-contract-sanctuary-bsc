/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

pragma solidity ^0.6.0;

contract GetMethod
{
    uint public value=51;
    string public name="Method Call";
    address public ownerAddress;
    constructor() public
    {
        ownerAddress=msg.sender;
    }

    modifier onlyOwner
    {
        require(ownerAddress==msg.sender,"Only owner can call the function");
        _;
    }

    function getValue() public view onlyOwner returns(uint)
    {
        return value;
    }
    function getString() public view onlyOwner returns(string memory)
    {
        return name;
    }


}