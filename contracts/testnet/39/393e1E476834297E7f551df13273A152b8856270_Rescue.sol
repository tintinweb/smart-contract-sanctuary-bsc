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

    constructor (address _usdt, address _dft) {

        USDT = _usdt;
        DFT = _dft;
    }

    function deposit(address account, uint256 usdtAmount, uint256 dftAmount) public {
        if (usdtAmount > 0) {
            require(IERC20(USDT).allowance(account, address(this)) >= usdtAmount, "USDT allowance not enough");
            uint256 sum = role[account].usdt;
            IERC20(USDT).transferFrom(account, address(this), usdtAmount);  
            role[account].usdt = sum.add(usdtAmount);
        }
        if (dftAmount > 0) {
            require(IERC20(DFT).allowance(account, address(this)) >= dftAmount, "DFT allowance not enough");
            uint256 sum = role[account].dft;
            IERC20(DFT).transferFrom(account, address(this), dftAmount);
            IERC20(DFT).burn(dftAmount);
            role[account].dft = sum.add(dftAmount);
        }
    }

    function withdrawal(address token, address account, uint256 amount) public multiReviewer {
        uint256 _amount = amount.div(2);
        require(IERC20(token).balanceOf(address(this)) >= _amount, "token balance not enough");    
        if (token == DFT) {
            require(role[account].dft >= amount, "role DFT balance not enough");
            role[account].dft = role[account].dft.sub(amount);
        }else if (token == USDT) {
            require(role[account].usdt >= amount, "role USDT balance not enough");
            role[account].usdt = role[account].usdt.sub(amount);
        } else {
             _amount = _amount.mul(2);
             require(IERC20(token).balanceOf(address(this)) >= _amount, "token balance not enough");   
        }
        IERC20(token).transfer(account, _amount);
    }

    function withdrawal(address payable account, uint256 amount) public multiReviewer {
        require(address(this).balance >= amount, "token balance not enough");    
        account.transfer(amount);
    }

    receive() external payable {}
}