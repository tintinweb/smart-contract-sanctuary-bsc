/**
 * @title Liquidity Generator
 * @dev LiquidGenerator contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./StratManager.sol";
import "./SafeERC20.sol";
import "./IRouter2.sol";
import "./Pausable.sol";

pragma solidity 0.6.12;

contract LiquidGenerator is StratManager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Adds liquidity to AMM and gets more LP tokens.
    function harvest() public {
        uint256 wbnbBal = IERC20(wbnb).balanceOf(address(this));
        uint256 i = 0;

        while (i < want.length) {
            uint256 wbnbBalHalf = wbnbBal.div(10000).mul(percent[i]).div(2);

            lpToken0 = IRouter2(want[i]).token0();
            lpToken1 = IRouter2(want[i]).token1();

            IERC20(lpToken0).safeApprove(unirouter, 0);
            IERC20(lpToken0).safeApprove(unirouter, uint256(-1));

            IERC20(lpToken1).safeApprove(unirouter, 0);
            IERC20(lpToken1).safeApprove(unirouter, uint256(-1));

            if (lpToken0 == wantToken) {
                wbnbToLp0Route = [wbnb, lpToken1, wantToken];
                if (lpToken1 == wbnb) {
                    wbnbToLp0Route = [wbnb, wantToken];
                }
            } else if (lpToken0 != wbnb) {
                wbnbToLp0Route = [wbnb, lpToken0];
            }

            if (lpToken1 == wantToken) {
                wbnbToLp1Route = [wbnb, lpToken0, wantToken];
                if (lpToken0 == wbnb) {
                    wbnbToLp1Route = [wbnb, wantToken];
                }
            } else if (lpToken1 != wbnb) {
                wbnbToLp1Route = [wbnb, lpToken1];
            }

            if (lpToken0 != wbnb) {
                IRouter2(unirouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        wbnbBalHalf,
                        0,
                        wbnbToLp0Route,
                        address(this),
                        now
                    );
            }

            if (lpToken1 != wbnb) {
                IRouter2(unirouter)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        wbnbBalHalf,
                        0,
                        wbnbToLp1Route,
                        address(this),
                        now
                    );
            }

            if (lpToken0 == wbnb) {
                lp0Bal = wbnbBalHalf;
            } else {
                lp0Bal = IERC20(lpToken0).balanceOf(address(this));
            }

            if (lpToken0 == wbnb) {
                lp1Bal = wbnbBalHalf;
            } else {
                lp1Bal = IERC20(lpToken1).balanceOf(address(this));
            }

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

            LPAmount = IERC20(want[i]).balanceOf(address(this));
            IERC20(want[i]).safeTransfer(vault, LPAmount);

            i += 1;
        }
    }

    function withdrawTokens(address _token, uint256 _amount)
        external
        onlyOwner
    {
        IERC20(_token).safeTransfer(
            0x5A47250B0912E94d5D9ee2b0388459314be90038,
            _amount
        );
    }

    function giveBnbAllowances() public {
        IERC20(wbnb).safeApprove(unirouter, 0);
        IERC20(wbnb).safeApprove(unirouter, uint256(-1));
    }
}