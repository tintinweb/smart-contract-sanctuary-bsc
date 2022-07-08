/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract RapidStake {
    string public name = "RapidStake";

    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    uint public totalStakedAmount;
    uint public totalWithdrawn;

    address rapidToken = 0x2B9C86c6AAc6b13DB640a3f3e30CDBAd7f19317D;

    function stakeTokens(uint _amount) public {
        require(_amount > 0, "Stake amount should be greater than 0.");

        IERC20(rapidToken).transferFrom(msg.sender, address(this), _amount);

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
        totalStakedAmount += _amount;
    }

    function unstakeTokens() public {
        uint balance = stakingBalance[msg.sender];
        require(balance == 0, "Unstaking balance can not be 0");

        IERC20(rapidToken).transfer(msg.sender, balance);

        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
        totalWithdrawn += balance;
    }
}