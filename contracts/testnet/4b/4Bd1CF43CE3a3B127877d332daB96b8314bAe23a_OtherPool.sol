// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../interfaces/IPlearnRanking.sol';

contract OtherPool is IPlearnRanking {
    constructor() {}

    function deposit(address user, uint256 amount) external {
        emit Deposit(user, amount);
    }

    function withdraw(address user,uint256  amount) external {
        emit Withdraw(user, amount);
    }

    function emergencyWithdraw(address user,uint256  amount) external {
        emit EmergencyWithdraw(user, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlearnRanking {
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event EmergencyWithdraw(address user, uint256 amount);
}