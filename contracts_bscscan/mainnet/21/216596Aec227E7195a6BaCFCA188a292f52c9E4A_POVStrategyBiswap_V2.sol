/**
 * @title Proof of Value - Strategy Biswap V2
 * @dev POVStrategyBiswap_V2 contract
 *
 * @author - <AUREUM VICTORIA GROUP>
 * for the Securus Foundation
 *
 * SPDX-License-Identifier: GNU GPLv2
 **/

pragma solidity ^0.6.12;

import "./ERC20.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./IRouter2.sol";
import "./IUniswapV2Pair.sol";
import "./IBiswapChef.sol";
import "./StratManager.sol";
import "./FeeManager.sol";

contract POVStrategyBiswap_V2 is StratManager, FeeManager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(
        uint256 _poolId,
        address _want,
        address _vault
    ) public {
        want = _want;
        poolId = _poolId;
        vault = _vault;
        lpToken0 = IUniswapV2Pair(want).token0();
        lpToken1 = IUniswapV2Pair(want).token1();

        outputToLp0Route = [bsw, xscr, lpToken0];
        outputToLp1Route = [bsw, xscr, lpToken1];

        busdToLp0Route = [busd, xscr, lpToken0];
        busdToLp1Route = [busd, xscr, lpToken1];

        _giveAllowances();
    }

    // If BUSD arrive on the smart contract then exchange it into the liquid pair
    function dollerToLQ() internal whenNotPaused {
        uint256 busdBal = IERC20(busd).balanceOf(address(this)).div(2);
        if (busdBal > 10) {
            if (lpToken0 != busd) {
                IRouter2(unirouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        busdBal,
                        0,
                        busdToLp0Route,
                        address(this),
                        now
                    );
            }

            if (lpToken1 != busd) {
                IRouter2(unirouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        busdBal,
                        0,
                        busdToLp1Route,
                        address(this),
                        now
                    );
            }

            uint256 lp0BalBusd = IERC20(lpToken0).balanceOf(address(this));
            uint256 lp1BalBusd = IERC20(lpToken1).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                lpToken0,
                lpToken1,
                lp0BalBusd,
                lp1BalBusd,
                1,
                1,
                address(this),
                now
            );
        }
    }

    // Puts the LQ funds to work / harvest the output
    function deposit() internal whenNotPaused {
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        IBiswapChef(chef).deposit(poolId, wantBal);
    }

    // The owner can withdraw the liquid pair to his vault.
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal < _amount) {
            IBiswapChef(chef).withdraw(poolId, _amount.sub(wantBal));
            wantBal = IERC20(want).balanceOf(address(this));
        }

        if (wantBal > _amount) {
            wantBal = _amount;
        }

        IERC20(want).safeTransfer(vault, wantBal);
    }

    // Call performance fee
    function chargeFees(address callFeeRecipient) internal {
        uint256 toCallFee = IERC20(output)
            .balanceOf(address(this))
            .div(1000)
            .mul(callFee);
        uint256 halfCallFee = toCallFee.div(2);

        counter++;

        if (counter == 1) {
            feeCoin = busd;
            feeLQCoin = 0x5B78E1ad1f6207050095a4316DE9a06e861416Cd;
        }
        if (counter == 2) {
            feeCoin = wbnb;
            feeLQCoin = 0x214819702cC8A8aBF852FdBd4312dd98e1D2546E;
        }
        if (counter == 3) {
            feeCoin = btcb;
            feeLQCoin = 0x9edC38b3B18Ef4547E30495A907faeB8a8f6382f;
        }
        if (counter == 4) {
            feeCoin = bifi;
            feeLQCoin = 0x1535C2bD110a3868f792C43c408EFf09d0cF2128;
        }
        if (counter == 5) {
            feeCoin = eth;
            feeLQCoin = 0x62722E4D7F2bcD02667Adb13095d4FeBcCAF2AA6;
        }
        if (counter == 6) {
            feeCoin = usdt;
            feeLQCoin = 0x4db89dCf4064B9c9a7AF9062C8fA23611EE19C09;
        }
        if (counter == 7) {
            feeCoin = bsw;
            feeLQCoin = 0xCFE5486a84d7E2251d68966C088f58F87FCd85A6;
            counter = 0;
        }

        outputToFeeCoinRoute = [bsw, xscr, feeCoin];
        IRouter2(unirouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                halfCallFee,
                0,
                outputToXscrRoute,
                address(this),
                now
            );
        if (feeCoin != bsw) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    halfCallFee,
                    0,
                    outputToFeeCoinRoute,
                    address(this),
                    now
                );
        }

        uint256 feeXscrBal = IERC20(xscr).balanceOf(address(this));
        uint256 feeCoinBal = IERC20(feeCoin).balanceOf(address(this));
        IRouter2(unirouter).addLiquidity(
            xscr,
            feeCoin,
            feeXscrBal,
            feeCoinBal,
            1,
            1,
            address(this),
            now
        );

        uint256 callFeeAmount = IERC20(feeLQCoin).balanceOf(address(this));
        IERC20(feeLQCoin).safeTransfer(callFeeRecipient, callFeeAmount);
    }

    // Adds liquidity to the automatic market maker and gets more LP tokens.
    function addLiquidity() internal {
        uint256 output = IERC20(output).balanceOf(address(this)).div(1000).mul(
            compoundFee
        );
        uint256 outputHalf = output.div(2);

        if (lpToken0 != bsw) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    outputHalf,
                    0,
                    outputToLp0Route,
                    address(this),
                    now
                );
        }
        if (lpToken1 != bsw) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    outputHalf,
                    0,
                    outputToLp1Route,
                    address(this),
                    now
                );
        }

        uint256 lp0Bal = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Bal = IERC20(lpToken1).balanceOf(address(this));
        IRouter2(unirouter).addLiquidity(
            lpToken0,
            lpToken1,
            lp0Bal,
            lp1Bal,
            1,
            1,
            address(this),
            now
        );
    }

    // Generate the profit for the POV vault
    function generateProfit() internal {
        uint256 bswBal = IERC20(bsw).balanceOf(address(this));
        if (bswBal > 0) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    bswBal,
                    0,
                    outputToWbnbRoute,
                    address(this),
                    now
                );
            uint256 wbnbBal = IERC20(wbnb).balanceOf(address(this));
            PovProfit = PovProfit.add(wbnbBal);
            IERC20(wbnb).safeTransfer(profitVault, wbnbBal);
        }
    }

    // Trigger the harvest.
    function harvest() external {
        _harvest(tx.origin);
    }

    // Compounds earnings and charges performance fee.
    function _harvest(address callFeeRecipient) internal whenNotPaused {
        if (IBiswapChef(chef).migrator() == address(0)) {
            dollerToLQ();
            deposit();
            uint256 outputBal = IERC20(output).balanceOf(address(this));
            if (outputBal > minToHarvest) {
                chargeFees(callFeeRecipient);
                addLiquidity();
                lastHarvest = block.timestamp;
                generateProfit();
            }
        } else {
            panic();
        }
    }

    // Calculate the total pool balance of "Want" held by the strats.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    // It calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // It calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        (uint256 _amount, ) = IBiswapChef(chef).userInfo(poolId, address(this));
        return _amount;
    }

    // Returns unharvested rewards.
    function rewardsAvailable() public view returns (uint256) {
        return IBiswapChef(chef).pendingBSW(poolId, address(this));
    }

    // Busd reward amount for calling harvest.
    function callReward() public view returns (uint256) {
        uint256 outputBal = rewardsAvailable();
        uint256 busdOut;
        if (outputBal > 0) {
            try
                IRouter2(unirouter).getAmountsOut(outputBal, outputToBusdRoute)
            returns (uint256[] memory amountOut) {
                busdOut = amountOut[amountOut.length - 1];
                busdOut = busdOut.div(1000).mul(callFee);
            } catch {}
        }

        return busdOut;
    }

    // Called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external onlyOwner {
        IBiswapChef(chef).emergencyWithdraw(poolId);

        uint256 wantBal = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(vault, wantBal);
    }

    // Pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyOwner {
        pause();
        IBiswapChef(chef).emergencyWithdraw(poolId);
    }

    /**
     * @dev Withdraws funds from the chef, leaving Coins.
     */
    function panic2(uint256 _balanceOfPool) public onlyOwner {
        pause();
        IBiswapChef(chef).withdraw(poolId, _balanceOfPool);
    }

    /**
     * @dev Pauses the strat.
     */
    function pause() public onlyOwner {
        _pause();

        _removeAllowances();
    }

    /**
     * @dev Unpauses the strat.
     */
    function unpause() external onlyOwner {
        _unpause();

        _giveAllowances();

        deposit();
    }

    function _giveAllowances() internal {
        IERC20(want).safeApprove(chef, uint256(-1));

        IERC20(output).safeApprove(unirouter, 0);
        IERC20(output).safeApprove(unirouter, uint256(-1));

        IERC20(lpToken0).safeApprove(unirouter, 0);
        IERC20(lpToken0).safeApprove(unirouter, uint256(-1));

        IERC20(lpToken1).safeApprove(unirouter, 0);
        IERC20(lpToken1).safeApprove(unirouter, uint256(-1));

        IERC20(busd).safeApprove(unirouter, 0);
        IERC20(busd).safeApprove(unirouter, uint256(-1));

        IERC20(xscr).safeApprove(unirouter, 0);
        IERC20(xscr).safeApprove(unirouter, uint256(-1));

        IERC20(btcb).safeApprove(unirouter, 0);
        IERC20(btcb).safeApprove(unirouter, uint256(-1));

        IERC20(bifi).safeApprove(unirouter, 0);
        IERC20(bifi).safeApprove(unirouter, uint256(-1));

        IERC20(wbnb).safeApprove(unirouter, 0);
        IERC20(wbnb).safeApprove(unirouter, uint256(-1));

        IERC20(eth).safeApprove(unirouter, 0);
        IERC20(eth).safeApprove(unirouter, uint256(-1));

        IERC20(usdt).safeApprove(unirouter, 0);
        IERC20(usdt).safeApprove(unirouter, uint256(-1));
    }

    function _removeAllowances() internal {
        IERC20(want).safeApprove(chef, 0);
        IERC20(output).safeApprove(unirouter, 0);
        IERC20(lpToken0).safeApprove(unirouter, 0);
        IERC20(lpToken1).safeApprove(unirouter, 0);
        IERC20(xscr).safeApprove(unirouter, 0);
        IERC20(busd).safeApprove(unirouter, 0);
        IERC20(btcb).safeApprove(unirouter, 0);
        IERC20(wbnb).safeApprove(unirouter, 0);
        IERC20(eth).safeApprove(unirouter, 0);
        IERC20(bifi).safeApprove(unirouter, 0);
        IERC20(usdt).safeApprove(unirouter, 0);
    }

    function outputToLp0() external view returns (address[] memory) {
        return outputToLp0Route;
    }

    function outputToLp1() external view returns (address[] memory) {
        return outputToLp1Route;
    }

    /**
     * @dev Function to exit the system. The vault will withdraw the required tokens
     * from the strategy and pay it to the vault.
     */
    function withdraw(address _token, uint256 _bal) public onlyOwner {
        IERC20(_token).transfer(vault, _bal);
    }
}