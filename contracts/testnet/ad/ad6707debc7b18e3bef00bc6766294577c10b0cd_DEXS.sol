/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DEXS {
    IERC20 public szToken;
    IERC20 public kofToken;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor(address _szToken, address _kofToken) {
        szToken = IERC20(_szToken);
        kofToken = IERC20(_kofToken);
    }

    struct UserDeposits {
        uint256 amount;
        address user;
    }
    uint256 count = 0;
    UserDeposits[] public userDeposits;

    function buy() public payable {
        uint256 _amount = msg.value;
        uint256 dexBalance = szToken.balanceOf(address(this));
        require(_amount > 0, "You need to send some ether");
        require(
            (_amount * 2) <= dexBalance,
            "Not enough tokens in the reserve"
        );
        szToken.transfer(msg.sender, _amount * 2);
        emit Bought(_amount);
    }

    function sell(uint256 _amount) public {
        require(_amount > 0, "You need to send some ether");
        uint256 userBal = szToken.balanceOf(msg.sender);
        require(_amount <= userBal, "Not enough tokens in the reserve");
        uint256 allowed = szToken.allowance(msg.sender, address(this));
        require(allowed >= _amount, "Check the token allowance");
        szToken.transferFrom(msg.sender, address(this), _amount);
        if (count == 0) {
            userDeposits.push(UserDeposits(_amount, msg.sender));
            count++;
            kofToken.transfer(msg.sender, _amount * 2);
        } else {
            uint256 prev = userDeposits[count - 1].amount;
            if (_amount >= (prev + ((15 * prev) / 100))) {
                userDeposits.push(UserDeposits(_amount, msg.sender));
                count++;
                kofToken.transfer(msg.sender, _amount * 2);
            }
        }
        payable(msg.sender).transfer(_amount / 2);
        emit Sold(_amount);
    }
}