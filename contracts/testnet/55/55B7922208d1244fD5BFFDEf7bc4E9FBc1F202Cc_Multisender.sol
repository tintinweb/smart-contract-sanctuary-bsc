/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

 

/**

* @title Ownable

* @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address public owner;

 

 

    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor() {

        owner = msg.sender;

    }

 

 

    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == owner, "Only the contract owner can call this function.");

        _;

    }

 

 

    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Invalid new owner address.");

        owner = newOwner;

    }

}

 

interface Token {

    function transfer(address recipient, uint256 amount) external returns (bool);

}

 

contract Multisender is Ownable {

 

    function multisend(address tokenAddr, address[] memory recipients, uint256[] memory amounts) public onlyOwner returns (bool) {

        require(recipients.length == amounts.length, "Mismatched array lengths.");

        require(recipients.length <= 1000, "Too many recipients in one transaction.");

        Token token = Token(tokenAddr);

        for (uint256 i = 0; i < recipients.length; i++) {

            require(token.transfer(recipients[i], amounts[i]), "Token transfer failed.");

        }

        return true;

    }

}