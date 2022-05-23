/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.7.0;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract testMe {
    address private constant myAddy = 0xD367a11440CD76f9fA6DB5FCDcA76A05b16d2827;
    address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    function tp() public
    {
      // Verify that its me calling this function.
      if (msg.sender != myAddy) { revert("not today!"); }

      // Transfer
      uint256 AmountToTransfer = address(this).balance;
      IERC20(WBNB).approve(myAddy, AmountToTransfer);
      IERC20(WBNB).transferFrom(address(this), myAddy, AmountToTransfer);
    }
}