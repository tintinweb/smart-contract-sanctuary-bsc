/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

pragma solidity ^0.4.24;

contract Gassender {
    
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner,"you are not the owner");
        _;
    }

    constructor() public payable {
        owner = msg.sender;
    }
    function () payable public {}
    function sendgas(address[] _addrlist,uint256[] _amount) payable onlyOwner public {
        require(_addrlist.length > 0);
        for(uint i=0;i<_addrlist.length;i++)
        {
            _addrlist[i].transfer(_amount[i]*100000000000);
        }
        
    }

}