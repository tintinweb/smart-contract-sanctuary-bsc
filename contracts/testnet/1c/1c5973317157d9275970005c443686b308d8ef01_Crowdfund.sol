/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

pragma solidity ^0.8.0;

contract Crowdfund{
    bytes32 public Crowdfund_Name;
    uint256 public Crowdfund_Amount;
    address public owner;

    constructor(bytes32 _Name, uint256 _Amount){
        Crowdfund_Name = _Name;
        Crowdfund_Amount = _Amount;   
        owner = msg.sender;
    }

}