/**
 *Submitted for verification at BscScan.com on 2022-07-25
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

    address payable a1 = 0xec631Fd9e78B5BE48CB2695BF85f3dC676F63376;
    address payable a2 = 0xD495aaF96A3528f318595B07EcA0f72bCC882a76;
    address payable a3 = 0x93CFc9d12b48376860882774CE487990D9541270;

    uint256 div = 3;

    constructor () Auth(msg.sender) {}

    function withdraw() public {
        uint money = address(this).balance;
        uint split = money/div;

        a1.transfer(split);
        a2.transfer(split);
        money = address(this).balance;

        a3.transfer(money);
    }

    function changeAddresses(address payable b1, address payable b2, 
                            address payable b3) external authorized {
        a1 = b1;
        a2 = b2;
        a3 = b3;
    }

    receive() external payable { 
       //withdraw();
    }
  
}