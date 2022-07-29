/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

pragma solidity ^0.7.6;

//SPDX-License-Identifier: Unlicensed

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract Split is Auth{

    address payable a1 = 0x6be9E183699FaE1b2941E026a6E4fb64f943D4CC;
    address payable a2 = 0x8f92BEd20F3164Ebc8C30b052aCb5141Ad6035d1;
    address payable a3 = 0x08667c443B5C8CE117A546e1a6925D286D43EAd0;
    address payable a4 = 0x7541981C2aa744d7eAEE4DF8aa9A4B56FA9d6AA8;

    uint256 div = 4;

    constructor () Auth(msg.sender) {}

    function withdraw() public {
        uint money = address(this).balance;
        uint split = money/div;

        a1.transfer(split);
        a2.transfer(split);
        a3.transfer(split);
        money = address(this).balance;

        a4.transfer(money);
    }

    function changeAddresses(address payable b1, address payable b2, 
                            address payable b3, address payable b4) external authorized {
        a1 = b1;
        a2 = b2;
        a3 = b3;
        a4 = b4;
    }

    receive() external payable { 
       //withdraw();
    }
  
}