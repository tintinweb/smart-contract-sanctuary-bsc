/**
 * @title Liquidity Generator
 * @dev LiquidGenerator contract
 *
 * @author - <AUREUM VICTORIA GROUP>
 * for the Securus Foundation
 *
 * SPDX-License-Identifier: GNU GPLv2
 **/

import "./StratManager.sol";
import "./FeeManager.sol";
import "./SafeERC20.sol";
import "./IRouter2.sol";
import "./Pausable.sol";

pragma solidity ^0.6.0;

contract LiquidGenerator is StratManager, FeeManager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address _vault) public {
        vault = _vault;
        _giveAllowances();
    }

    // performance fees
    function chargeFees() internal {
        uint256 FeeAmount = IERC20(wbnb).balanceOf(address(this)).div(100).mul(
            mainFee
        );

        IRouter2(unirouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                FeeAmount,
                0,
                wbnbToBtcbToWXSCRRoute,
                address(this),
                now
            );

        uint256 FeeAmountWXSCR = IERC20(wxscr).balanceOf(address(this));

        uint256 callFeeAmount = FeeAmountWXSCR.div(10000).mul(callFee);
        IERC20(wxscr).safeTransfer(msg.sender, callFeeAmount);

        uint256 TeamFeeAmount = FeeAmountWXSCR.div(10000).mul(TeamFee);
        IERC20(wxscr).safeTransfer(teamVault, TeamFeeAmount);
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        uint256 LP1 = IERC20(wbnb)
            .balanceOf(address(this))
            .div(100)
            .mul(lp1PercentBuy)
            .div(2);
        uint256 LP2 = IERC20(wbnb)
            .balanceOf(address(this))
            .div(100)
            .mul(lp2PercentBuy)
            .div(2);
        uint256 LP3 = IERC20(wbnb)
            .balanceOf(address(this))
            .div(100)
            .mul(lp3PercentBuy)
            .div(2);
        uint256 LP4 = IERC20(wbnb)
            .balanceOf(address(this))
            .div(100)
            .mul(lp4PercentBuy)
            .div(2);
        uint256 LP5 = IERC20(wbnb)
            .balanceOf(address(this))
            .div(100)
            .mul(lp5PercentBuy)
            .div(2);
        uint256 LP6 = IERC20(wbnb)
            .balanceOf(address(this))
            .div(100)
            .mul(lp6PercentBuy)
            .div(2);
        uint256 LP7 = IERC20(wbnb)
            .balanceOf(address(this))
            .div(100)
            .mul(lp7PercentBuy)
            .div(2);

        // LP 1 wbnb - wxscr
        if (lp1PercentBuy > 0) {
            // has wbnb
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP1,
                    0,
                    wbnbToWXSCRRoute,
                    address(this),
                    now
                );

            uint256 lp0Bal = IERC20(wbnb).balanceOf(address(this));
            uint256 lp1Bal = IERC20(wxscr).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                wbnb,
                wxscr,
                lp0Bal,
                lp1Bal,
                1,
                1,
                address(this),
                now
            );
        }

        //LP 2 btcb - wxscr
        if (lp2PercentBuy > 0) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP2,
                    0,
                    wbnbToBtcbRoute,
                    address(this),
                    now
                );
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP2,
                    0,
                    wbnbToBtcbToWXSCRRoute,
                    address(this),
                    now
                );

            uint256 lp2Bal = IERC20(btcb).balanceOf(address(this));
            uint256 lp3Bal = IERC20(wxscr).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                btcb,
                wxscr,
                lp2Bal,
                lp3Bal,
                1,
                1,
                address(this),
                now
            );
        }

        //LP 3 busd - wxscr
        if (lp3PercentBuy > 0) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP3,
                    0,
                    wbnbToBusdRoute,
                    address(this),
                    now
                );
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP3,
                    0,
                    wbnbToBusdToWXSCRRoute,
                    address(this),
                    now
                );

            uint256 lp4Bal = IERC20(busd).balanceOf(address(this));
            uint256 lp5Bal = IERC20(wxscr).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                busd,
                wxscr,
                lp4Bal,
                lp5Bal,
                1,
                1,
                address(this),
                now
            );
        }

        //LP 4 eth - wxscr
        if (lp4PercentBuy > 0) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP4,
                    0,
                    wbnbToEthRoute,
                    address(this),
                    now
                );
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP4,
                    0,
                    wbnbToEthToWXSCRRoute,
                    address(this),
                    now
                );

            uint256 lp6Bal = IERC20(eth).balanceOf(address(this));
            uint256 lp7Bal = IERC20(wxscr).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                eth,
                wxscr,
                lp6Bal,
                lp7Bal,
                1,
                1,
                address(this),
                now
            );
        }

        //LP 5 bifi - wxscr
        if (lp5PercentBuy > 0) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP5,
                    0,
                    wbnbToBifiRoute,
                    address(this),
                    now
                );
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP5,
                    0,
                    wbnbToBifiToWXSCRRoute,
                    address(this),
                    now
                );

            uint256 lp8Bal = IERC20(bifi).balanceOf(address(this));
            uint256 lp9Bal = IERC20(wxscr).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                bifi,
                wxscr,
                lp8Bal,
                lp9Bal,
                1,
                1,
                address(this),
                now
            );
        }

        //LP 6 usdt - wxscr
        if (lp6PercentBuy > 0) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP6,
                    0,
                    wbnbToUsdtRoute,
                    address(this),
                    now
                );
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP6,
                    0,
                    wbnbToUsdtToWXSCRRoute,
                    address(this),
                    now
                );

            uint256 lp10Bal = IERC20(usdt).balanceOf(address(this));
            uint256 lp11Bal = IERC20(wxscr).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                usdt,
                wxscr,
                lp10Bal,
                lp11Bal,
                1,
                1,
                address(this),
                now
            );
        }

        //LP 7 bsw - wxscr
        if (lp7PercentBuy > 0) {
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP7,
                    0,
                    wbnbToBswRoute,
                    address(this),
                    now
                );
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    LP7,
                    0,
                    wbnbToBswToWXSCRRoute,
                    address(this),
                    now
                );

            uint256 lp12Bal = IERC20(bsw).balanceOf(address(this));
            uint256 lp13Bal = IERC20(wxscr).balanceOf(address(this));
            IRouter2(unirouter).addLiquidity(
                bsw,
                wxscr,
                lp12Bal,
                lp13Bal,
                1,
                1,
                address(this),
                now
            );
        }
    }

    // send the LPs to Vault
    function transferToVault() internal {
        uint256 LPAmount_WXSCR_WBNB = IERC20(WXSCR_WBNB_LP_Token).balanceOf(
            address(this)
        );
        if (LPAmount_WXSCR_WBNB > 0) {
            IERC20(WXSCR_WBNB_LP_Token).safeTransfer(
                vault,
                LPAmount_WXSCR_WBNB
            );
        }

        uint256 LPAmount_WXSCR_BTCB = IERC20(WXSCR_BTCB_LP_Token).balanceOf(
            address(this)
        );
        if (LPAmount_WXSCR_BTCB > 0) {
            IERC20(WXSCR_BTCB_LP_Token).safeTransfer(
                vault,
                LPAmount_WXSCR_BTCB
            );
        }

        uint256 LPAmount_WXSCR_BUSD = IERC20(WXSCR_BUSD_LP_Token).balanceOf(
            address(this)
        );
        if (LPAmount_WXSCR_BUSD > 0) {
            IERC20(WXSCR_BUSD_LP_Token).safeTransfer(
                vault,
                LPAmount_WXSCR_BUSD
            );
        }

        uint256 LPAmount_WXSCR_ETH = IERC20(WXSCR_ETH_LP_Token).balanceOf(
            address(this)
        );
        if (LPAmount_WXSCR_ETH > 0) {
            IERC20(WXSCR_ETH_LP_Token).safeTransfer(vault, LPAmount_WXSCR_ETH);
        }

        uint256 LPAmount_WXSCR_BIFI = IERC20(WXSCR_BIFI_LP_Token).balanceOf(
            address(this)
        );
        if (LPAmount_WXSCR_BIFI > 0) {
            IERC20(WXSCR_BIFI_LP_Token).safeTransfer(
                vault,
                LPAmount_WXSCR_BIFI
            );
        }

        uint256 LPAmount_WXSCR_USDT = IERC20(WXSCR_USDT_LP_Token).balanceOf(
            address(this)
        );
        if (LPAmount_WXSCR_USDT > 0) {
            IERC20(WXSCR_USDT_LP_Token).safeTransfer(
                vault,
                LPAmount_WXSCR_USDT
            );
        }

        uint256 LPAmount_WXSCR_BSW = IERC20(WXSCR_BSW_LP_Token).balanceOf(
            address(this)
        );
        if (LPAmount_WXSCR_BSW > 0) {
            IERC20(WXSCR_BSW_LP_Token).safeTransfer(vault, LPAmount_WXSCR_BSW);
        }
    }

    // harvest
    function harvest() external whenNotPaused {
        uint256 _bal = IERC20(wbnb).balanceOf(address(this));

        if (_bal > minBnbBal) {
            chargeFees();
            addLiquidity();
            transferToVault();
        }
    }

    // pause harvest
    function pause() public onlyOwner {
        _removeAllowances();
        _pause();
    }

    // unpause harvest
    function unpause() external onlyOwner {
        _giveAllowances();
        _unpause();
    }

    function _giveAllowances() internal {
        IERC20(wbnb).safeApprove(unirouter, 0);
        IERC20(wbnb).safeApprove(unirouter, uint256(-1));

        IERC20(btcb).safeApprove(unirouter, 0);
        IERC20(btcb).safeApprove(unirouter, uint256(-1));

        IERC20(busd).safeApprove(unirouter, 0);
        IERC20(busd).safeApprove(unirouter, uint256(-1));

        IERC20(eth).safeApprove(unirouter, 0);
        IERC20(eth).safeApprove(unirouter, uint256(-1));

        IERC20(bifi).safeApprove(unirouter, 0);
        IERC20(bifi).safeApprove(unirouter, uint256(-1));

        IERC20(bsw).safeApprove(unirouter, 0);
        IERC20(bsw).safeApprove(unirouter, uint256(-1));

        IERC20(usdt).safeApprove(unirouter, 0);
        IERC20(usdt).safeApprove(unirouter, uint256(-1));

        IERC20(wxscr).safeApprove(unirouter, 0);
        IERC20(wxscr).safeApprove(unirouter, uint256(-1));
    }

    function _removeAllowances() internal {
        IERC20(wxscr).safeApprove(unirouter, 0);
        IERC20(busd).safeApprove(unirouter, 0);
        IERC20(btcb).safeApprove(unirouter, 0);
        IERC20(wbnb).safeApprove(unirouter, 0);
        IERC20(eth).safeApprove(unirouter, 0);
        IERC20(bifi).safeApprove(unirouter, 0);
        IERC20(bsw).safeApprove(unirouter, 0);
        IERC20(usdt).safeApprove(unirouter, 0);
    }

    /**
     * @dev Function to exit the system. The vault will withdraw the required tokens
     * from the strategy and pay it to the vault.
     */
    function withdraw(address _token, uint256 _bal) public onlyOwner {
        IERC20(_token).transfer(vault, _bal);
    }

    function withdrawWBNB() public onlyOwner {
        uint256 _bal = IERC20(wbnb).balanceOf(address(this));
        IERC20(wbnb).transfer(vault, _bal);
    }
}