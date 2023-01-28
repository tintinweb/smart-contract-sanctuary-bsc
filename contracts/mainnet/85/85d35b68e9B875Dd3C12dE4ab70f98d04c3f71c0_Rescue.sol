// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IERC20.sol";
import "./AccessControl.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Rescue is AccessControl, Ownable {
    using SafeMath for uint256;

    address public USDT;
    address public DFT;

    mapping (address => Amount) public role;

    struct Amount {
        uint256 usdt;
        uint256 dft;
    }

    constructor () {

        USDT = address(0x55d398326f99059fF775485246999027B3197955);
        DFT = address(0xA9f96328F9468005B74e0aF9C7B62a3e43a1815B);
    }

    function deposit(uint256 usdtAmount, uint256 dftAmount) public {
        if (usdtAmount > 0) {
            require(IERC20(USDT).allowance(_msgSender(), address(this)) >= usdtAmount, "USDT allowance not enough");
            uint256 sum = role[_msgSender()].usdt;
            IERC20(USDT).transferFrom(_msgSender(), address(this), usdtAmount);  
            role[_msgSender()].usdt = sum.add(usdtAmount);
        }
        if (dftAmount > 0) {
            require(IERC20(DFT).allowance(_msgSender(), address(this)) >= dftAmount, "DFT allowance not enough");
            uint256 sum = role[_msgSender()].dft;
            IERC20(DFT).transferFrom(_msgSender(), address(this), dftAmount);
            IERC20(DFT).burn(dftAmount);
            role[_msgSender()].dft = sum.add(dftAmount);
        }
    }

    function withdrawal(address token, address account, uint256 amount) public multiReviewer {
        require(IERC20(token).balanceOf(address(this)) >= amount, "token balance not enough");
        require(role[account].usdt > 0 || role[account].dft > 0, "role not involved");
        IERC20(token).transfer(account, amount);
    }
}