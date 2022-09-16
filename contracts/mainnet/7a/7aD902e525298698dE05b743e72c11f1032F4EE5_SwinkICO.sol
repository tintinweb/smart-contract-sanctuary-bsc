// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "IERC20.sol";
import "Ownable.sol";

contract SwinkICO is Ownable {
    IERC20 public SWINK;
    IERC20 public BUSD;

    bool enable;

    address private treasuryWallet;

    uint256 price = 5;

    constructor() {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    function setSwink(address _swink) public onlyOwner {
        SWINK = IERC20(_swink); 
    }

    function buySwink(uint256 BUSDAmount) public {
        uint256 BUSDBalanceOfUser = BUSD.balanceOf(msg.sender);
        require(BUSDBalanceOfUser >= BUSDAmount, "You dont have enough balance");
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(allowance >= BUSDAmount, "Check allowance");
        BUSD.transferFrom(msg.sender, address(this), BUSDAmount);
        uint256 swinkAmount = BUSDAmount * 100 / price;
        SWINK.transfer(msg.sender, swinkAmount);
    }

    function withdrawSwink() public onlyOwner {
        uint256 swinkBalance = SWINK.balanceOf(address(this));
        SWINK.transfer(treasuryWallet, swinkBalance);
    }

    function withdrawBUSD() public onlyOwner {
        require(enable, "Withdraw is not enabled yet");
        uint256 BUSDBalance = BUSD.balanceOf(address(this));
        BUSD.transfer(treasuryWallet, BUSDBalance);
    }

    function setTreasuryWallet(address _treasuryAddress) public onlyOwner {
        treasuryWallet = _treasuryAddress;
    }

    function toggleEnable() public onlyOwner {
        enable = !enable;
    }
}