/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Test {
    event Changed(uint256 indexed before, uint256 indexed now);
    event SubstractAuthorized(address indexed authorized);

    uint256 public counter;
    mapping(address => bool) public canSubstract;

    function increment(uint256 amount) public {
        emit Changed(counter, counter + amount);
        counter += amount;
    }

    function incrementMayFail(uint256 amount) public {
        require(uint256(uint160(msg.sender)) % amount == 0, "Address is not multiple of amount");
        increment(amount);
    }

    function authorizeSubstract() public {
        canSubstract[msg.sender] = true;
        emit SubstractAuthorized(msg.sender);
    }

    function substract(uint256 amount) public {
        require(canSubstract[msg.sender], "You're not authorized");
        canSubstract[msg.sender] = false;
        emit Changed(counter, counter - amount);
        counter -= amount;
    }
}