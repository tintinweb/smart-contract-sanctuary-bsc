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
    address public immutable daylight;
    address public daylightRedeem;

    // token to redeem
    address public redeemToken;
    address public sellBurnToken;

    // routers
    address public sellBurnRouter;
    address public buyBurnRouter;

    // wallet to distribute rewards for staking and farming
    address public rewardWallet;
    
    // minimum tokens to trigger fee receiver
    uint256 public minToTrigger = 100 * 10**18;

    // use daylight owner
    modifier onlyOwner() {
        require(
            msg.sender == IDaylight(daylight).getOwner(),
            'Only Daylight Owner'
        );
        _;
    }

    constructor(
        address daylight_,
        address daylightRedeem_,
        address rewardWallet_,
        address redeemToken_,
        address sellBurnToken_,
        address buyBurnRouter_,
        address sellBurnRouter_
    ) {
        daylight = daylight_;
        daylightRedeem = daylightRedeem_;
        rewardWallet = rewardWallet_;

        redeemToken = redeemToken_;
        sellBurnToken = sellBurnToken_;
        sellBurnRouter = sellBurnRouter_;
        buyBurnRouter = buyBurnRouter_;
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

    function setMinToTrigger(uint256 minToTrigger_) external onlyOwner {
        minToTrigger = minToTrigger_;
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

    function trigger() external {
        
        // daylight balance
        uint256 balance = IERC20(daylight).balanceOf(address(this));
        if (balance <= minToTrigger) {
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
            balance / 10
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