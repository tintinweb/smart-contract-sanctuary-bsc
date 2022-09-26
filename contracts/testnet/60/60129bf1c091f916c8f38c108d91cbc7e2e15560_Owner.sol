/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
} 



//     • exPerBlock :- It defines how many ex tokens are generated in a block.
//     • PoolInfo – All the pool details will be provided by this function. It based on the poolId.
//     • AccexPerShare – This variable is returned in poolInfo function. What does this mean?
// It returns the current reward token quantity for one staked lp token. This variable is manipulated by 1e12 for the decimal problems.
//     • AllocationPoint –  Admin can add multiple lp tokens as staked tokens to the farm. Let assume, experblock is 40 token. If the reward mint for all staking tokens is 40 reward tokens per block then the value of our ex token will reduce. If the reward is the same for all staking tokens, then the users will stake more USD cheaper lp tokens in the farm and get much higher reward. Allocationpoint helps to prevent this problem.Allocation point should be higher for LP tokens with higher USD value in the market and lower allocation point for tokens with lower USD value. Let’s see how it will works.