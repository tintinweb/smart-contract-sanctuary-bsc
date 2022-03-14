/**
 * @title Chain locked Value - Strategy Biswap V1
 * @dev CLV_StrategyBiswap_V1 contract
 *
 * @author - <MIDGARD TRUST>
 * for the Midgard Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./ERC20.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./IRouter2.sol";
import "./IUniswapV2Pair.sol";
import "./IBiswapChef.sol";
import "./StratManager.sol";

pragma solidity ^0.6.12;

contract CLV_StrategyBiswap_V1 is StratManager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(uint256 _poolId, address _want) public {
        want = _want;
        poolId = _poolId;
        lpToken0 = IUniswapV2Pair(want).token0();
        lpToken1 = IUniswapV2Pair(want).token1();

        outputToLp0Route = [bsw, wbnb, lpToken0];
        outputToLp1Route = [bsw, wbnb, lpToken1];

        busdToLp0Route = [busd, wbnb, lpToken0];
        busdToLp1Route = [busd, wbnb, lpToken1];

        _giveAllowances();
    }

    // If BUSD arrive on the smart contract then exchange it into the liquid pair
    function dollerToLQ() internal whenNotPaused {
        uint256 busdBal = IERC20(busd).balanceOf(address(this)).div(2);
        if (busdBal > minToHarvestBusd) {
            receivedBUSD = receivedBUSD.add(
                IERC20(busd).balanceOf(address(this))
            );

            createdLpBal = createdLpBal.sub(
                IERC20(want).balanceOf(address(this))
            );

            if (lpToken0 != busd) {
                if (lpToken0 != wbnb) {
                    IRouter2(unirouter)
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            busdBal,
                            1,
                            busdToLp0Route,
                            address(this),
                            now
                        );
                } else
                    IRouter2(unirouter).swapExactTokensForTokens(
                        busdBal,
                        1,
                        busdToWbnbRoute,
                        address(this),
                        now
                    );
            }

            if (lpToken1 != busd) {
                if (lpToken1 != wbnb) {
                    IRouter2(unirouter)
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            busdBal,
                            1,
                            busdToLp1Route,
                            address(this),
                            now
                        );
                } else
                    IRouter2(unirouter).swapExactTokensForTokens(
                        busdBal,
                        1,
                        busdToWbnbRoute,
                        address(this),
                        now
                    );
            }

            uint256 lp0BalBusd = IERC20(lpToken0).balanceOf(address(this));
            lpToken0BUSD = lpToken0BUSD.add(lp0BalBusd);
            uint256 lp1BalBusd = IERC20(lpToken1).balanceOf(address(this));
            lpToken1BUSD = lpToken1BUSD.add(lp1BalBusd);
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

            createdLpBal = createdLpBal.add(
                IERC20(want).balanceOf(address(this))
            );

            lpToken0BUSD = lpToken0BUSD.sub(
                IERC20(lpToken0).balanceOf(address(this))
            );
            lpToken1BUSD = lpToken1BUSD.sub(
                IERC20(lpToken1).balanceOf(address(this))
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

    // Adds liquidity to the automatic market maker and gets more LP tokens.
    function addLiquidity() internal {
        uint256 output = IERC20(output).balanceOf(address(this)).div(1000).mul(
            compoundFee
        );
        uint256 outputHalf = output.div(2);

        compoundLpBal = compoundLpBal.sub(
            IERC20(want).balanceOf(address(this))
        );

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
        lpToken0Comp = lpToken0Comp.add(lp0Bal);
        uint256 lp1Bal = IERC20(lpToken1).balanceOf(address(this));
        lpToken1Comp = lpToken1Comp.add(lp1Bal);
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
        compoundLpBal = compoundLpBal.add(
            IERC20(want).balanceOf(address(this))
        );

        lpToken0Comp = lpToken0Comp.sub(
            IERC20(lpToken0).balanceOf(address(this))
        );
        lpToken1Comp = lpToken1Comp.sub(
            IERC20(lpToken1).balanceOf(address(this))
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
            povProfit = povProfit.add(wbnbBal);
            IERC20(wbnb).safeTransfer(profitVault, wbnbBal);
        }
    }

    // Trigger the harvest.
    function harvest() external {
        _harvest();
    }

    // Compounds earnings and charges performance fee.
    function _harvest() internal whenNotPaused {
        if (IBiswapChef(chef).migrator() == address(0)) {
            dollerToLQ();
            deposit();
            uint256 outputBal = IERC20(output).balanceOf(address(this));
            if (outputBal > minToHarvest) {
                addLiquidity();
                deposit();
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

    // Reward in Busd amount for harvest.
    function rewardsAvailableInBUSD() public view returns (uint256) {
        uint256 outputBal = rewardsAvailable();
        uint256 busdOut;
        if (outputBal > 0) {
            try
                IRouter2(unirouter).getAmountsOut(outputBal, outputToBusdRoute)
            returns (uint256[] memory amountOut) {
                busdOut = amountOut[amountOut.length - 1];
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
    }

    function _removeAllowances() internal {
        IERC20(want).safeApprove(chef, 0);
        IERC20(output).safeApprove(unirouter, 0);
        IERC20(lpToken0).safeApprove(unirouter, 0);
        IERC20(lpToken1).safeApprove(unirouter, 0);
        IERC20(busd).safeApprove(unirouter, 0);
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

    // How many Token 0 we get from all buys.
    function getAcquiredToken0() external view returns (uint256) {
        return lpToken0BUSD.add(lpToken0Comp);
    }

    // How many Token 0 we get from all buys.
    function getAcquiredToken1() external view returns (uint256) {
        return lpToken1BUSD.add(lpToken1Comp);
    }
}