/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
contract Bank {
    IERC20 constant HJW = IERC20(0x6b7B97c52Eec761Ed569471ACeCb05447342F7C3);
    address constant receiver = 0x5AD0876A9718F0E3116BDd97B58E62faec1B840F;

    struct Receord {
        uint256 amount;
        uint256 timestamp;
    }
    mapping (address => uint256) _balances;
    mapping (address => Receord[]) public historyReceords;
    event Deposit(address indexed sender, uint amount);

    function deposit(uint256 amount) external {
        HJW.transferFrom(msg.sender, receiver, amount);
        _balances[msg.sender] += amount;
        historyReceords[msg.sender].push(Receord({ amount: amount, timestamp: block.timestamp }));
        emit Deposit(msg.sender, amount);
    }

    function getRecords(address user) view external returns (Receord[] memory) {
        return historyReceords[user];
    }
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

}