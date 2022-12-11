/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

pragma solidity ^0.8.4;

contract Stake {
  mapping(address => uint256) public balances;
    mapping(address => uint256) public stakingStart;
    mapping(address => uint256) public stakingEnd;
    uint256 public stakingDays = 7;

    function stake() public payable {
        balances[msg.sender] += msg.value;
        stakingStart[msg.sender] = block.timestamp;
        stakingEnd[msg.sender] = block.timestamp + (stakingDays * 1 days);
    }

    function withdraw() public {
        require(stakingEnd[msg.sender] < block.timestamp, "Staking period has not ended");
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}