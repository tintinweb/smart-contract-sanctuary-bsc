// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "./UniV2ClassDex.sol";
import "../DexAggregatorInterface.sol";
import "../../lib/DexData.sol";
import "../../lib/Utils.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../DelegateInterface.sol";
import "../../Adminable.sol";

/// @title Swap logic on BSC
/// @author OpenLeverage
/// @notice Use this contract to swap tokens.
/// @dev Routers for different swap requests.
contract BscDexAggregatorV1 is DelegateInterface, Adminable, DexAggregatorInterface, UniV2ClassDex {
    using DexData for bytes;
    using SafeMath for uint;

    mapping(IUniswapV2Pair => V2PriceOracle) public uniV2PriceOracle;
    IUniswapV2Factory public pancakeFactory;
    address public openLev;
    uint8 private constant priceDecimals = 24;

    mapping(uint8 => DexInfo) public dexInfo;

    //pancakeFactory: 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    function initialize(
        IUniswapV2Factory _pancakeFactory,
        address _unsedFactory
    ) public {
        require(msg.sender == admin, "Not admin");
        // Shh - currently unused
        _unsedFactory;
        pancakeFactory = _pancakeFactory;
        dexInfo[DexData.DEX_PANCAKE] = DexInfo(_pancakeFactory, 25);
    }

    /// @notice Save factories of the dex.
    /// @param dexName Index of Dex. find list of dex in contracts/lib/DexData.sol.
    /// @param factoryAddr Factory address of Different dex forked from uniswap.
    /// @param fees Swap fee collects by dex.
    function setDexInfo(uint8[] memory dexName, IUniswapV2Factory[] memory factoryAddr, uint16[] memory fees) external override onlyAdmin {
        require(dexName.length == factoryAddr.length && dexName.length == fees.length, 'EOR');
        for (uint i = 0; i < dexName.length; i++) {
            dexInfo[dexName[i]] = DexInfo(factoryAddr[i], fees[i]);
        }
    }

    /// @dev SetOpenlev address to update dex price
    function setOpenLev(address _openLev) external onlyAdmin {
        require(address(0) != _openLev, '0x');
        openLev = _openLev;
    }

    /// @notice Sell tokens 
    /// @dev Sell exact amount of token with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param sellAmount Exact amount to sell
    /// @param minBuyAmount minmum amount of token to receive.
    /// @param data Dex to use for swap
    /// @return buyAmount Exact Amount bought
    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external override returns (uint buyAmount){
        address payer = msg.sender;
        buyAmount = uniClassSell(dexInfo[data.toDex()], buyToken, sellToken, sellAmount, minBuyAmount, payer, payer);
    }

    /// @notice Sell tokens 
    /// @dev Sell exact amount of token through path
    /// @param sellAmount Exact amount to sell
    /// @param minBuyAmount minmum amount of token to receive.
    /// @param data Dex to use for swap and path of the swap
    /// @return buyAmount Exact amount bought
    function sellMul(uint sellAmount, uint minBuyAmount, bytes memory data) external override returns (uint buyAmount){
        buyAmount = uniClassSellMul(dexInfo[data.toDex()], sellAmount, minBuyAmount, data.toUniV2Path());
    }

    /// @notice Buy tokens 
    /// @dev Buy exact amount of token with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param buyTax Tax applyed by buyToken while transfer from Dex pair
    /// @param sellTax Tax applyed by sellToken while transfer into Dex pair
    /// @param buyAmount Exact amount to buy
    /// @param maxSellAmount maximum amount of token to receive.
    /// @param data Dex to use for swap
    /// @return sellAmount Exact amount sold
    function buy(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, uint maxSellAmount, bytes memory data) external override returns (uint sellAmount){
        sellAmount = uniClassBuy(dexInfo[data.toDex()], buyToken, sellToken, buyAmount, maxSellAmount, buyTax, sellTax);
    }

    /// @notice Calculate amount of token to buy 
    /// @dev Calculate exact amount of token to buy with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param buyTax Tax applyed by buyToken while transfer from Dex pair
    /// @param sellTax Tax applyed by sellToken while transfer into Dex pair
    /// @param sellAmount Exact amount to sell
    /// @param data Dex to use for swap
    /// @return buyAmount Amount of buyToken would bought
    function calBuyAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint sellAmount, bytes memory data) external view override returns (uint buyAmount) {
        sellAmount = Utils.toAmountAfterTax(sellAmount, sellTax);
        buyAmount = uniClassCalBuyAmount(dexInfo[data.toDex()], buyToken, sellToken, sellAmount);
        buyAmount = Utils.toAmountAfterTax(buyAmount, buyTax);
    }

    /// @notice Calculate amount of token to sell 
    /// @dev Calculate exact amount of token to sell with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param buyTax Tax applyed by buyToken while transfer from Dex pair
    /// @param sellTax Tax applyed by SellToken while transfer into Dex pair
    /// @param buyAmount Exact amount to buy
    /// @param data Dex to use for swap
    /// @return sellAmount Amount of sellToken would sold
    function calSellAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, bytes memory data) external view override returns (uint sellAmount){
        sellAmount = uniClassCalSellAmount(dexInfo[data.toDex()], buyToken, sellToken, buyAmount, buyTax, sellTax);
    }

    /// @notice Get price 
    /// @dev Get current price of desToken / quoteToken
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param data Dex to use for swap
    function getPrice(address desToken, address quoteToken, bytes memory data) external view override returns (uint256 price, uint8 decimals){
        decimals = priceDecimals;
        price = uniClassGetPrice(dexInfo[data.toDex()].factory, desToken, quoteToken, decimals);
    }

    /// @dev Get average price of desToken / quoteToken in the last period of time
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param secondsAgo Time period of the average
    /// @param data Dex to use for swap
    function getAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory data) external view override returns (uint256 price, uint8 decimals, uint256 timestamp){
        require(data.isUniV2Class(), "unsupported dex");
        // Shh - currently unused
        secondsAgo;
        decimals = priceDecimals;
        address pair = getUniClassPair(desToken, quoteToken, dexInfo[data.toDex()].factory);
        V2PriceOracle memory priceOracle = uniV2PriceOracle[IUniswapV2Pair(pair)];
        (price, timestamp) = uniClassGetAvgPrice(desToken, quoteToken, priceOracle);
    }

    /// @notice Fet current and history price
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param secondsAgo not used on BSC
    /// @param dexData dex parameters
    /// @return price Real-time price
    /// @return cAvgPrice Current TWAP price
    /// @return hAvgPrice Historical TWAP price
    /// @return decimals Token price decimal
    /// @return timestamp Last TWAP price update timestamp 
    function getPriceCAvgPriceHAvgPrice(
        address desToken,
        address quoteToken,
        uint32 secondsAgo,
        bytes memory dexData
    ) external view override returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp){
        require(dexData.isUniV2Class(), "unsupported dex");
        secondsAgo;
        decimals = priceDecimals;
        address pair = getUniClassPair(desToken, quoteToken, dexInfo[dexData.toDex()].factory);
        V2PriceOracle memory priceOracle = uniV2PriceOracle[IUniswapV2Pair(pair)];
        (price, cAvgPrice, hAvgPrice, timestamp) = uniClassGetPriceCAvgPriceHAvgPrice(pair, priceOracle, desToken, quoteToken, decimals);
    }

    /// @dev Update Dex price if not updated over time window
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param timeWindow minmum time gap between two updates
    /// @param data dex parameters
    /// @return If updated
    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external override returns (bool){
        require(msg.sender == openLev, "Only openLev can update price");
        require(data.isUniV2Class(), "unsupported dex");
        address pair = getUniClassPair(desToken, quoteToken, dexInfo[data.toDex()].factory);
        V2PriceOracle memory priceOracle = uniV2PriceOracle[IUniswapV2Pair(pair)];
        (V2PriceOracle memory updatedPriceOracle, bool updated) = uniClassUpdatePriceOracle(pair, priceOracle, timeWindow, priceDecimals);
        if (updated) {
            uniV2PriceOracle[IUniswapV2Pair(pair)] = updatedPriceOracle;
        }
        return updated;
    }

    /// @dev Update UniV3 observations
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param data Dex parameters
    function updateV3Observation(address desToken, address quoteToken, bytes memory data) external pure override {
        // Shh - currently unused
        (desToken,quoteToken, data);
        revert("Not implemented");
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

library Utils{
    using SafeMath for uint;

    uint constant feeRatePrecision = 10**6;

    function toAmountBeforeTax(uint256 amount, uint24 feeRate) internal pure returns (uint){
        uint denominator = feeRatePrecision.sub(feeRate);
        uint numerator = amount.mul(feeRatePrecision).add(denominator).sub(1);
        return numerator / denominator;
    }

    function toAmountAfterTax(uint256 amount, uint24 feeRate) internal pure returns (uint){
        return amount.mul(feeRatePrecision.sub(feeRate)) / feeRatePrecision;
    }

    function minOf(uint a, uint b) internal pure returns (uint){
        return a < b ? a : b;
    }

    function maxOf(uint a, uint b) internal pure returns (uint){
        return a > b ? a : b;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title TransferHelper
 * @dev Wrappers around ERC20 operations that returns the value received by recipent and the actual allowance of approval.
 * To use this library you can add a `using TransferHelper for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
 library TransferHelper{
    // using SafeMath for uint;

    function safeTransfer(IERC20 _token, address _to, uint _amount) internal returns (uint amountReceived){
        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeTransferFrom(IERC20 _token, address _from, address _to, uint _amount) internal returns (uint amountReceived){
        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
            // _token.transferFrom(_from, _to, _amount);
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TFF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
        bool success;
        if (_token.allowance(address(this), _spender) != 0){
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, 0));
            require(success, "AF");
        }
        (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, _amount));
        require(success, "AF");

        return _token.allowance(address(this), _spender);
    }

    // function safeIncreaseAllowance(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
    //     uint256 allowanceBefore = _token.allowance(address(this), _spender);
    //     uint256 allowanceNew = allowanceBefore.add(_amount);
    //     uint256 allowanceAfter = safeApprove(_token, _spender, allowanceNew);
    //     require(allowanceAfter == allowanceNew, "AF");
    //     return allowanceNew;
    // }

    // function safeDecreaseAllowance(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
    //     uint256 allowanceBefore = _token.allowance(address(this), _spender);
    //     uint256 allowanceNew = allowanceBefore.sub(_amount);
    //     uint256 allowanceAfter = safeApprove(_token, _spender, allowanceNew);
    //     require(allowanceAfter == allowanceNew, "AF");
    //     return allowanceNew;
    // }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

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
    uint8 constant DEX_BISWAP=15;

    struct V3PoolData {
        address tokenA;
        address tokenB;
        uint24 fee;
    }

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
        require (data.length >= FEE_INDEX, "DexData: toDexDetail wrong data format");
        if (isUniV2Class(data)){
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

    function toArrayLength(bytes memory data) internal pure returns(uint8 length){
        require(data.length >= TRANSFERFEE_INDEX, "DexData: toArrayLength wrong data format");

        assembly {
            length := byte(0, mload(add(data, add(0x20, ARRYLENTH_INDEX))))
        }
    }

    // only for add pair
    function toTransferFeeRates(bytes memory data) internal pure returns (uint24[] memory transferFeeRates){
        uint8 length = toArrayLength(data) * 3;
        uint start = TRANSFERFEE_INDEX;

        transferFeeRates = new uint24[](length);
        for (uint i = 0; i < length; i++){
            // use default value
            if (data.length <= start){
                transferFeeRates[i] = 0;
                continue;
            }

            // use input value
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, start)))
            }

            transferFeeRates[i] = uint24(temp >> (256 - FEE_SIZE * 8));
            start += FEE_SIZE;
        }
    }

    function toUniV2Path(bytes memory data) internal pure returns (address[] memory path) {
        uint8 length = toArrayLength(data);
        uint end =  PATH_INDEX + ADDRESS_SIZE * length;
        require(data.length >= end, "DexData: toUniV2Path wrong data format");

        uint start = PATH_INDEX;
        path = new address[](length);
        for (uint i = 0; i < length; i++) {
            uint startIndex = start + ADDRESS_SIZE * i;
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, startIndex)))
            }

            path[i] = address(temp >> (256 - ADDRESS_SIZE * 8));
        }
    }

    function isUniV2Class(bytes memory data) internal pure returns(bool){
        return toDex(data) != DEX_UNIV3;
    }

    function toUniV3Path(bytes memory data) internal pure returns (V3PoolData[] memory path) {
        uint8 length = toArrayLength(data);
        uint end = PATH_INDEX + (FEE_SIZE  + ADDRESS_SIZE) * length - FEE_SIZE;
        require(data.length >= end, "DexData: toUniV3Path wrong data format");
        require(length > 1, "DexData: toUniV3Path path too short");

        uint temp;
        uint index = PATH_INDEX;
        path = new V3PoolData[](length - 1);

        for (uint i = 0; i < length - 1; i++) {
            V3PoolData memory pool;

            // get tokenA
            if (i == 0) {
                assembly {
                    temp := mload(add(data, add(0x20, index)))
                }
                pool.tokenA = address(temp >> (256 - ADDRESS_SIZE * 8));
                index += ADDRESS_SIZE;
            }else{
                pool.tokenA = path[i-1].tokenB;
                index += NEXT_OFFSET;
            }

            // get TokenB
            assembly {
                temp := mload(add(data, add(0x20, index)))
            }

            uint tokenBAndFee = temp >> (256 - NEXT_OFFSET * 8);
            pool.tokenB = address(tokenBAndFee >> (FEE_SIZE * 8));
            pool.fee = uint24(tokenBAndFee - (tokenBAndFee << (FEE_SIZE * 8)));

            path[i] = pool;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../../lib/TransferHelper.sol";
import "../../lib/DexData.sol";
import "../../lib/Utils.sol";

contract UniV2ClassDex {
    using SafeMath for uint;
    using Utils for uint;
    using TransferHelper for IERC20;

    struct V2PriceOracle {
        uint32 blockTimestampLast;  // Last block timestamp when price updated
        uint price0; // recorded price for token0
        uint price1; // recorded price for token1
        uint price0CumulativeLast; // Cumulative TWAP for token0
        uint price1CumulativeLast; // Cumulative TWAP for token1
    }

    struct DexInfo {
        IUniswapV2Factory factory;
        uint16 fees;//30->0.3%
    }

    function uniClassSell(DexInfo memory dexInfo,
        address buyToken,
        address sellToken,
        uint sellAmount,
        uint minBuyAmount,
        address payer,
        address payee
    ) internal returns (uint buyAmount){
        address pair = getUniClassPair(buyToken, sellToken, dexInfo.factory);
        IUniswapV2Pair(pair).sync();
        sellAmount = transferOut(IERC20(sellToken), payer, pair, sellAmount);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        sellAmount = buyToken < sellToken ? IERC20(sellToken).balanceOf(pair).sub(token1Reserves) : IERC20(sellToken).balanceOf(pair).sub(token0Reserves);

        uint balanceBefore = IERC20(buyToken).balanceOf(payee);
        dexInfo.fees = getPairFees(dexInfo, pair);

        if (buyToken < sellToken) {
            buyAmount = getAmountOut(sellAmount, token1Reserves, token0Reserves, dexInfo.fees);
            IUniswapV2Pair(pair).swap(buyAmount, 0, payee, "");
        } else {
            buyAmount = getAmountOut(sellAmount, token0Reserves, token1Reserves, dexInfo.fees);
            IUniswapV2Pair(pair).swap(0, buyAmount, payee, "");
        }
        buyAmount = IERC20(buyToken).balanceOf(payee).sub(balanceBefore);
        require(buyAmount >= minBuyAmount, 'buy amount less than min');
    }

    function uniClassSellMul(DexInfo memory dexInfo, uint sellAmount, uint minBuyAmount, address[] memory tokens)
    internal returns (uint buyAmount){
        for (uint i = 1; i < tokens.length; i++) {
            address sellToken = tokens[i - 1];
            address buyToken = tokens[i];
            bool isLast = i == tokens.length - 1;
            address payer = i == 1 ? msg.sender : address(this);
            address payee = isLast ? msg.sender : address(this);
            buyAmount = uniClassSell(dexInfo, buyToken, sellToken, sellAmount, 0, payer, payee);
            if (!isLast) {
                sellAmount = buyAmount;
            }
        }
        require(buyAmount >= minBuyAmount, 'buy amount less than min');
    }

    function uniClassBuy(
        DexInfo memory dexInfo,
        address buyToken,
        address sellToken,
        uint buyAmount,
        uint maxSellAmount,
        uint24 buyTokenFeeRate,
        uint24 sellTokenFeeRate)
    internal returns (uint sellAmount){
        address pair = getUniClassPair(buyToken, sellToken, dexInfo.factory);
        IUniswapV2Pair(pair).sync();
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        uint balanceBefore = IERC20(buyToken).balanceOf(msg.sender);
        dexInfo.fees = getPairFees(dexInfo, pair);
        if (buyToken < sellToken) {
            sellAmount = getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token1Reserves, token0Reserves, dexInfo.fees);
            sellAmount = sellAmount.toAmountBeforeTax(sellTokenFeeRate);
            require(sellAmount <= maxSellAmount, 'sell amount not enough');
            transferOut(IERC20(sellToken), msg.sender, pair, sellAmount);
            IUniswapV2Pair(pair).swap(buyAmount.toAmountBeforeTax(buyTokenFeeRate), 0, msg.sender, "");
        } else {
            sellAmount = getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token0Reserves, token1Reserves, dexInfo.fees);
            sellAmount = sellAmount.toAmountBeforeTax(sellTokenFeeRate);
            require(sellAmount <= maxSellAmount, 'sell amount not enough');
            transferOut(IERC20(sellToken), msg.sender, pair, sellAmount);
            IUniswapV2Pair(pair).swap(0, buyAmount.toAmountBeforeTax(buyTokenFeeRate), msg.sender, "");
        }

        uint balanceAfter = IERC20(buyToken).balanceOf(msg.sender);
        require(buyAmount <= balanceAfter.sub(balanceBefore), "wrong amount bought");
    }

    function uniClassCalBuyAmount(DexInfo memory dexInfo, address buyToken, address sellToken, uint sellAmount) internal view returns (uint) {
        address pair = getUniClassPair(buyToken, sellToken, dexInfo.factory);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        if (buyToken < sellToken) {
            return getAmountOut(sellAmount, token1Reserves, token0Reserves, getPairFees(dexInfo, pair));
        } else {
            return getAmountOut(sellAmount, token0Reserves, token1Reserves, getPairFees(dexInfo, pair));
        }
    }

    function uniClassCalSellAmount(
        DexInfo memory dexInfo,
        address buyToken,
        address sellToken,
        uint buyAmount,
        uint24 buyTokenFeeRate,
        uint24 sellTokenFeeRate) internal view returns (uint sellAmount) {
        address pair = getUniClassPair(buyToken, sellToken, dexInfo.factory);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        sellAmount = buyToken < sellToken ?
        getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token1Reserves, token0Reserves, getPairFees(dexInfo, pair)) :
        getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token0Reserves, token1Reserves, getPairFees(dexInfo, pair));

        return sellAmount.toAmountBeforeTax(sellTokenFeeRate);
    }

    function uniClassGetPrice(IUniswapV2Factory factory, address desToken, address quoteToken, uint8 decimals) internal view returns (uint256){
        address pair = getUniClassPair(desToken, quoteToken, factory);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        return desToken == IUniswapV2Pair(pair).token0() ?
        token1Reserves.mul(10 ** decimals).div(token0Reserves) :
        token0Reserves.mul(10 ** decimals).div(token1Reserves);
    }

    function uniClassGetAvgPrice(address desToken, address quoteToken, V2PriceOracle memory priceOracle) internal pure returns (uint256 price, uint256 timestamp){
        timestamp = priceOracle.blockTimestampLast;
        price = desToken < quoteToken ? uint(priceOracle.price0) : uint(priceOracle.price1);
    }


    function uniClassGetPriceCAvgPriceHAvgPrice(address pair, V2PriceOracle memory priceOracle, address desToken, address quoteToken, uint8 decimals)
    internal view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint256 timestamp){
        bool isToken0 = desToken < quoteToken;
        (uint256 token0Reserves, uint256 token1Reserves, uint32 uniBlockTimeLast) = IUniswapV2Pair(pair).getReserves();
        price = isToken0 ?
        token1Reserves.mul(10 ** decimals).div(token0Reserves) :
        token0Reserves.mul(10 ** decimals).div(token1Reserves);

        hAvgPrice = isToken0 ? uint(priceOracle.price0) : uint(priceOracle.price1);
        timestamp = priceOracle.blockTimestampLast;

        if (uniBlockTimeLast <= priceOracle.blockTimestampLast) {
            cAvgPrice = hAvgPrice;
        } else {
            uint32 timeElapsed = uniBlockTimeLast - priceOracle.blockTimestampLast;
            cAvgPrice = uint256(isToken0 ?
                calTPrice(IUniswapV2Pair(pair).price0CumulativeLast(), priceOracle.price0CumulativeLast, timeElapsed, decimals) :
                calTPrice(IUniswapV2Pair(pair).price1CumulativeLast(), priceOracle.price1CumulativeLast, timeElapsed, decimals));
        }
    }

    function uniClassUpdatePriceOracle(address pair, V2PriceOracle memory priceOracle, uint32 timeWindow, uint8 decimals) internal returns (V2PriceOracle memory, bool updated) {
        uint32 currentBlockTime = toUint32(block.timestamp);
        if (currentBlockTime < (priceOracle.blockTimestampLast + timeWindow)) {
            return (priceOracle, false);
        }
        IUniswapV2Pair(pair).sync();
        uint32 timeElapsed = currentBlockTime - priceOracle.blockTimestampLast;
        uint currentPrice0CumulativeLast = IUniswapV2Pair(pair).price0CumulativeLast();
        uint currentPrice1CumulativeLast = IUniswapV2Pair(pair).price1CumulativeLast();
        if (priceOracle.blockTimestampLast != 0) {
            priceOracle.price0 = calTPrice(currentPrice0CumulativeLast, priceOracle.price0CumulativeLast, timeElapsed, decimals);
            priceOracle.price1 = calTPrice(currentPrice1CumulativeLast, priceOracle.price1CumulativeLast, timeElapsed, decimals);
        }
        priceOracle.price0CumulativeLast = currentPrice0CumulativeLast;
        priceOracle.price1CumulativeLast = currentPrice1CumulativeLast;
        priceOracle.blockTimestampLast = currentBlockTime;
        return (priceOracle, true);
    }

    function calTPrice(uint currentPriceCumulativeLast, uint historyPriceCumulativeLast, uint32 timeElapsed, uint8 decimals)
    internal pure returns (uint){
        uint256 diff = currentPriceCumulativeLast.sub(historyPriceCumulativeLast);
        if (diff < (1e50)) {
            return ((diff.mul(10 ** decimals)) >> 112).div(timeElapsed);
        } else {
            return ((diff) >> 112).mul(10 ** decimals).div(timeElapsed);
        }
    }

    function toUint32(uint256 y) internal pure returns (uint32 z) {
        require((z = uint32(y)) == y);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint16 fees) private pure returns (uint amountOut)
    {
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(uint(10000).sub(fees));
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint16 fees) private pure returns (uint amountIn) {
        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(uint(10000).sub(fees));
        amountIn = (numerator / denominator).add(1);
    }

    function transferOut(IERC20 token, address payer, address to, uint amount) private returns (uint256 amountReceived) {
        if (payer == address(this)) {
            amountReceived = token.safeTransfer(to, amount);
        } else {
            amountReceived = token.safeTransferFrom(payer, to, amount);
        }
    }

    function getUniClassPair(address tokenA, address tokenB, IUniswapV2Factory factory) internal view returns (address pair){
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (address(factory) == 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73) {
            return address(uint(keccak256(abi.encodePacked(
                    hex'ff',
                    address(factory),
                    keccak256(abi.encodePacked(token0, token1)),
                    hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
                ))));
        } else {
            return factory.getPair(tokenA, tokenB);
        }
    }

    function getPairFees(DexInfo memory dexInfo, address pair) private view returns (uint16){
        //mdex
        if (address(dexInfo.factory) == 0x3CD1C46068dAEa5Ebb0d3f55F6915B10648062B8) {
            return toUint16((IMdexFactory)(address(dexInfo.factory)).getPairFees(pair));
        }
        //biswap
        else if (address(dexInfo.factory) == 0x858E3312ed3A876947EA49d572A7C42DE08af7EE) {
            return toUint16((uint(10)).mul(IBiSwapPair(pair).swapFee()));
        }
        else {
            return dexInfo.fees;
        }
    }

    function toUint16(uint256 y) internal pure returns (uint16 z) {
        require((z = uint16(y)) == y);
    }
}

interface IMdexFactory {
    function getPairFees(address) external view returns (uint256);
}

interface IBiSwapPair {
    function swapFee() external view returns (uint32);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

interface DexAggregatorInterface {

    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);

    function sellMul(uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);

    function buy(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, uint maxSellAmount, bytes memory data) external returns (uint sellAmount);

    function calBuyAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint sellAmount, bytes memory data) external view returns (uint);

    function calSellAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, bytes memory data) external view returns (uint);

    function getPrice(address desToken, address quoteToken, bytes memory data) external view returns (uint256 price, uint8 decimals);

    function getAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory data) external view returns (uint256 price, uint8 decimals, uint256 timestamp);

    //cal current avg price and get history avg price
    function getPriceCAvgPriceHAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);

    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external returns(bool);

    function updateV3Observation(address desToken, address quoteToken, bytes memory data) external;

    function setDexInfo(uint8[] memory dexName, IUniswapV2Factory[] memory factoryAddr, uint16[] memory fees) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;


contract DelegateInterface {
    /**
     * Implementation address for this contract
     */
    address public implementation;

}

// SPDX-License-Identifier: BUSL-1.1


pragma solidity 0.7.6;

abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);
    constructor () {
        developer = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller must be admin");
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "caller must be admin or developer");
        _;
    }

    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;
        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;
        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "only pendingAdmin can accept admin");
        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        // Store admin with value pendingAdmin
        admin = pendingAdmin;
        // Clear the pending value
        pendingAdmin = address(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}