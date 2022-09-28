/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// File: simple_flat.sol


// File: simple.sol



pragma solidity ^0.8.0;

contract ownable
{
    address public owner;
    constructor()
    {
        owner=msg.sender;
    }
    modifier onlyowner()
    {
        require(msg.sender == owner,"only owner access");
        _;
    }
    function setowner(address _newowner) public onlyowner
    {
    require(_newowner != address(0),"invalid address");
    owner=_newowner;
    }

}