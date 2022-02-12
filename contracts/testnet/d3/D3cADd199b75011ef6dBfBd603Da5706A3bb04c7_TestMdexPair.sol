/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.12;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

interface IMdexPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract TestMdexPair is IMdexPair, Ownable {

    uint112 public v1;
    uint112 public v2;

    constructor(uint112 _v1, uint112 _v2) public {
        v1 = _v1;
        v2 = _v2;
    }

    function getReserves() public override view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast){
        reserve0 = v1;
        reserve1 = v2;
        blockTimestampLast = uint32(now);
    }

    function updateValue(uint112 _v1, uint112 _v2) public onlyOwner {
        v1 = _v1;
        v2 = _v2;
    }
}