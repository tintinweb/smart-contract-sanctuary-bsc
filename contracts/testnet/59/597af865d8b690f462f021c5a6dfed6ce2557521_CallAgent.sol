// SPDX-License-Identifier: BSD 3-Clause

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

contract CallAgent is Ownable {
    function withdrawEth(uint256 amount, address payable out) public onlyOwner {
        out.transfer(amount);
    }

    function withdrawErc20(
        uint256 amount,
        address erc20,
        address out
    ) public onlyOwner {
        IERC20(erc20).transfer(out, amount);
    }

    function approveERC20(
        address erc20,
        address target,
        uint256 amount
    ) public onlyOwner {
        IERC20(erc20).approve(target, amount);
    }

    function callWithEarnErc20(
        address cont1,
        bytes calldata call1,
        address cont2,
        bytes calldata call2,
        address token
    ) public onlyOwner {
        uint256 balance_before = IERC20(token).balanceOf(address(this));
        cont1.call(call1);
        cont2.call(call2);
        uint256 balance_after = IERC20(token).balanceOf(address(this));
        require(balance_after > balance_before, "emmmmmm");
    }

    function callWithEarnEth(
        address cont1,
        bytes calldata call1,
        uint256 amount1,
        address cont2,
        bytes calldata call2,
        uint256 amount2
    ) public onlyOwner {
        uint256 balance_before = address(this).balance;
        cont1.call{value: amount1}(call1);
        cont2.call{value: amount2}(call2);
        uint256 balance_after = address(this).balance;
        require(balance_after > balance_before, "emmmmmm");
    }

    function multiCall(
        address cont1,
        bytes calldata call1,
        uint256 amount1,
        address cont2,
        bytes calldata call2,
        uint256 amount2
    ) public onlyOwner {
        cont1.call{value: amount1}(call1);
        cont2.call{value: amount2}(call2);
    }

    fallback() external payable {}
}