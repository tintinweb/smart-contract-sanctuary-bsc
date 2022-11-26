//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IDaylight {
    function burnFrom(address account, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function sellBurn(
        uint256 amount,
        address to,
        address router,
        address receiveToken,
        uint256 excess
    ) external;
}

interface IRedeem {
    function redeem(address[] calldata tokens, uint256 amount) external;
    
}

contract FeeReceiver {

    // daylight token and redeem contract
    address public constant daylight = 0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E;
    address public daylightRedeem;

    // token to redeem
    address public redeemToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public sellBurnToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // routers
    address public sellBurnRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public buyBurnRouter = 0xb34DA672837aFe372eceF419b25a357A36f59F6f;

    // wallet to distribute rewards for staking and farming
    address public rewardWallet;

    // users who can trigger the receiver
    mapping ( address => bool ) public canTrigger;

    // Percent Of Balance To Burn In Excess
    uint256 public excessPercent = 10;

    // use daylight owner
    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    constructor(
        address daylightRedeem_,
        address rewardWallet_
    ) {
        daylightRedeem = daylightRedeem_;
        rewardWallet = rewardWallet_;

        canTrigger[daylight] = true;
        canTrigger[msg.sender] = true;
    }

    function withdrawETH() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function burnAll() external onlyOwner {
        IDaylight(daylight).burn( IERC20(daylight).balanceOf(address(this)) );
    }

    function setRewardWallet(address newWallet) external onlyOwner {
        rewardWallet = newWallet;
    }

    function setCanTrigger(address user, bool canTrigger_) external onlyOwner {
        canTrigger[user] = canTrigger_;
    }

    function setSellBurnRouter(address newRouter) external onlyOwner {
        sellBurnRouter = newRouter;
    }

    function setBuyBurnRouter(address newRouter) external onlyOwner {
        buyBurnRouter = newRouter;
    }

    function setRedeemToken(address newRedeemToken) external onlyOwner {
        redeemToken = newRedeemToken;
    }

    function setSellBurnToken(address newSellBurnToken) external onlyOwner {
        sellBurnToken = newSellBurnToken;
    }

    function setDaylightRedeem(address newRedeem) external onlyOwner {
        daylightRedeem = newRedeem;
    }

    function setExcessPercent(uint256 newExcess) external onlyOwner {
        excessPercent = newExcess;
    }

    function trigger() external {
        
        require(
            canTrigger[msg.sender],
            'Only Approved Operator Can Trigger'
        );

        // daylight balance
        uint256 balance = IERC20(daylight).balanceOf(address(this));
        if (balance <= 1000) {
            return;
        }

        // send 20% to the reward distributor
        IERC20(daylight).transfer(rewardWallet, ( balance * 2 ) / 10);

        // sell-burn 20% to PCS
        IDaylight(daylight).sellBurn(
            ( balance * 2 ) / 10,
            address(this),
            sellBurnRouter,
            sellBurnToken,
            ( balance * excessPercent ) / 100
        );

        // put redeem token balance in floor contract
        IERC20(sellBurnToken).transfer(daylightRedeem, IERC20(sellBurnToken).balanceOf(address(this)));

        // approve of redeem contract
        IERC20(daylight).approve(daylightRedeem, balance);
        
        // redeem 20% of balance
        address[] memory redeemTokens = new address[](1);
        redeemTokens[0] = redeemToken;
        IRedeem(daylightRedeem).redeem(redeemTokens, ( balance * 2 ) / 10);

        // buy back with tokens received
        address[] memory path = new address[](2);
        path[0] = redeemToken;
        path[1] = daylight;
        IERC20(redeemToken).approve(buyBurnRouter, type(uint256).max);
        IUniswapV2Router02(buyBurnRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            IERC20(redeemToken).balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp + 1000
        );

        // burn remainder of balance
        IDaylight(daylight).burn( IERC20(daylight).balanceOf(address(this)) );

        // clear storage
        delete redeemTokens;
        delete path;
    }

    receive() external payable {}
}