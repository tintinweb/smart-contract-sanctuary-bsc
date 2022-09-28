/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// File: IERC20.sol


pragma solidity ^0.8.5;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: ICO.sol


pragma solidity ^0.8.4;


contract ICO {

    IERC20 public token;

    constructor(IERC20 tokenAddress) {
        token = tokenAddress;
    }

    function buyTokens() public payable {
        uint256 tokenDecimals = 10**token.decimals();
        uint256 ethDecimals = 10**18;

        uint256 amount = (msg.value * tokenDecimals) / ethDecimals;

        require(token.balanceOf(address(this)) >= amount, "Contract doesn't have enough balance");

        token.transfer(msg.sender, amount);
    }
}