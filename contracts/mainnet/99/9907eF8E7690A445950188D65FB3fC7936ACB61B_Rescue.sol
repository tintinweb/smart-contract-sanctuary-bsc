// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IERC20.sol";
import "./AccessControl.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Rescue is AccessControl, Ownable {
    using SafeMath for uint256;

    address public USDT;
    address public TFX;

    mapping (address => Amount) public role;

    struct Amount {
        uint256 usdt;
        uint256 tfx;
    }

    constructor () {

        USDT = address(0x55d398326f99059fF775485246999027B3197955);
        TFX = address(0xA9f96328F9468005B74e0aF9C7B62a3e43a1815B);
    }

    function deposit(uint256 usdtAmount, uint256 tfxAmount) public {
        if (usdtAmount > 0) {
            require(IERC20(USDT).allowance(_msgSender(), address(this)) >= usdtAmount, "USDT allowance not enough");
            uint256 sum = role[_msgSender()].usdt;
            IERC20(USDT).transferFrom(_msgSender(), address(this), usdtAmount);  
            role[_msgSender()].usdt = sum.add(usdtAmount);
        }
        if (tfxAmount > 0) {
            require(IERC20(TFX).allowance(_msgSender(), address(this)) >= tfxAmount, "TFX allowance not enough");
            uint256 sum = role[_msgSender()].tfx;
            IERC20(TFX).transferFrom(_msgSender(), address(this), tfxAmount);
            IERC20(TFX).burn(tfxAmount);
            role[_msgSender()].tfx = sum.add(tfxAmount);
        }
    }

    function withdrawal(address token, address account, uint256 amount) public multiReviewer {
        require(IERC20(token).balanceOf(address(this)) >= amount, "token balance not enough");
        require(role[account].usdt > 0 || role[account].tfx > 0, "role not involved");
        IERC20(token).transfer(account, amount);
    }
}