/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract UserPool {

    address payable[] public players;
    address public admin;
    uint public createTime;
    enum POOL_STATE {
        OPEN, CLOSED
    }
    POOL_STATE public poolState;

    struct User {
        address user;
        uint score;
    }

    constructor() {
        admin = msg.sender;
        poolState = POOL_STATE.CLOSED;
    }

    receive () payable external {

    }

    function payPool() public payable {
        require(poolState == POOL_STATE.OPEN, "Pool is closed");
        require(msg.value > 0 ether, "Please pay something to join pool");
        players.push(payable(msg.sender));
    }

    function startPool() public {
        require(msg.sender == admin, "Only admin can start the pool");
        require(poolState == POOL_STATE.CLOSED, "The pool is already open");
        poolState = POOL_STATE.OPEN;
    }

    function endPool() public {
        require(msg.sender == admin, "Only admin can close the pool");
        require(poolState == POOL_STATE.OPEN, "The pool is already closed");
        poolState = POOL_STATE.CLOSED;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function adminWithdraw() public {
        require(msg.sender == admin, "Only admin can withdraw");
        payable(admin).transfer(getBalance());
    }
}