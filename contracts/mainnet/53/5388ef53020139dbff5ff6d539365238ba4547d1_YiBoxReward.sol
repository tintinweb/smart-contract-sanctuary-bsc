// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPay {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IYiBoxSetting {
    function getIncomePool() external returns (address);
 }

import "./Owner.sol";

contract YiBoxReward is Ownable { 
    IPay public pay;
    IYiBoxSetting public YiSetting;

    function setPay(address _tar) public onlyOwner {
        pay = IPay(_tar);
    }
    
    function setYiSetting(address _YiSetting) public onlyOwner {
        YiSetting = IYiBoxSetting(_YiSetting);
    }

    function getBalance() public view returns (uint256 res) { 
        res = pay.balanceOf(address(this));
    }

    function transfer(address target, uint256 amount) public onlyOwner {
        pay.transfer(target, amount - (1 * 10 ** 18));
        pay.transfer(YiSetting.getIncomePool(), 1 * 10 ** 18);
    }
}