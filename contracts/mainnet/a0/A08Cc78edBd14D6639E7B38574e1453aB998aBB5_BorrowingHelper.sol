// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import "../interfaces/DexAggregatorInterface.sol";
import "../interfaces/OpenLevInterface.sol";
import "../IOPBorrowing.sol";
import "../OPBorrowingLib.sol";
import "../libraries/DexData.sol";
import "../libraries/Utils.sol";

contract BorrowingHelper {
    using DexData for bytes;

    constructor() {}

    enum BorrowingStatus {
        HEALTHY, // Do nothing
        UPDATING_PRICE, // Need update price
        WAITING, // Waiting for 1 min before liquidate
        LIQUIDATING, // Can liquidate
        NOP // No position
    }

    struct BorrowingStatVars {
        uint256 collateral;
        uint256 lastUpdateTime;
        BorrowingStatus status;
    }

    struct CollateralVars {
        uint256 collateral;
        uint256 borrowing;
        uint256 collateralRatio;
    }


    uint internal constant RATIO_DENOMINATOR = 10000;

    function collateralRatios(
        IOPBorrowing borrowing,
        uint16[] calldata marketIds,
        address[] calldata borrowers,
        bool[] calldata collateralIndexes
    ) external view returns (uint[] memory results) {
        results = new uint[](marketIds.length);
        for (uint i = 0; i < marketIds.length; i++) {
            results[i] = borrowing.collateralRatio(marketIds[i], collateralIndexes[i], borrowers[i]);
        }
        return results;
    }

    function getBorrowingStat(IOPBorrowing borrowing, address borrower, uint16 marketId, bool collateralIndex) external returns (BorrowingStatVars memory) {
        BorrowingStatVars memory result;
        result.collateral = OPBorrowingStorage(address(borrowing)).activeCollaterals(borrower, marketId, collateralIndex);
        if (result.collateral == 0) {
            result.status = BorrowingStatus.NOP;
            return result;
        }
        if (borrowing.collateralRatio(marketId, collateralIndex, borrower) >= 10000) {
            result.status = BorrowingStatus.HEALTHY;
            return result;
        }

        LPoolInterface borrowPool;
        address collateralToken;
        address borrowToken;
        bytes memory dexData;
        {
            (LPoolInterface pool0, LPoolInterface pool1, address token0, address token1, uint32 dex) = OPBorrowingStorage(address(borrowing)).markets(marketId);
            borrowPool = collateralIndex ? pool0 : pool1;
            collateralToken = collateralIndex ? token1 : token0;
            borrowToken = collateralIndex ? token0 : token1;
            dexData = OPBorrowingLib.uint32ToBytes(dex);
            (,,,, result.lastUpdateTime) = OPBorrowingStorage(address(borrowing)).dexAgg().getPriceCAvgPriceHAvgPrice(
                collateralToken,
                borrowToken,
                60,
                dexData
            );
            if (dexData.isUniV2Class()) {
                OPBorrowingStorage(address(borrowing)).openLev().updatePrice(marketId, dexData);
            }
        }
        uint collateral = OPBorrowingStorage(address(borrowing)).activeCollaterals(borrower, marketId, collateralIndex);
        uint borrowed = borrowPool.borrowBalanceCurrent(borrower);
        (uint collateralRatio, , , , , , , , , ,) = OPBorrowingStorage(address(borrowing)).marketsConf(marketId);
        uint maxPrice;
        uint denominator;
        {
            DexAggregatorInterface dexAgg = OPBorrowingStorage(address(borrowing)).dexAgg();
            (uint price, uint cAvgPrice, uint hAvgPrice, uint8 decimals,) = dexAgg.getPriceCAvgPriceHAvgPrice(collateralToken, borrowToken, 60, dexData);
            maxPrice = Utils.maxOf(Utils.maxOf(price, cAvgPrice), hAvgPrice);
            denominator = (10 ** uint(decimals));
        }
        if ((((collateral * maxPrice) / denominator) * collateralRatio) / RATIO_DENOMINATOR < borrowed) {
            result.status = BorrowingStatus.LIQUIDATING;
            return result;
        }
        if (!dexData.isUniV2Class() || block.timestamp < result.lastUpdateTime + 60) {
            result.status = BorrowingStatus.WAITING;
            return result;
        }
        result.status = BorrowingStatus.UPDATING_PRICE;
        return result;
    }

    function getBorrowersCollateral(
        IOPBorrowing borrowing,
        uint16 marketId,
        address[] calldata borrowers,
        bool[] calldata collateralIndexes
    ) external view returns (CollateralVars[] memory results) {
        results = new CollateralVars[](borrowers.length);
        (LPoolInterface pool0, LPoolInterface pool1, , ,) = OPBorrowingStorage(address(borrowing)).markets(marketId);
        for (uint i = 0; i < borrowers.length; i++) {
            CollateralVars memory item;
            item.collateral = OPBorrowingStorage(address(borrowing)).activeCollaterals(borrowers[i], marketId, collateralIndexes[i]);
            if (item.collateral > 0) {
                item.collateralRatio = borrowing.collateralRatio(marketId, collateralIndexes[i], borrowers[i]);
                LPoolInterface borrowPool = collateralIndexes[i] ? pool0 : pool1;
                item.borrowing = borrowPool.borrowBalanceCurrent(borrowers[i]);
            }
            results[i] = item;
        }
        return results;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

library Utils {
    uint private constant FEE_RATE_PRECISION = 10 ** 6;

    function toAmountBeforeTax(uint256 amount, uint24 feeRate) internal pure returns (uint) {
        uint denominator = FEE_RATE_PRECISION - feeRate;
        uint numerator = amount * FEE_RATE_PRECISION + denominator - 1;
        return numerator / denominator;
    }

    function toAmountAfterTax(uint256 amount, uint24 feeRate) internal pure returns (uint) {
        return (amount * (FEE_RATE_PRECISION - feeRate)) / FEE_RATE_PRECISION;
    }

    function minOf(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    function maxOf(uint a, uint b) internal pure returns (uint) {
        return a > b ? a : b;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TransferHelper
 * @dev Wrappers around ERC20 operations that returns the value received by recipent and the actual allowance of approval.
 * To use this library you can add a `using TransferHelper for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library TransferHelper {
    function safeTransfer(IERC20 _token, address _to, uint256 _amount) internal {
        if (_amount > 0) {
            bool success;
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
            require(success, "TF");
        }
    }

    function safeTransferFrom(IERC20 _token, address _from, address _to, uint256 _amount) internal returns (uint256 amountReceived) {
        if (_amount > 0) {
            bool success;
            uint256 balanceBefore = _token.balanceOf(_to);
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
            require(success, "TFF");
            uint256 balanceAfter = _token.balanceOf(_to);
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _amount) internal {
        bool success;
        if (_token.allowance(address(this), _spender) != 0) {
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, 0));
            require(success, "AF");
        }
        (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, _amount));
        require(success, "AF");
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

/// @dev DexDataFormat addPair = byte(dexID) + bytes3(feeRate) + bytes(arrayLength) + byte3[arrayLength](trasferFeeRate Lpool <-> openlev)
/// + byte3[arrayLength](transferFeeRate openLev -> Dex) + byte3[arrayLength](Dex -> transferFeeRate openLev)
/// exp: 0x0100000002011170000000011170000000011170000000
/// DexDataFormat dexdata = byte(dexID）+ bytes3(feeRate) + byte(arrayLength) + path
/// uniV2Path = bytes20[arraylength](address)
/// uniV3Path = bytes20(address)+ bytes20[arraylength-1](address + fee)
library DexData {
    // in byte
    uint constant DEX_INDEX = 0;
    uint constant FEE_INDEX = 1;
    uint constant ARRYLENTH_INDEX = 4;
    uint constant TRANSFERFEE_INDEX = 5;
    uint constant PATH_INDEX = 5;
    uint constant FEE_SIZE = 3;
    uint constant ADDRESS_SIZE = 20;
    uint constant NEXT_OFFSET = ADDRESS_SIZE + FEE_SIZE;

    uint8 constant DEX_UNIV2 = 1;
    uint8 constant DEX_UNIV3 = 2;
    uint8 constant DEX_PANCAKE = 3;
    uint8 constant DEX_SUSHI = 4;
    uint8 constant DEX_MDEX = 5;
    uint8 constant DEX_TRADERJOE = 6;
    uint8 constant DEX_SPOOKY = 7;
    uint8 constant DEX_QUICK = 8;
    uint8 constant DEX_SHIBA = 9;
    uint8 constant DEX_APE = 10;
    uint8 constant DEX_PANCAKEV1 = 11;
    uint8 constant DEX_BABY = 12;
    uint8 constant DEX_MOJITO = 13;
    uint8 constant DEX_KU = 14;
    uint8 constant DEX_BISWAP = 15;
    uint8 constant DEX_VVS = 20;

    function toDex(bytes memory data) internal pure returns (uint8) {
        require(data.length >= FEE_INDEX, "DexData: toDex wrong data format");
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
        }
        return temp;
    }

    function toFee(bytes memory data) internal pure returns (uint24) {
        require(data.length >= ARRYLENTH_INDEX, "DexData: toFee wrong data format");
        uint temp;
        assembly {
            temp := mload(add(data, add(0x20, FEE_INDEX)))
        }
        return uint24(temp >> (256 - (ARRYLENTH_INDEX - FEE_INDEX) * 8));
    }

    function toDexDetail(bytes memory data) internal pure returns (uint32) {
        require(data.length >= FEE_INDEX, "DexData: toDexDetail wrong data format");
        if (isUniV2Class(data)) {
            uint8 temp;
            assembly {
                temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
            }
            return uint32(temp);
        } else {
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, DEX_INDEX)))
            }
            return uint32(temp >> (256 - ((FEE_SIZE + FEE_INDEX) * 8)));
        }
    }

    function isUniV2Class(bytes memory data) internal pure returns (bool) {
        return toDex(data) != DEX_UNIV3;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface XOLEInterface {
    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface OpenLevInterface {
    struct Market {
        // Market info
        address pool0; // Lending Pool 0
        address pool1; // Lending Pool 1
        address token0; // Lending Token 0
        address token1; // Lending Token 1
        uint16 marginLimit; // Margin ratio limit for specific trading pair. Two decimal in percentage, ex. 15.32% => 1532
        uint16 feesRate; // feesRate 30=>0.3%
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint256 pool0Insurance; // Insurance balance for token 0
        uint256 pool1Insurance; // Insurance balance for token 1
    }

    function markets(uint16 marketId) external view returns (Market memory market);

    function taxes(uint16 marketId, address token, uint index) external view returns (uint24);

    function getMarketSupportDexs(uint16 marketId) external view returns (uint32[] memory);

    function updatePrice(uint16 marketId, bytes memory dexData) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface OPBuyBackInterface {
    function transferIn(address token, uint amount) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface LPoolInterface {
    function underlying() external view returns (address);

    function totalBorrows() external view returns (uint);

    function borrowBalanceCurrent(address account) external view returns (uint);

    function borrowBalanceStored(address account) external view returns (uint);

    function borrowBehalf(address borrower, uint borrowAmount) external;

    function repayBorrowBehalf(address borrower, uint repayAmount) external;

    function repayBorrowEndByOpenLev(address borrower, uint repayAmount) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface DexAggregatorInterface {
    function getPrice(address desToken, address quoteToken, bytes memory data) external view returns (uint256 price, uint8 decimals);

    function getPriceCAvgPriceHAvgPrice(
        address desToken,
        address quoteToken,
        uint32 secondsAgo,
        bytes memory dexData
    ) external view returns (uint256 price, uint256 cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);

    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external returns (bool);

    function getToken0Liquidity(address token0, address token1, bytes memory dexData) external view returns (uint);

    function getPairLiquidity(address token0, address token1, bytes memory dexData) external view returns (uint token0Liq, uint token1Liq);

    function buy(
        address buyToken,
        address sellToken,
        uint24 buyTax,
        uint24 sellTax,
        uint buyAmount,
        uint maxSellAmount,
        bytes memory data
    ) external returns (uint sellAmount);

    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

interface ControllerInterface {
    function collBorrowAllowed(uint marketId, address borrower, bool collateralIndex) external view returns (bool);

    function collRepayAllowed(uint marketId) external view returns (bool);

    function collRedeemAllowed(uint marketId) external view returns (bool);

    function collLiquidateAllowed(uint marketId) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

import "./interfaces/LPoolInterface.sol";
import "./libraries/TransferHelper.sol";
import "./common/IWETH.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

library OPBorrowingLib {
    using TransferHelper for IERC20;

    function transferIn(address from, IERC20 token, address weth, uint amount) internal returns (uint) {
        if (address(token) == weth) {
            IWETH(weth).deposit{ value: msg.value }();
            return msg.value;
        } else {
            return token.safeTransferFrom(from, address(this), amount);
        }
    }

    function doTransferOut(address to, IERC20 token, address weth, uint amount) internal {
        if (address(token) == weth) {
            IWETH(weth).withdraw(amount);
            (bool success, ) = to.call{ value: amount }("");
            require(success, "Transfer failed");
        } else {
            token.safeTransfer(to, amount);
        }
    }

    function borrowBehalf(LPoolInterface pool, address token, address account, uint amount) internal returns (uint) {
        uint balance = balanceOf(IERC20(token));
        pool.borrowBehalf(account, amount);
        return balanceOf(IERC20(token)) - (balance);
    }

    function borrowCurrent(LPoolInterface pool, address account) internal view returns (uint256) {
        return pool.borrowBalanceCurrent(account);
    }

    function borrowStored(LPoolInterface pool, address account) internal view returns (uint256) {
        return pool.borrowBalanceStored(account);
    }

    function repay(LPoolInterface pool, address account, uint amount) internal {
        pool.repayBorrowBehalf(account, amount);
    }

    function balanceOf(IERC20 token) internal view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function decimals(address token) internal view returns (uint256) {
        return ERC20(token).decimals();
    }

    function safeApprove(IERC20 token, address spender, uint256 amount) internal {
        token.safeApprove(spender, amount);
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        token.safeTransfer(to, amount);
    }

    function amountToShare(uint amount, uint totalShare, uint reserve) internal pure returns (uint share) {
        share = totalShare > 0 && reserve > 0 ? (totalShare * amount) / reserve : amount;
    }

    function shareToAmount(uint share, uint totalShare, uint reserve) internal pure returns (uint amount) {
        if (totalShare > 0 && reserve > 0) {
            amount = (reserve * share) / totalShare;
        }
    }

    function uint32ToBytes(uint32 u) internal pure returns (bytes memory) {
        if (u < 256) {
            return abi.encodePacked(uint8(u));
        }
        return abi.encodePacked(u);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.17;

import "./interfaces/LPoolInterface.sol";
import "./interfaces/OpenLevInterface.sol";
import "./interfaces/ControllerInterface.sol";
import "./interfaces/DexAggregatorInterface.sol";
import "./interfaces/XOLEInterface.sol";
import "./interfaces/OPBuyBackInterface.sol";

contract OPBorrowingStorage {
    event NewMarket(uint16 marketId, LPoolInterface pool0, LPoolInterface pool1, address token0, address token1, uint32 dex, uint token0Liq, uint token1Liq);

    event Borrow(address indexed borrower, uint16 marketId, bool collateralIndex, uint collateral, uint borrow, uint borrowFees);

    event Repay(address indexed borrower, uint16 marketId, bool collateralIndex, uint repayAmount, uint collateral);

    event Redeem(address indexed borrower, uint16 marketId, bool collateralIndex, uint collateral);

    event Liquidate(
        address indexed borrower,
        uint16 marketId,
        bool collateralIndex,
        address liquidator,
        uint collateralDecrease,
        uint repayAmount,
        uint outstandingAmount,
        uint liquidateFees,
        uint token0Price
    );

    event NewLiquidity(uint16 marketId, uint oldToken0Liq, uint oldToken1Liq, uint newToken0Liq, uint newToken1Liq);

    event NewMarketConf(
        uint16 marketId,
        uint16 collateralRatio,
        uint16 maxLiquidityRatio,
        uint16 borrowFeesRatio,
        uint16 insuranceRatio,
        uint16 poolReturnsRatio,
        uint16 liquidateFeesRatio,
        uint16 liquidatorReturnsRatio,
        uint16 liquidateInsuranceRatio,
        uint16 liquidatePoolReturnsRatio,
        uint16 liquidateMaxLiquidityRatio,
        uint16 twapDuration
    );

    struct Market {
        LPoolInterface pool0; // pool0 address
        LPoolInterface pool1; // pool1 address
        address token0; // token0 address
        address token1; // token1 address
        uint32 dex; // decentralized exchange
    }

    struct MarketConf {
        uint16 collateralRatio; //  the collateral ratio, 6000 => 60%
        uint16 maxLiquidityRatio; // the maximum pool's total borrowed cannot be exceeded dex liquidity*ratio, 1000 => 10%
        uint16 borrowFeesRatio; // the borrowing fees ratio, 30 => 0.3%
        uint16 insuranceRatio; // the insurance percentage of the borrowing fees, 3000 => 30%
        uint16 poolReturnsRatio; // the pool's returns percentage of the borrowing fees, 3000 => 30%
        uint16 liquidateFeesRatio; // the liquidation fees ratio, 100 => 1%
        uint16 liquidatorReturnsRatio; // the liquidator returns percentage of the liquidation fees, 3000 => 30%
        uint16 liquidateInsuranceRatio; // the insurance percentage of the liquidation fees, 3000 => 30%
        uint16 liquidatePoolReturnsRatio; // the pool's returns percentage of the liquidation fees, 3000 => 30%
        uint16 liquidateMaxLiquidityRatio; // the maximum liquidation amount cannot be exceeded dex liquidity*ratio, 1000=> 10%
        uint16 twapDuration; // the TWAP duration, 60 => 60s
    }

    struct Liquidity {
        uint token0Liq; // the token0 liquidity
        uint token1Liq; // the token1 liquidity
    }

    struct Insurance {
        uint insurance0; // the token0 insurance
        uint insurance1; // the token1 insurance
    }

    struct LiquidationConf {
        uint128 liquidatorXOLEHeld; //  the minimum amount of xole held by liquidator
        uint8 priceDiffRatio; // the maximum ratio of real price diff TWAP, 10 => 10%
        OPBuyBackInterface buyBack; // the ole buyback contract address
    }

    uint internal constant RATIO_DENOMINATOR = 10000;

    address public immutable wETH;

    OpenLevInterface public immutable openLev;

    ControllerInterface public immutable controller;

    DexAggregatorInterface public immutable dexAgg;

    XOLEInterface public immutable xOLE;

    // mapping of marketId to market info
    mapping(uint16 => Market) public markets;

    // mapping of marketId to market config
    mapping(uint16 => MarketConf) public marketsConf;

    // mapping of borrower, marketId, collateralIndex to collateral shares
    mapping(address => mapping(uint16 => mapping(bool => uint))) public activeCollaterals;

    // mapping of marketId to insurances
    mapping(uint16 => Insurance) public insurances;

    // mapping of marketId to time weighted average liquidity
    mapping(uint16 => Liquidity) public twaLiquidity;

    // mapping of token address to total shares
    mapping(address => uint) public totalShares;

    MarketConf public marketDefConf;

    LiquidationConf public liquidationConf;

    constructor(OpenLevInterface _openLev, ControllerInterface _controller, DexAggregatorInterface _dexAgg, XOLEInterface _xOLE, address _wETH) {
        openLev = _openLev;
        controller = _controller;
        dexAgg = _dexAgg;
        xOLE = _xOLE;
        wETH = _wETH;
    }
}

interface IOPBorrowing {
    function initialize(OPBorrowingStorage.MarketConf memory _marketDefConf, OPBorrowingStorage.LiquidationConf memory _liquidationConf) external;

    // only controller
    function addMarket(uint16 marketId, LPoolInterface pool0, LPoolInterface pool1, bytes memory dexData) external;

    /*** Borrower Functions ***/
    function borrow(uint16 marketId, bool collateralIndex, uint collateral, uint borrowing) external payable;

    function repay(uint16 marketId, bool collateralIndex, uint repayAmount, bool isRedeem) external payable returns (uint redeemShare);

    function redeem(uint16 marketId, bool collateralIndex, uint collateral) external;

    function liquidate(uint16 marketId, bool collateralIndex, address borrower) external;

    function collateralRatio(uint16 marketId, bool collateralIndex, address borrower) external view returns (uint current);

    /*** Admin Functions ***/
    function migrateOpenLevMarkets(uint16 from, uint16 to) external;

    function setTwaLiquidity(uint16[] calldata marketIds, OPBorrowingStorage.Liquidity[] calldata liquidity) external;

    function setMarketConf(uint16 marketId, OPBorrowingStorage.MarketConf calldata _marketConf) external;

    function setMarketDex(uint16 marketId, uint32 dex) external;

    function moveInsurance(uint16 marketId, bool tokenIndex, address to, uint moveShare) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `from` to `to`.
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