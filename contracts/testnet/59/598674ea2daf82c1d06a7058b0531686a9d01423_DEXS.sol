/**
 *Submitted for verification at BscScan.com on 2023-02-10
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
    
    IERC20 public token;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor(address _token){
        token = IERC20(_token);
    }

    function buy() payable public {
        uint256 _amount = msg.value;
        uint dexBalance = token.balanceOf(address(this));
        require(_amount > 0, "You need to send some ether");
        require((_amount * 2) <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, _amount * 2);
        emit Bought(_amount);
    }

    function sell(uint _amount) public {
        require(_amount > 0, "You need to send some ether");
        uint userBal = token.balanceOf(msg.sender);
        require(_amount <= userBal, "Not enough tokens in the reserve");
        uint allowed = token.allowance(msg.sender, address(this));
        require(allowed >= _amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), _amount);
        payable(msg.sender).transfer(_amount / 2);
        emit Sold(_amount);
    }
}