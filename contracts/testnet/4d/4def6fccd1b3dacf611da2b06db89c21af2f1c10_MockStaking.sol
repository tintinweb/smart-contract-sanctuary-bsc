/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

pragma solidity ^0.8.0;

contract MockStaking {
    
    event Stake(
        address by,
        uint256 amount
    );

    mapping(address => uint256) public staked;

    function stake(uint256 amount) public {
        staked[msg.sender] += amount;
        emit Stake(msg.sender, amount);
    }

}