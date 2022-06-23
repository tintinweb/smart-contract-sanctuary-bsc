/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

//SPDX-License-Identifier:MIT
pragma solidity >=0.8.11;
//11
contract selfwhitelist{
    address owner;

    constructor(){
        owner=msg.sender;
    }
    modifier onlyOwner() {
    require(msg.sender == owner, "only owner can be called");
    _;
   }
   mapping(address => bool) whitelisted;
   function whitelist(address whitelistedaddress )public onlyOwner{
       whitelisted[whitelistedaddress]=true;
   }
   function check(address _whitelisted)public view returns(bool){
        bool userwhitelisted=whitelisted[_whitelisted];
        return userwhitelisted; 
    }
}