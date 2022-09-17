// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "IERC20.sol";
import "Ownable.sol";

contract SwinkICO is Ownable {
    IERC20 public SWINK;
    
    //da cambiare in BUSD
    IERC20 public USDC;

    bool enable;

    //da teamWallet passa a treasuryWallet
    address private teamWallet;

    //5 centesimi di dollaro
    uint256 price = 5;

    constructor() {
        USDC = IERC20(0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814);   // busd contract on bsc mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    }

    function setSwink(address _swink) public onlyOwner {
        SWINK = IERC20(_swink); 
    }

    function buySwink(uint256 usdcAmount) public {
        uint256 usdcBalanceOfUser = USDC.balanceOf(msg.sender);
        require(usdcBalanceOfUser >= usdcAmount, "You dont have enough balance");
        uint256 allowance = USDC.allowance(msg.sender, address(this));
        require(allowance >= usdcAmount, "Check allowance");
        USDC.transferFrom(msg.sender, address(this), usdcAmount);
        uint256 swinkAmount = usdcAmount * 100 / price * 10 ** 18;// /*/ 10 ** (USDC.decimals() - SWINK.decimals())*/ / price;
        SWINK.transfer(msg.sender, swinkAmount);
    }

    function withdrawSwink() public onlyOwner {
        uint256 swinkBalance = SWINK.balanceOf(address(this));
        SWINK.transfer(teamWallet, swinkBalance);
    }

    function withdrawUsdc() public onlyOwner {
        require(enable, "Withdraw is not enabled yet");
        uint256 usdcBalance = USDC.balanceOf(address(this));
        USDC.transfer(teamWallet, usdcBalance);
    }

    function setTeamWallet(address _teamAddress) public onlyOwner {
        teamWallet = _teamAddress;
    }

    function toggleEnable() public onlyOwner {
        enable = !enable;
    }
}