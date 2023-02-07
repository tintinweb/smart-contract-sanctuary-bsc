// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./interfaces/IERC20.sol";

contract TaxCalculator {
    function estimateTokenTax(address _token, uint256 _amount) external {
        uint startBalance = IERC20(_token).balanceOf(address(this));

        IERC20(_token).approve(address(this), _amount);
        IERC20(_token).transfer(address(this), _amount);

        uint endBalance = IERC20(_token).balanceOf(address(this));
        uint transferredAmount = endBalance - startBalance;

        require(transferredAmount >= _amount, "Token has tax");
    }
}