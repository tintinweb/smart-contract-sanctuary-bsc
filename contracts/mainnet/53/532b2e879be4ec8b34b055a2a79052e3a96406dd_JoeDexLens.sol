// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

/// @title Joe V1 Factory Interface
/// @notice Interface to interact with Joe V1 Factory
interface IJoeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function migrator() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setMigrator(address) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

/// @title Joe V1 Pair Interface
/// @notice Interface to interact with Joe V1 Pairs
interface IJoePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

import {ILBPair} from "./ILBPair.sol";
import {IPendingOwnable} from "./IPendingOwnable.sol";

/**
 * @title Liquidity Book Factory Interface
 * @author Trader Joe
 * @notice Required interface of LBFactory contract
 */
interface ILBFactory is IPendingOwnable {
    error LBFactory__IdenticalAddresses(IERC20 token);
    error LBFactory__QuoteAssetNotWhitelisted(IERC20 quoteAsset);
    error LBFactory__QuoteAssetAlreadyWhitelisted(IERC20 quoteAsset);
    error LBFactory__AddressZero();
    error LBFactory__LBPairAlreadyExists(IERC20 tokenX, IERC20 tokenY, uint256 _binStep);
    error LBFactory__LBPairDoesNotExists(IERC20 tokenX, IERC20 tokenY, uint256 _binStep);
    error LBFactory__LBPairNotCreated(IERC20 tokenX, IERC20 tokenY, uint256 binStep);
    error LBFactory__DecreasingPeriods(uint16 filterPeriod, uint16 decayPeriod);
    error LBFactory__ReductionFactorOverflows(uint16 reductionFactor, uint256 max);
    error LBFactory__VariableFeeControlOverflows(uint16 variableFeeControl, uint256 max);
    error LBFactory__BaseFeesBelowMin(uint256 baseFees, uint256 minBaseFees);
    error LBFactory__FeesAboveMax(uint256 fees, uint256 maxFees);
    error LBFactory__FlashLoanFeeAboveMax(uint256 fees, uint256 maxFees);
    error LBFactory__BinStepRequirementsBreached(uint256 lowerBound, uint16 binStep, uint256 higherBound);
    error LBFactory__ProtocolShareOverflows(uint16 protocolShare, uint256 max);
    error LBFactory__FunctionIsLockedForUsers(address user, uint8 binStep);
    error LBFactory__LBPairIgnoredIsAlreadyInTheSameState();
    error LBFactory__BinStepHasNoPreset(uint256 binStep);
    error LBFactory__SameFeeRecipient(address feeRecipient);
    error LBFactory__SameFlashLoanFee(uint256 flashLoanFee);
    error LBFactory__LBPairSafetyCheckFailed(address LBPairImplementation);
    error LBFactory__SameImplementation(address LBPairImplementation);
    error LBFactory__ImplementationNotSet();
    error LBFactory__SamePresetOpenState();

    /**
     * @dev Structure to store the LBPair information, such as:
     * binStep: The bin step of the LBPair
     * LBPair: The address of the LBPair
     * createdByOwner: Whether the pair was created by the owner of the factory
     * ignoredForRouting: Whether the pair is ignored for routing or not. An ignored pair will not be explored during routes finding
     */
    struct LBPairInformation {
        uint8 binStep;
        ILBPair LBPair;
        bool createdByOwner;
        bool ignoredForRouting;
    }

    event LBPairCreated(
        IERC20 indexed tokenX, IERC20 indexed tokenY, uint256 indexed binStep, ILBPair LBPair, uint256 pid
    );

    event FeeRecipientSet(address oldRecipient, address newRecipient);

    event FlashLoanFeeSet(uint256 oldFlashLoanFee, uint256 newFlashLoanFee);

    event LBPairImplementationSet(address oldLBPairImplementation, address LBPairImplementation);

    event LBPairIgnoredStateChanged(ILBPair indexed LBPair, bool ignored);

    event PresetSet(
        uint256 indexed binStep,
        uint256 baseFactor,
        uint256 filterPeriod,
        uint256 decayPeriod,
        uint256 reductionFactor,
        uint256 variableFeeControl,
        uint256 protocolShare,
        uint256 maxVolatilityAccumulator
    );

    event PresetRemoved(uint256 indexed binStep);

    event QuoteAssetAdded(IERC20 indexed quoteAsset);

    event QuoteAssetRemoved(IERC20 indexed quoteAsset);

    event OpenPresetChanged(uint8 indexed binStep, bool open);

    function getMaxFlashLoanFee() external pure returns (uint256);

    function getMinBinStep() external pure returns (uint256);

    function getMaxBinStep() external pure returns (uint256);

    function getLBPairImplementation() external view returns (address);

    function getNumberOfQuoteAssets() external view returns (uint256);

    function getQuoteAssetAtIndex(uint256 index) external view returns (IERC20);

    function isQuoteAsset(IERC20 token) external view returns (bool);

    function getFeeRecipient() external view returns (address);

    function getFlashLoanFee() external view returns (uint256);

    function getLBPairAtIndex(uint256 id) external returns (ILBPair);

    function getNumberOfLBPairs() external view returns (uint256);

    function getLBPairInformation(IERC20 tokenX, IERC20 tokenY, uint256 binStep)
        external
        view
        returns (LBPairInformation memory);

    function getPreset(uint256 binStep)
        external
        view
        returns (
            uint256 baseFactor,
            uint256 filterPeriod,
            uint256 decayPeriod,
            uint256 reductionFactor,
            uint256 variableFeeControl,
            uint256 protocolShare,
            uint256 maxAccumulator
        );

    function getAllBinSteps() external view returns (uint256[] memory presetsBinStep);

    function getAllLBPairs(IERC20 tokenX, IERC20 tokenY)
        external
        view
        returns (LBPairInformation[] memory LBPairsBinStep);

    function setLBPairImplementation(address lbPairImplementation) external;

    function createLBPair(IERC20 tokenX, IERC20 tokenY, uint24 activeId, uint8 binStep)
        external
        returns (ILBPair pair);

    function setLBPairIgnored(IERC20 tokenX, IERC20 tokenY, uint256 binStep, bool ignored) external;

    function setPreset(
        uint8 binStep,
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulator
    ) external;

    function removePreset(uint8 binStep) external;

    function setFeesParametersOnPair(
        IERC20 tokenX,
        IERC20 tokenY,
        uint8 binStep,
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulator
    ) external;

    function setFeeRecipient(address feeRecipient) external;

    function setFlashLoanFee(uint256 flashLoanFee) external;

    function addQuoteAsset(IERC20 quoteAsset) external;

    function removeQuoteAsset(IERC20 quoteAsset) external;

    function forceDecay(ILBPair lbPair) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

/// @title Liquidity Book Flashloan Callback Interface
/// @author Trader Joe
/// @notice Required interface to interact with LB flash loans
interface ILBFlashLoanCallback {
    function LBFlashLoanCallback(
        address sender,
        IERC20 tokenX,
        IERC20 tokenY,
        bytes32 amounts,
        bytes32 totalFees,
        bytes calldata data
    ) external returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

import {ILBLegacyPair} from "./ILBLegacyPair.sol";
import {IPendingOwnable} from "./IPendingOwnable.sol";

/// @title Liquidity Book Factory Interface
/// @author Trader Joe
/// @notice Required interface of LBFactory contract
interface ILBLegacyFactory is IPendingOwnable {
    /// @dev Structure to store the LBPair information, such as:
    /// - binStep: The bin step of the LBPair
    /// - LBPair: The address of the LBPair
    /// - createdByOwner: Whether the pair was created by the owner of the factory
    /// - ignoredForRouting: Whether the pair is ignored for routing or not. An ignored pair will not be explored during routes finding
    struct LBPairInformation {
        uint16 binStep;
        ILBLegacyPair LBPair;
        bool createdByOwner;
        bool ignoredForRouting;
    }

    event LBPairCreated(
        IERC20 indexed tokenX, IERC20 indexed tokenY, uint256 indexed binStep, ILBLegacyPair LBPair, uint256 pid
    );

    event FeeRecipientSet(address oldRecipient, address newRecipient);

    event FlashLoanFeeSet(uint256 oldFlashLoanFee, uint256 newFlashLoanFee);

    event FeeParametersSet(
        address indexed sender,
        ILBLegacyPair indexed LBPair,
        uint256 binStep,
        uint256 baseFactor,
        uint256 filterPeriod,
        uint256 decayPeriod,
        uint256 reductionFactor,
        uint256 variableFeeControl,
        uint256 protocolShare,
        uint256 maxVolatilityAccumulator
    );

    event FactoryLockedStatusUpdated(bool unlocked);

    event LBPairImplementationSet(address oldLBPairImplementation, address LBPairImplementation);

    event LBPairIgnoredStateChanged(ILBLegacyPair indexed LBPair, bool ignored);

    event PresetSet(
        uint256 indexed binStep,
        uint256 baseFactor,
        uint256 filterPeriod,
        uint256 decayPeriod,
        uint256 reductionFactor,
        uint256 variableFeeControl,
        uint256 protocolShare,
        uint256 maxVolatilityAccumulator,
        uint256 sampleLifetime
    );

    event PresetRemoved(uint256 indexed binStep);

    event QuoteAssetAdded(IERC20 indexed quoteAsset);

    event QuoteAssetRemoved(IERC20 indexed quoteAsset);

    function MAX_FEE() external pure returns (uint256);

    function MIN_BIN_STEP() external pure returns (uint256);

    function MAX_BIN_STEP() external pure returns (uint256);

    function MAX_PROTOCOL_SHARE() external pure returns (uint256);

    function LBPairImplementation() external view returns (address);

    function getNumberOfQuoteAssets() external view returns (uint256);

    function getQuoteAssetAtIndex(uint256 index) external view returns (IERC20);

    function isQuoteAsset(IERC20 token) external view returns (bool);

    function feeRecipient() external view returns (address);

    function flashLoanFee() external view returns (uint256);

    function creationUnlocked() external view returns (bool);

    function allLBPairs(uint256 id) external returns (ILBLegacyPair);

    function getNumberOfLBPairs() external view returns (uint256);

    function getLBPairInformation(IERC20 tokenX, IERC20 tokenY, uint256 binStep)
        external
        view
        returns (LBPairInformation memory);

    function getPreset(uint16 binStep)
        external
        view
        returns (
            uint256 baseFactor,
            uint256 filterPeriod,
            uint256 decayPeriod,
            uint256 reductionFactor,
            uint256 variableFeeControl,
            uint256 protocolShare,
            uint256 maxAccumulator,
            uint256 sampleLifetime
        );

    function getAllBinSteps() external view returns (uint256[] memory presetsBinStep);

    function getAllLBPairs(IERC20 tokenX, IERC20 tokenY)
        external
        view
        returns (LBPairInformation[] memory LBPairsBinStep);

    function setLBPairImplementation(address LBPairImplementation) external;

    function createLBPair(IERC20 tokenX, IERC20 tokenY, uint24 activeId, uint16 binStep)
        external
        returns (ILBLegacyPair pair);

    function setLBPairIgnored(IERC20 tokenX, IERC20 tokenY, uint256 binStep, bool ignored) external;

    function setPreset(
        uint16 binStep,
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulator,
        uint16 sampleLifetime
    ) external;

    function removePreset(uint16 binStep) external;

    function setFeesParametersOnPair(
        IERC20 tokenX,
        IERC20 tokenY,
        uint16 binStep,
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulator
    ) external;

    function setFeeRecipient(address feeRecipient) external;

    function setFlashLoanFee(uint256 flashLoanFee) external;

    function setFactoryLockedState(bool locked) external;

    function addQuoteAsset(IERC20 quoteAsset) external;

    function removeQuoteAsset(IERC20 quoteAsset) external;

    function forceDecay(ILBLegacyPair LBPair) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

/// @title Liquidity Book Pair V2 Interface
/// @author Trader Joe
/// @notice Required interface of LBPair contract
interface ILBLegacyPair {
    function tokenX() external view returns (IERC20);

    function tokenY() external view returns (IERC20);

    function getReservesAndId() external view returns (uint256 reserveX, uint256 reserveY, uint256 activeId);

    function swap(bool sentTokenY, address to) external returns (uint256 amountXOut, uint256 amountYOut);

    function findFirstNonEmptyBinId(uint24 id_, bool sentTokenY) external view returns (uint24 id);

    function getBin(uint24 id) external view returns (uint256 reserveX, uint256 reserveY);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

import {ILBFactory} from "./ILBFactory.sol";
import {IJoeFactory} from "./IJoeFactory.sol";
import {ILBLegacyPair} from "./ILBLegacyPair.sol";
import {ILBToken} from "./ILBToken.sol";
import {IWAVAX} from "./IWAVAX.sol";

/// @title Liquidity Book Router Interface
/// @author Trader Joe
/// @notice Required interface of LBRouter contract
interface ILBLegacyRouter {
    struct LiquidityParameters {
        IERC20 tokenX;
        IERC20 tokenY;
        uint256 binStep;
        uint256 amountX;
        uint256 amountY;
        uint256 amountXMin;
        uint256 amountYMin;
        uint256 activeIdDesired;
        uint256 idSlippage;
        int256[] deltaIds;
        uint256[] distributionX;
        uint256[] distributionY;
        address to;
        uint256 deadline;
    }

    function getIdFromPrice(ILBLegacyPair LBPair, uint256 price) external view returns (uint24);

    function getPriceFromId(ILBLegacyPair LBPair, uint24 id) external view returns (uint256);

    function getSwapIn(ILBLegacyPair lbPair, uint256 amountOut, bool swapForY)
        external
        view
        returns (uint256 amountIn, uint256 feesIn);

    function getSwapOut(ILBLegacyPair lbPair, uint256 amountIn, bool swapForY)
        external
        view
        returns (uint256 amountOut, uint256 feesIn);

    function createLBPair(IERC20 tokenX, IERC20 tokenY, uint24 activeId, uint16 binStep)
        external
        returns (ILBLegacyPair pair);

    function addLiquidity(LiquidityParameters calldata liquidityParameters)
        external
        returns (uint256[] memory depositIds, uint256[] memory liquidityMinted);

    function addLiquidityAVAX(LiquidityParameters calldata liquidityParameters)
        external
        payable
        returns (uint256[] memory depositIds, uint256[] memory liquidityMinted);

    function removeLiquidity(
        IERC20 tokenX,
        IERC20 tokenY,
        uint16 binStep,
        uint256 amountXMin,
        uint256 amountYMin,
        uint256[] memory ids,
        uint256[] memory amounts,
        address to,
        uint256 deadline
    ) external returns (uint256 amountX, uint256 amountY);

    function removeLiquidityAVAX(
        IERC20 token,
        uint16 binStep,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        uint256[] memory ids,
        uint256[] memory amounts,
        address payable to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint256 amountOutMinAVAX,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address payable to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactAVAXForTokens(
        uint256 amountOutMin,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountOut);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amountsIn);

    function swapTokensForExactAVAX(
        uint256 amountOut,
        uint256 amountInMax,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address payable to,
        uint256 deadline
    ) external returns (uint256[] memory amountsIn);

    function swapAVAXForExactTokens(
        uint256 amountOut,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amountsIn);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMinAVAX,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address payable to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountOut);

    function sweep(IERC20 token, address to, uint256 amount) external;

    function sweepLBToken(ILBToken _lbToken, address _to, uint256[] calldata _ids, uint256[] calldata _amounts)
        external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

import {ILBFactory} from "./ILBFactory.sol";
import {ILBFlashLoanCallback} from "./ILBFlashLoanCallback.sol";
import {ILBToken} from "./ILBToken.sol";

interface ILBPair is ILBToken {
    error LBPair__ZeroBorrowAmount();
    error LBPair__AddressZero();
    error LBPair__AlreadyInitialized();
    error LBPair__EmptyMarketConfigs();
    error LBPair__FlashLoanCallbackFailed();
    error LBPair__FlashLoanInsufficientAmount();
    error LBPair__InsufficientAmountIn();
    error LBPair__InsufficientAmountOut();
    error LBPair__InvalidInput();
    error LBPair__InvalidStaticFeeParameters();
    error LBPair__OnlyFactory();
    error LBPair__OnlyProtocolFeeRecipient();
    error LBPair__OutOfLiquidity();
    error LBPair__TokenNotSupported();
    error LBPair__ZeroAmount(uint24 id);
    error LBPair__ZeroAmountsOut(uint24 id);
    error LBPair__ZeroShares(uint24 id);
    error LBPair__MaxTotalFeeExceeded();

    event DepositedToBins(address indexed sender, address indexed to, uint256[] ids, bytes32[] amounts);

    event WithdrawnFromBins(address indexed sender, address indexed to, uint256[] ids, bytes32[] amounts);

    event CompositionFees(address indexed sender, uint24 id, bytes32 totalFees, bytes32 protocolFees);

    event CollectedProtocolFees(address indexed feeRecipient, bytes32 protocolFees);

    event Swap(
        address indexed sender,
        address indexed to,
        uint24 id,
        bytes32 amountsIn,
        bytes32 amountsOut,
        uint24 volatilityAccumulator,
        bytes32 totalFees,
        bytes32 protocolFees
    );

    event StaticFeeParametersSet(
        address indexed sender,
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulator
    );

    event FlashLoan(
        address indexed sender,
        ILBFlashLoanCallback indexed receiver,
        uint24 activeId,
        bytes32 amounts,
        bytes32 totalFees,
        bytes32 protocolFees
    );

    event OracleLengthIncreased(address indexed sender, uint16 oracleLength);

    event ForcedDecay(address indexed sender, uint24 idReference, uint24 volatilityReference);

    function initialize(
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulator,
        uint24 activeId
    ) external;

    function getFactory() external view returns (ILBFactory factory);

    function getTokenX() external view returns (IERC20 tokenX);

    function getTokenY() external view returns (IERC20 tokenY);

    function getBinStep() external view returns (uint8 binStep);

    function getReserves() external view returns (uint128 reserveX, uint128 reserveY);

    function getActiveId() external view returns (uint24 activeId);

    function getBin(uint24 id) external view returns (uint128 binReserveX, uint128 binReserveY);

    function getNextNonEmptyBin(bool swapForY, uint24 id) external view returns (uint24 nextId);

    function getProtocolFees() external view returns (uint128 protocolFeeX, uint128 protocolFeeY);

    function getStaticFeeParameters()
        external
        view
        returns (
            uint16 baseFactor,
            uint16 filterPeriod,
            uint16 decayPeriod,
            uint16 reductionFactor,
            uint24 variableFeeControl,
            uint16 protocolShare,
            uint24 maxVolatilityAccumulator
        );

    function getVariableFeeParameters()
        external
        view
        returns (uint24 volatilityAccumulator, uint24 volatilityReference, uint24 idReference, uint40 timeOfLastUpdate);

    function getOracleParameters()
        external
        view
        returns (uint8 sampleLifetime, uint16 size, uint16 activeSize, uint40 lastUpdated, uint40 firstTimestamp);

    function getOracleSampleAt(uint40 lookupTimestamp)
        external
        view
        returns (uint64 cumulativeId, uint64 cumulativeVolatility, uint64 cumulativeBinCrossed);

    function getPriceFromId(uint24 id) external view returns (uint256 price);

    function getIdFromPrice(uint256 price) external view returns (uint24 id);

    function getSwapIn(uint128 amountOut, bool swapForY)
        external
        view
        returns (uint128 amountIn, uint128 amountOutLeft, uint128 fee);

    function getSwapOut(uint128 amountIn, bool swapForY)
        external
        view
        returns (uint128 amountInLeft, uint128 amountOut, uint128 fee);

    function swap(bool swapForY, address to) external returns (bytes32 amountsOut);

    function flashLoan(ILBFlashLoanCallback receiver, bytes32 amounts, bytes calldata data) external;

    function mint(address to, bytes32[] calldata liquidityConfigs, address refundTo)
        external
        returns (bytes32 amountsReceived, bytes32 amountsLeft, uint256[] memory liquidityMinted);

    function burn(address from, address to, uint256[] calldata ids, uint256[] calldata amountsToBurn)
        external
        returns (bytes32[] memory amounts);

    function collectProtocolFees() external returns (bytes32 collectedProtocolFees);

    function increaseOracleLength(uint16 newLength) external;

    function setStaticFeeParameters(
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulator
    ) external;

    function forceDecay() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

import {IJoeFactory} from "./IJoeFactory.sol";
import {ILBFactory} from "./ILBFactory.sol";
import {ILBLegacyFactory} from "./ILBLegacyFactory.sol";
import {ILBLegacyRouter} from "./ILBLegacyRouter.sol";
import {ILBPair} from "./ILBPair.sol";
import {ILBToken} from "./ILBToken.sol";
import {IWAVAX} from "./IWAVAX.sol";

/**
 * @title Liquidity Book Router Interface
 * @author Trader Joe
 * @notice Required interface of LBRouter contract
 */
interface ILBRouter {
    error LBRouter__SenderIsNotWAVAX();
    error LBRouter__PairNotCreated(address tokenX, address tokenY, uint256 binStep);
    error LBRouter__WrongAmounts(uint256 amount, uint256 reserve);
    error LBRouter__SwapOverflows(uint256 id);
    error LBRouter__BrokenSwapSafetyCheck();
    error LBRouter__NotFactoryOwner();
    error LBRouter__TooMuchTokensIn(uint256 excess);
    error LBRouter__BinReserveOverflows(uint256 id);
    error LBRouter__IdOverflows(int256 id);
    error LBRouter__LengthsMismatch();
    error LBRouter__WrongTokenOrder();
    error LBRouter__IdSlippageCaught(uint256 activeIdDesired, uint256 idSlippage, uint256 activeId);
    error LBRouter__AmountSlippageCaught(uint256 amountXMin, uint256 amountX, uint256 amountYMin, uint256 amountY);
    error LBRouter__IdDesiredOverflows(uint256 idDesired, uint256 idSlippage);
    error LBRouter__FailedToSendAVAX(address recipient, uint256 amount);
    error LBRouter__DeadlineExceeded(uint256 deadline, uint256 currentTimestamp);
    error LBRouter__AmountSlippageBPTooBig(uint256 amountSlippage);
    error LBRouter__InsufficientAmountOut(uint256 amountOutMin, uint256 amountOut);
    error LBRouter__MaxAmountInExceeded(uint256 amountInMax, uint256 amountIn);
    error LBRouter__InvalidTokenPath(address wrongToken);
    error LBRouter__InvalidVersion(uint256 version);
    error LBRouter__WrongAvaxLiquidityParameters(
        address tokenX, address tokenY, uint256 amountX, uint256 amountY, uint256 msgValue
    );

    /**
     * @dev This enum represents the version of the pair requested
     * - V1: Joe V1 pair
     * - V2: LB pair V2. Also called legacyPair
     * - V2_1: LB pair V2.1 (current version)
     */
    enum Version {
        V1,
        V2,
        V2_1
    }

    /**
     * @dev The liquidity parameters, such as:
     * - tokenX: The address of token X
     * - tokenY: The address of token Y
     * - binStep: The bin step of the pair
     * - amountX: The amount to send of token X
     * - amountY: The amount to send of token Y
     * - amountXMin: The min amount of token X added to liquidity
     * - amountYMin: The min amount of token Y added to liquidity
     * - activeIdDesired: The active id that user wants to add liquidity from
     * - idSlippage: The number of id that are allowed to slip
     * - deltaIds: The list of delta ids to add liquidity (`deltaId = activeId - desiredId`)
     * - distributionX: The distribution of tokenX with sum(distributionX) = 100e18 (100%) or 0 (0%)
     * - distributionY: The distribution of tokenY with sum(distributionY) = 100e18 (100%) or 0 (0%)
     * - to: The address of the recipient
     * - deadline: The deadline of the tx
     */
    struct LiquidityParameters {
        IERC20 tokenX;
        IERC20 tokenY;
        uint256 binStep;
        uint256 amountX;
        uint256 amountY;
        uint256 amountXMin;
        uint256 amountYMin;
        uint256 activeIdDesired;
        uint256 idSlippage;
        int256[] deltaIds;
        uint256[] distributionX;
        uint256[] distributionY;
        address to;
        address refundTo;
        uint256 deadline;
    }

    /**
     * @dev The path parameters, such as:
     * - pairBinSteps: The list of bin steps of the pairs to go through
     * - versions: The list of versions of the pairs to go through
     * - tokenPath: The list of tokens in the path to go through
     */
    struct Path {
        uint256[] pairBinSteps;
        Version[] versions;
        IERC20[] tokenPath;
    }

    function getFactory() external view returns (ILBFactory);

    function getLegacyFactory() external view returns (ILBLegacyFactory);

    function getV1Factory() external view returns (IJoeFactory);

    function getLegacyRouter() external view returns (ILBLegacyRouter);

    function getWAVAX() external view returns (IWAVAX);

    function getIdFromPrice(ILBPair LBPair, uint256 price) external view returns (uint24);

    function getPriceFromId(ILBPair LBPair, uint24 id) external view returns (uint256);

    function getSwapIn(ILBPair LBPair, uint128 amountOut, bool swapForY)
        external
        view
        returns (uint128 amountIn, uint128 amountOutLeft, uint128 fee);

    function getSwapOut(ILBPair LBPair, uint128 amountIn, bool swapForY)
        external
        view
        returns (uint128 amountInLeft, uint128 amountOut, uint128 fee);

    function createLBPair(IERC20 tokenX, IERC20 tokenY, uint24 activeId, uint8 binStep)
        external
        returns (ILBPair pair);

    function addLiquidity(LiquidityParameters calldata liquidityParameters)
        external
        returns (
            uint256 amountXAdded,
            uint256 amountYAdded,
            uint256 amountXLeft,
            uint256 amountYLeft,
            uint256[] memory depositIds,
            uint256[] memory liquidityMinted
        );

    function addLiquidityAVAX(LiquidityParameters calldata liquidityParameters)
        external
        payable
        returns (
            uint256 amountXAdded,
            uint256 amountYAdded,
            uint256 amountXLeft,
            uint256 amountYLeft,
            uint256[] memory depositIds,
            uint256[] memory liquidityMinted
        );

    function removeLiquidity(
        IERC20 tokenX,
        IERC20 tokenY,
        uint8 binStep,
        uint256 amountXMin,
        uint256 amountYMin,
        uint256[] memory ids,
        uint256[] memory amounts,
        address to,
        uint256 deadline
    ) external returns (uint256 amountX, uint256 amountY);

    function removeLiquidityAVAX(
        IERC20 token,
        uint8 binStep,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        uint256[] memory ids,
        uint256[] memory amounts,
        address payable to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Path memory path,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint256 amountOutMinAVAX,
        Path memory path,
        address payable to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactAVAXForTokens(uint256 amountOutMin, Path memory path, address to, uint256 deadline)
        external
        payable
        returns (uint256 amountOut);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        Path memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amountsIn);

    function swapTokensForExactAVAX(
        uint256 amountOut,
        uint256 amountInMax,
        Path memory path,
        address payable to,
        uint256 deadline
    ) external returns (uint256[] memory amountsIn);

    function swapAVAXForExactTokens(uint256 amountOut, Path memory path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amountsIn);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Path memory path,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMinAVAX,
        Path memory path,
        address payable to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        Path memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountOut);

    function sweep(IERC20 token, address to, uint256 amount) external;

    function sweepLBToken(ILBToken _lbToken, address _to, uint256[] calldata _ids, uint256[] calldata _amounts)
        external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
 * @title Liquidity Book Token Interface
 * @author Trader Joe
 * @notice Interface to interact with the LBToken.
 */
interface ILBToken {
    error LBToken__AddressThisOrZero();
    error LBToken__InvalidLength();
    error LBToken__SelfApproval(address owner);
    error LBToken__SpenderNotApproved(address from, address spender);
    error LBToken__TransferExceedsBalance(address from, uint256 id, uint256 amount);
    error LBToken__BurnExceedsBalance(address from, uint256 id, uint256 amount);

    event TransferBatch(
        address indexed sender, address indexed from, address indexed to, uint256[] ids, uint256[] amounts
    );

    event ApprovalForAll(address indexed account, address indexed sender, bool approved);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply(uint256 id) external view returns (uint256);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function isApprovedForAll(address owner, address spender) external view returns (bool);

    function setApprovalForAll(address spender, bool approved) external;

    function batchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
 * @title Liquidity Book Pending Ownable Interface
 * @author Trader Joe
 * @notice Required interface of Pending Ownable contract used for LBFactory
 */
interface IPendingOwnable {
    error PendingOwnable__AddressZero();
    error PendingOwnable__NoPendingOwner();
    error PendingOwnable__NotOwner();
    error PendingOwnable__NotPendingOwner();
    error PendingOwnable__PendingOwnerAlreadySet();

    event PendingOwnerSet(address indexed pendingOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function setPendingOwner(address pendingOwner) external;

    function revokePendingOwner() external;

    function becomeOwner() external;

    function renounceOwnership() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

/**
 * @title WAVAX Interface
 * @notice Required interface of Wrapped AVAX contract
 */
interface IWAVAX is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
 * @title Liquidity Book Constants Library
 * @author Trader Joe
 * @notice Set of constants for Liquidity Book contracts
 */
library Constants {
    uint8 internal constant SCALE_OFFSET = 128;
    uint256 internal constant SCALE = 1 << SCALE_OFFSET;

    uint256 internal constant PRECISION = 1e18;
    uint256 internal constant SQUARED_PRECISION = PRECISION * PRECISION;

    uint256 internal constant MAX_FEE = 0.1e18; // 10%
    uint256 internal constant MAX_PROTOCOL_SHARE = 2_500; // 25% of the fee

    uint256 internal constant BASIS_POINT_MAX = 10_000;
    uint256 internal constant TWO_BASIS_POINT_MAX = 2 * BASIS_POINT_MAX;

    /// @dev The expected return after a successful flash loan
    bytes32 internal constant CALLBACK_SUCCESS = keccak256("LBPair.onFlashLoan");
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
 * @title Liquidity Book Bit Math Library
 * @author Trader Joe
 * @notice Helper contract used for bit calculations
 */
library BitMath {
    /**
     * @dev Returns the index of the closest bit on the right of x that is non null
     * @param x The value as a uint256
     * @param bit The index of the bit to start searching at
     * @return id The index of the closest non null bit on the right of x.
     * If there is no closest bit, it returns max(uint256)
     */
    function closestBitRight(uint256 x, uint8 bit) internal pure returns (uint256 id) {
        unchecked {
            uint256 shift = 255 - bit;
            x <<= shift;

            // can't overflow as it's non-zero and we shifted it by `_shift`
            return (x == 0) ? type(uint256).max : mostSignificantBit(x) - shift;
        }
    }

    /**
     * @dev Returns the index of the closest bit on the left of x that is non null
     * @param x The value as a uint256
     * @param bit The index of the bit to start searching at
     * @return id The index of the closest non null bit on the left of x.
     * If there is no closest bit, it returns max(uint256)
     */
    function closestBitLeft(uint256 x, uint8 bit) internal pure returns (uint256 id) {
        unchecked {
            x >>= bit;

            return (x == 0) ? type(uint256).max : leastSignificantBit(x) + bit;
        }
    }

    /**
     * @dev Returns the index of the most significant bit of x
     * This function returns 0 if x is 0
     * @param x The value as a uint256
     * @return msb The index of the most significant bit of x
     */
    function mostSignificantBit(uint256 x) internal pure returns (uint8 msb) {
        assembly {
            if gt(x, 0xffffffffffffffffffffffffffffffff) {
                x := shr(128, x)
                msb := 128
            }
            if gt(x, 0xffffffffffffffff) {
                x := shr(64, x)
                msb := add(msb, 64)
            }
            if gt(x, 0xffffffff) {
                x := shr(32, x)
                msb := add(msb, 32)
            }
            if gt(x, 0xffff) {
                x := shr(16, x)
                msb := add(msb, 16)
            }
            if gt(x, 0xff) {
                x := shr(8, x)
                msb := add(msb, 8)
            }
            if gt(x, 0xf) {
                x := shr(4, x)
                msb := add(msb, 4)
            }
            if gt(x, 0x3) {
                x := shr(2, x)
                msb := add(msb, 2)
            }
            if gt(x, 0x1) { msb := add(msb, 1) }
        }
    }

    /**
     * @dev Returns the index of the least significant bit of x
     * This function returns 255 if x is 0
     * @param x The value as a uint256
     * @return lsb The index of the least significant bit of x
     */
    function leastSignificantBit(uint256 x) internal pure returns (uint8 lsb) {
        assembly {
            let sx := shl(128, x)
            if iszero(iszero(sx)) {
                lsb := 128
                x := sx
            }
            sx := shl(64, x)
            if iszero(iszero(sx)) {
                x := sx
                lsb := add(lsb, 64)
            }
            sx := shl(32, x)
            if iszero(iszero(sx)) {
                x := sx
                lsb := add(lsb, 32)
            }
            sx := shl(16, x)
            if iszero(iszero(sx)) {
                x := sx
                lsb := add(lsb, 16)
            }
            sx := shl(8, x)
            if iszero(iszero(sx)) {
                x := sx
                lsb := add(lsb, 8)
            }
            sx := shl(4, x)
            if iszero(iszero(sx)) {
                x := sx
                lsb := add(lsb, 4)
            }
            sx := shl(2, x)
            if iszero(iszero(sx)) {
                x := sx
                lsb := add(lsb, 2)
            }
            if iszero(iszero(shl(1, x))) { lsb := add(lsb, 1) }

            lsb := sub(255, lsb)
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {BitMath} from "./BitMath.sol";

/**
 * @title Liquidity Book Uint256x256 Math Library
 * @author Trader Joe
 * @notice Helper contract used for full precision calculations
 */
library Uint256x256Math {
    using BitMath for uint256;

    error Uint256x256Math__MulShiftOverflow();
    error Uint256x256Math__MulDivOverflow();

    /**
     * @notice Calculates floor(x*y/denominator) with full precision
     * The result will be rounded down
     * @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
     * Requirements:
     * - The denominator cannot be zero
     * - The result must fit within uint256
     * Caveats:
     * - This function does not work with fixed-point numbers
     * @param x The multiplicand as an uint256
     * @param y The multiplier as an uint256
     * @param denominator The divisor as an uint256
     * @return result The result as an uint256
     */
    function mulDivRoundDown(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        (uint256 prod0, uint256 prod1) = _getMulProds(x, y);

        return _getEndOfDivRoundDown(x, y, denominator, prod0, prod1);
    }

    /**
     * @notice Calculates ceil(x*y/denominator) with full precision
     * The result will be rounded up
     * @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
     * Requirements:
     * - The denominator cannot be zero
     * - The result must fit within uint256
     * Caveats:
     * - This function does not work with fixed-point numbers
     * @param x The multiplicand as an uint256
     * @param y The multiplier as an uint256
     * @param denominator The divisor as an uint256
     * @return result The result as an uint256
     */
    function mulDivRoundUp(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        result = mulDivRoundDown(x, y, denominator);
        if (mulmod(x, y, denominator) != 0) result += 1;
    }

    /**
     * @notice Calculates floor(x * y / 2**offset) with full precision
     * The result will be rounded down
     * @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
     * Requirements:
     * - The offset needs to be strictly lower than 256
     * - The result must fit within uint256
     * Caveats:
     * - This function does not work with fixed-point numbers
     * @param x The multiplicand as an uint256
     * @param y The multiplier as an uint256
     * @param offset The offset as an uint256, can't be greater than 256
     * @return result The result as an uint256
     */
    function mulShiftRoundDown(uint256 x, uint256 y, uint8 offset) internal pure returns (uint256 result) {
        (uint256 prod0, uint256 prod1) = _getMulProds(x, y);

        if (prod0 != 0) result = prod0 >> offset;
        if (prod1 != 0) {
            // Make sure the result is less than 2^256.
            if (prod1 >= 1 << offset) revert Uint256x256Math__MulShiftOverflow();

            unchecked {
                result += prod1 << (256 - offset);
            }
        }
    }

    /**
     * @notice Calculates floor(x * y / 2**offset) with full precision
     * The result will be rounded down
     * @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
     * Requirements:
     * - The offset needs to be strictly lower than 256
     * - The result must fit within uint256
     * Caveats:
     * - This function does not work with fixed-point numbers
     * @param x The multiplicand as an uint256
     * @param y The multiplier as an uint256
     * @param offset The offset as an uint256, can't be greater than 256
     * @return result The result as an uint256
     */
    function mulShiftRoundUp(uint256 x, uint256 y, uint8 offset) internal pure returns (uint256 result) {
        result = mulShiftRoundDown(x, y, offset);
        if (mulmod(x, y, 1 << offset) != 0) result += 1;
    }

    /**
     * @notice Calculates floor(x << offset / y) with full precision
     * The result will be rounded down
     * @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
     * Requirements:
     * - The offset needs to be strictly lower than 256
     * - The result must fit within uint256
     * Caveats:
     * - This function does not work with fixed-point numbers
     * @param x The multiplicand as an uint256
     * @param offset The number of bit to shift x as an uint256
     * @param denominator The divisor as an uint256
     * @return result The result as an uint256
     */
    function shiftDivRoundDown(uint256 x, uint8 offset, uint256 denominator) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;

        prod0 = x << offset; // Least significant 256 bits of the product
        unchecked {
            prod1 = x >> (256 - offset); // Most significant 256 bits of the product
        }

        return _getEndOfDivRoundDown(x, 1 << offset, denominator, prod0, prod1);
    }

    /**
     * @notice Calculates ceil(x << offset / y) with full precision
     * The result will be rounded up
     * @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
     * Requirements:
     * - The offset needs to be strictly lower than 256
     * - The result must fit within uint256
     * Caveats:
     * - This function does not work with fixed-point numbers
     * @param x The multiplicand as an uint256
     * @param offset The number of bit to shift x as an uint256
     * @param denominator The divisor as an uint256
     * @return result The result as an uint256
     */
    function shiftDivRoundUp(uint256 x, uint8 offset, uint256 denominator) internal pure returns (uint256 result) {
        result = shiftDivRoundDown(x, offset, denominator);
        if (mulmod(x, 1 << offset, denominator) != 0) result += 1;
    }

    /**
     * @notice Helper function to return the result of `x * y` as 2 uint256
     * @param x The multiplicand as an uint256
     * @param y The multiplier as an uint256
     * @return prod0 The least significant 256 bits of the product
     * @return prod1 The most significant 256 bits of the product
     */
    function _getMulProds(uint256 x, uint256 y) private pure returns (uint256 prod0, uint256 prod1) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
    }

    /**
     * @notice Helper function to return the result of `x * y / denominator` with full precision
     * @param x The multiplicand as an uint256
     * @param y The multiplier as an uint256
     * @param denominator The divisor as an uint256
     * @param prod0 The least significant 256 bits of the product
     * @param prod1 The most significant 256 bits of the product
     * @return result The result as an uint256
     */
    function _getEndOfDivRoundDown(uint256 x, uint256 y, uint256 denominator, uint256 prod0, uint256 prod1)
        private
        pure
        returns (uint256 result)
    {
        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
        } else {
            // Make sure the result is less than 2^256. Also prevents denominator == 0
            if (prod1 >= denominator) revert Uint256x256Math__MulDivOverflow();

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1
            // See https://cs.stackexchange.com/q/138556/92363
            unchecked {
                // Does not overflow because the denominator cannot be zero at this stage in the function
                uint256 lpotdod = denominator & (~denominator + 1);
                assembly {
                    // Divide denominator by lpotdod.
                    denominator := div(denominator, lpotdod)

                    // Divide [prod1 prod0] by lpotdod.
                    prod0 := div(prod0, lpotdod)

                    // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one
                    lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
                }

                // Shift in bits from prod1 into prod0
                prod0 |= prod1 * lpotdod;

                // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
                // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
                // four bits. That is, denominator * inv = 1 mod 2^4
                uint256 inverse = (3 * denominator) ^ 2;

                // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
                // in modular arithmetic, doubling the correct bits in each step
                inverse *= 2 - denominator * inverse; // inverse mod 2^8
                inverse *= 2 - denominator * inverse; // inverse mod 2^16
                inverse *= 2 - denominator * inverse; // inverse mod 2^32
                inverse *= 2 - denominator * inverse; // inverse mod 2^64
                inverse *= 2 - denominator * inverse; // inverse mod 2^128
                inverse *= 2 - denominator * inverse; // inverse mod 2^256

                // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
                // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
                // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
                // is no longer required.
                result = prod0 * inverse;
            }
        }
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

pragma solidity ^0.8.10;

import "./ISafeOwnable.sol";

interface ISafeAccessControlEnumerable is ISafeOwnable {
    error SafeAccessControlEnumerable__OnlyRole(address account, bytes32 role);
    error SafeAccessControlEnumerable__OnlyOwnerOrRole(address account, bytes32 role);
    error SafeAccessControlEnumerable__RoleAlreadyGranted(address account, bytes32 role);
    error SafeAccessControlEnumerable__AccountAlreadyHasRole(address account, bytes32 role);
    error SafeAccessControlEnumerable__AccountDoesNotHaveRole(address account, bytes32 role);

    event RoleGranted(address indexed sender, bytes32 indexed role, address indexed account);
    event RoleRevoked(address indexed sender, bytes32 indexed role, address indexed account);
    event RoleAdminSet(address indexed sender, bytes32 indexed role, bytes32 indexed adminRole);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getRoleMemberAt(bytes32 role, uint256 index) external view returns (address);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface ISafeOwnable {
    error SafeOwnable__OnlyOwner();
    error SafeOwnable__OnlyPendingOwner();

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PendingOwnerSet(address indexed owner, address indexed pendingOwner);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function setPendingOwner(address newPendingOwner) external;

    function becomeOwner() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../structs/EnumerableMap.sol";
import "./ISafeAccessControlEnumerable.sol";
import "./SafeOwnable.sol";

/**
 * @title Safe Access Control Enumerable
 * @author 0x0Louis
 * @notice This contract is used to manage a set of addresses that have been granted a specific role.
 * Only the owner can be granted the DEFAULT_ADMIN_ROLE.
 */
abstract contract SafeAccessControlEnumerable is SafeOwnable, ISafeAccessControlEnumerable {
    using EnumerableMap for EnumerableMap.AddressSet;

    struct EnumerableRoleData {
        EnumerableMap.AddressSet members;
        bytes32 adminRole;
    }

    bytes32 public constant override DEFAULT_ADMIN_ROLE = 0x00;

    mapping(bytes32 => EnumerableRoleData) private _roles;

    /**
     * @dev Modifier that checks if the caller has the role `role`.
     */
    modifier onlyRole(bytes32 role) {
        if (!hasRole(role, msg.sender)) revert SafeAccessControlEnumerable__OnlyRole(msg.sender, role);
        _;
    }

    /**
     * @dev Modifier that checks if the caller has the role `role` or the role `DEFAULT_ADMIN_ROLE`.
     */
    modifier onlyOwnerOrRole(bytes32 role) {
        if (owner() != msg.sender && !hasRole(role, msg.sender)) {
            revert SafeAccessControlEnumerable__OnlyOwnerOrRole(msg.sender, role);
        }
        _;
    }

    /**
     * @notice Checks if an account has a role.
     * @param role The role to check.
     * @param account The account to check.
     * @return True if the account has the role, false otherwise.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @notice Returns the number of accounts that have the role.
     * @param role The role to check.
     * @return The number of accounts that have the role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @notice Returns the account at the given index in the role.
     * @param role The role to check.
     * @param index The index to check.
     * @return The account at the given index in the role.
     */
    function getRoleMemberAt(bytes32 role, uint256 index) public view override returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @notice Returns the admin role of the given role.
     * @param role The role to check.
     * @return The admin role of the given role.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @notice Grants `role` to `account`.
     * @param role The role to grant.
     * @param account The account to grant the role to.
     */
    function grantRole(bytes32 role, address account) public override onlyOwnerOrRole((getRoleAdmin(role))) {
        if (!_grantRole(role, account)) revert SafeAccessControlEnumerable__AccountAlreadyHasRole(account, role);
    }

    /**
     * @notice Revokes `role` from `account`.
     * @param role The role to revoke.
     * @param account The account to revoke the role from.
     */
    function revokeRole(bytes32 role, address account) public override onlyOwnerOrRole((getRoleAdmin(role))) {
        if (!_revokeRole(role, account)) revert SafeAccessControlEnumerable__AccountDoesNotHaveRole(account, role);
    }

    /**
     * @notice Revokes `role` from the calling account.
     * @param role The role to revoke.
     */
    function renounceRole(bytes32 role) public override {
        if (!_revokeRole(role, msg.sender)) {
            revert SafeAccessControlEnumerable__AccountDoesNotHaveRole(msg.sender, role);
        }
    }

    function _transferOwnership(address newOwner) internal override {
        address previousOwner = owner();
        super._transferOwnership(newOwner);

        _revokeRole(DEFAULT_ADMIN_ROLE, previousOwner);
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
    }

    /**
     * @notice Grants `role` to `account`.
     * @param role The role to grant.
     * @param account The account to grant the role to.
     * @return True if the role was granted to the account, that is if the account did not already have the role,
     * false otherwise.
     */
    function _grantRole(bytes32 role, address account) internal returns (bool) {
        if (role == DEFAULT_ADMIN_ROLE && owner() != account || !_roles[role].members.add(account)) return false;

        emit RoleGranted(msg.sender, role, account);
        return true;
    }

    /**
     * @notice Revokes `role` from `account`.
     * @param role The role to revoke.
     * @param account The account to revoke the role from.
     * @return True if the role was revoked from the account, that is if the account had the role,
     * false otherwise.
     */
    function _revokeRole(bytes32 role, address account) internal returns (bool) {
        if (role == DEFAULT_ADMIN_ROLE && owner() != account || !_roles[role].members.remove(account)) return false;

        emit RoleRevoked(msg.sender, role, account);
        return true;
    }

    /**
     * @notice Sets `role` as the admin role of `adminRole`.
     * @param role The role to set as the admin role.
     * @param adminRole The role to set as the admin role of `role`.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        _roles[role].adminRole = adminRole;

        emit RoleAdminSet(msg.sender, role, adminRole);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./ISafeOwnable.sol";

/**
 * @title Safe Ownable
 * @author 0x0Louis
 * @notice This contract is used to manage the ownership of a contract in a two-step process.
 */
abstract contract SafeOwnable is ISafeOwnable {
    address private _owner;
    address private _pendingOwner;

    /**
     * @dev Modifier that checks if the caller is the owner.
     */
    modifier onlyOwner() {
        if (msg.sender != owner()) revert SafeOwnable__OnlyOwner();
        _;
    }

    /**
     * @dev Modifier that checks if the caller is the pending owner.
     */
    modifier onlyPendingOwner() {
        if (msg.sender != pendingOwner()) revert SafeOwnable__OnlyPendingOwner();
        _;
    }

    /**
     * @notice Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @notice Returns the address of the current owner.
     */
    function owner() public view virtual override returns (address) {
        return _owner;
    }

    /**
     * @notice Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual override returns (address) {
        return _pendingOwner;
    }

    /**
     * @notice Sets the pending owner to a new address.
     * @param newOwner The address to transfer ownership to.
     */
    function setPendingOwner(address newOwner) public virtual override onlyOwner {
        _setPendingOwner(newOwner);
    }

    /**
     * @notice Accepts ownership of the contract.
     * @dev Can only be called by the pending owner.
     */
    function becomeOwner() public virtual override onlyPendingOwner {
        address newOwner = _pendingOwner;

        _setPendingOwner(address(0));
        _transferOwnership(newOwner);
    }

    /**
     * Private Functions
     */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Sets the pending owner to a new address.
     * @param newPendingOwner The address to transfer ownership to.
     */
    function _setPendingOwner(address newPendingOwner) internal virtual {
        _pendingOwner = newPendingOwner;
        emit PendingOwnerSet(msg.sender, newPendingOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Enumerable Map
 * @author 0x0Louis
 * @notice Implements a simple enumerable map that maps keys to values.
 * @dev This library is very close to the EnumerableMap library from OpenZeppelin.
 * The main difference is that this library use only one storage slot to store the
 * keys and values while the OpenZeppelin library uses two storage slots.
 *
 * Enumerable maps have the folowing properties:
 *
 * - Elements are added, removed, updated, checked for existence and returned in constant time (O(1)).
 * - Elements are enumerated in linear time (O(n)). Enumeration is not guaranteed to be in any particular order.
 *
 * Usage:
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.AddressToUint96Map;
 *
 *    // Declare a map state variable
 *     EnumerableMap.AddressToUint96Map private _map;
 * ```
 *
 * Currently, only address keys to uint96 values are supported.
 *
 * The library also provides enumerable sets. Using the same implementation as the enumerable maps,
 * but the values and the keys are the same.
 */
library EnumerableMap {
    struct EnumerableMapping {
        bytes32[] _entries;
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @notice Returns the value at the given index.
     * @param self The enumerable mapping to query.
     * @param index The index.
     * @return value The value at the given index.
     */
    function _at(EnumerableMapping storage self, uint256 index) private view returns (bytes32 value) {
        value = self._entries[index];
    }

    /**
     * @notice Returns the value associated with the given key.
     * @dev Returns 0 if the key is not in the enumerable mapping. Use `contains` to check for existence.
     * @param self The enumerable mapping to query.
     * @param key The key.
     * @return value The value associated with the given key.
     */
    function _get(EnumerableMapping storage self, bytes32 key) private view returns (bytes32 value) {
        uint256 index = self._indexes[key];
        if (index == 0) return bytes12(0);

        value = _at(self, index - 1);
    }

    /**
     * @notice Returns true if the enumerable mapping contains the given key.
     * @param self The enumerable mapping to query.
     * @param key The key.
     * @return True if the given key is in the enumerable mapping.
     */
    function _contains(EnumerableMapping storage self, bytes32 key) private view returns (bool) {
        return self._indexes[key] != 0;
    }

    /**
     * @notice Returns the number of elements in the enumerable mapping.
     * @param self The enumerable mapping to query.
     * @return The number of elements in the enumerable mapping.
     */
    function _length(EnumerableMapping storage self) private view returns (uint256) {
        return self._entries.length;
    }

    /**
     * @notice Adds the given key and value to the enumerable mapping.
     * @param self The enumerable mapping to update.
     * @param offset The offset to add to the key.
     * @param key The key to add.
     * @param value The value associated with the key.
     * @return True if the key was added to the enumerable mapping, that is if it was not already in the enumerable mapping.
     */
    function _add(
        EnumerableMapping storage self,
        uint8 offset,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        if (!_contains(self, key)) {
            self._entries.push(_encode(offset, key, value));
            self._indexes[key] = self._entries.length;
            return true;
        }

        return false;
    }

    /**
     * @notice Removes a key from the enumerable mapping.
     * @param self The enumerable mapping to update.
     * @param offset The offset to use when removing the key.
     * @param key The key to remove.
     * @return True if the key was removed from the enumerable mapping, that is if it was present in the enumerable mapping.
     */
    function _remove(
        EnumerableMapping storage self,
        uint8 offset,
        bytes32 key
    ) private returns (bool) {
        uint256 keyIndex = self._indexes[key];

        if (keyIndex != 0) {
            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = self._entries.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastentry = self._entries[lastIndex];
                bytes32 lastKey = _decodeKey(offset, lastentry);

                self._entries[toDeleteIndex] = lastentry;
                self._indexes[lastKey] = keyIndex;
            }

            self._entries.pop();
            delete self._indexes[key];

            return true;
        }

        return false;
    }

    /**
     * @notice Updates the value associated with the given key in the enumerable mapping.
     * @param self The enumerable mapping to update.
     * @param offset The offset to use when setting the key.
     * @param key The key to set.
     * @param value The value to set.
     * @return True if the value was updated, that is if the key was already in the enumerable mapping.
     */
    function _update(
        EnumerableMapping storage self,
        uint8 offset,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        uint256 keyIndex = self._indexes[key];

        if (keyIndex != 0) {
            self._entries[keyIndex - 1] = _encode(offset, key, value);

            return true;
        }

        return false;
    }

    /**
     * @notice Encodes a key and a value into a bytes32.
     * @dev The key is encoded at the beginning of the bytes32 using the given offset.
     * The value is encoded at the end of the bytes32.
     * There is no overflow check, so the key and value must be small enough to fit both in the bytes32.
     * @param offset The offset to use when encoding the key.
     * @param key The key to encode.
     * @param value The value to encode.
     * @return encoded The encoded bytes32.
     */
    function _encode(
        uint8 offset,
        bytes32 key,
        bytes32 value
    ) private pure returns (bytes32 encoded) {
        encoded = (key << offset) | value;
    }

    /**
     * @notice Decodes a bytes32 into an addres key
     * @param offset The offset to use when decoding the key.
     * @param entry The bytes32 to decode.
     * @return key The key.
     */
    function _decodeKey(uint8 offset, bytes32 entry) private pure returns (bytes32 key) {
        key = entry >> offset;
    }

    /**
     * @notice Decodes a bytes32 into a bytes32 value.
     * @param mask The mask to use when decoding the value.
     * @param entry The bytes32 to decode.
     * @return value The decoded value.
     */
    function _decodeValue(uint256 mask, bytes32 entry) private pure returns (bytes32 value) {
        value = entry & bytes32(mask);
    }

    /** Address to Uint96 Map */

    /**
     * @dev Structure to represent a map of address keys to uint96 values.
     * The first 20 bytes of the key are used to store the address, and the last 12 bytes are used to store the uint96 value.
     */
    struct AddressToUint96Map {
        EnumerableMapping _inner;
    }

    uint256 private constant _ADDRESS_TO_UINT96_MAP_MASK = type(uint96).max;
    uint8 private constant _ADDRESS_TO_UINT96_MAP_OFFSET = 96;

    /**
     * @notice Returns the address key and the uint96 value at the given index.
     * @param self The address to uint96 map to query.
     * @param index The index.
     * @return key The key at the given index.
     * @return value The value at the given index.
     */
    function at(AddressToUint96Map storage self, uint256 index) internal view returns (address key, uint96 value) {
        bytes32 entry = _at(self._inner, index);

        key = address(uint160(uint256(_decodeKey(_ADDRESS_TO_UINT96_MAP_OFFSET, entry))));
        value = uint96(uint256(_decodeValue(_ADDRESS_TO_UINT96_MAP_MASK, entry)));
    }

    /**
     * @notice Returns the uint96 value associated with the given key.
     * @dev Returns 0 if the key is not in the map. Use `contains` to check for existence.
     * @param self The address to uint96 map to query.
     * @param key The address key.
     * @return value The uint96 value associated with the given key.
     */
    function get(AddressToUint96Map storage self, address key) internal view returns (uint96 value) {
        bytes32 entry = _get(self._inner, bytes32(uint256(uint160(key))));

        value = uint96(uint256(_decodeValue(_ADDRESS_TO_UINT96_MAP_MASK, entry)));
    }

    /**
     * @notice Returns the number of elements in the map.
     * @param self The address to uint96 map to query.
     * @return The number of elements in the map.
     */
    function length(AddressToUint96Map storage self) internal view returns (uint256) {
        return _length(self._inner);
    }

    /**
     * @notice Returns true if the map contains the given key.
     * @param self The address to uint96 map to query.
     * @param key The address key.
     * @return True if the map contains the given key.
     */
    function contains(AddressToUint96Map storage self, address key) internal view returns (bool) {
        return _contains(self._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @notice Adds a key-value pair to the map.
     * @param self The address to uint96 map to update.
     * @param key The address key.
     * @param value The uint96 value.
     * @return True if the key-value pair was added, that is if the key was not already in the map.
     */
    function add(
        AddressToUint96Map storage self,
        address key,
        uint96 value
    ) internal returns (bool) {
        return
            _add(self._inner, _ADDRESS_TO_UINT96_MAP_OFFSET, bytes32(uint256(uint160(key))), bytes32(uint256(value)));
    }

    /**
     * @notice Removes a key-value pair from the map.
     * @param self The address to uint96 map to update.
     * @param key The address key.
     * @return True if the key-value pair was removed, that is if the key was in the map.
     */
    function remove(AddressToUint96Map storage self, address key) internal returns (bool) {
        return _remove(self._inner, _ADDRESS_TO_UINT96_MAP_OFFSET, bytes32(uint256(uint160(key))));
    }

    /**
     * @notice Updates a key-value pair in the map.
     * @param self The address to uint96 map to update.
     * @param key The address key.
     * @param value The uint96 value.
     * @return True if the value was updated, that is if the key was already in the map.
     */
    function update(
        AddressToUint96Map storage self,
        address key,
        uint96 value
    ) internal returns (bool) {
        return
            _update(
                self._inner,
                _ADDRESS_TO_UINT96_MAP_OFFSET,
                bytes32(uint256(uint160(key))),
                bytes32(uint256(value))
            );
    }

    /** Bytes32 Set */

    /**
     * @dev Structure to represent a set of bytes32 values.
     */
    struct Bytes32Set {
        EnumerableMapping _inner;
    }

    uint8 private constant _BYTES32_SET_OFFSET = 0;

    // uint256 private constant _BYTES32_SET_MASK = type(uint256).max; // unused

    /**
     * @notice Returns the bytes32 value at the given index.
     * @param self The bytes32 set to query.
     * @param index The index.
     * @return value The value at the given index.
     */
    function at(Bytes32Set storage self, uint256 index) internal view returns (bytes32 value) {
        value = _at(self._inner, index);
    }

    /**
     * @notice Returns the number of elements in the set.
     * @param self The bytes32 set to query.
     * @return The number of elements in the set.
     */
    function length(Bytes32Set storage self) internal view returns (uint256) {
        return _length(self._inner);
    }

    /**
     * @notice Returns true if the set contains the given value.
     * @param self The bytes32 set to query.
     * @param value The bytes32 value.
     * @return True if the set contains the given value.
     */
    function contains(Bytes32Set storage self, bytes32 value) internal view returns (bool) {
        return _contains(self._inner, value);
    }

    /**
     * @notice Adds a value to the set.
     * @param self The bytes32 set to update.
     * @param value The bytes32 value.
     * @return True if the value was added, that is if the value was not already in the set.
     */
    function add(Bytes32Set storage self, bytes32 value) internal returns (bool) {
        return _add(self._inner, _BYTES32_SET_OFFSET, value, bytes32(0));
    }

    /**
     * @notice Removes a value from the set.
     * @param self The bytes32 set to update.
     * @param value The bytes32 value.
     * @return True if the value was removed, that is if the value was in the set.
     */
    function remove(Bytes32Set storage self, bytes32 value) internal returns (bool) {
        return _remove(self._inner, _BYTES32_SET_OFFSET, value);
    }

    /** Uint Set */

    /**
     * @dev Structure to represent a set of uint256 values.
     */
    struct UintSet {
        EnumerableMapping _inner;
    }

    uint8 private constant _UINT_SET_OFFSET = 0;

    // uint256 private constant _UINT_SET_MASK = type(uint256).max; // unused

    /**
     * @notice Returns the uint256 value at the given index.
     * @param self The uint256 set to query.
     * @param index The index.
     * @return value The value at the given index.
     */
    function at(UintSet storage self, uint256 index) internal view returns (uint256 value) {
        value = uint256(_at(self._inner, index));
    }

    /**
     * @notice Returns the number of elements in the set.
     * @param self The uint256 set to query.
     * @return The number of elements in the set.
     */
    function length(UintSet storage self) internal view returns (uint256) {
        return _length(self._inner);
    }

    /**
     * @notice Returns true if the set contains the given value.
     * @param self The uint256 set to query.
     * @param value The uint256 value.
     * @return True if the set contains the given value.
     */
    function contains(UintSet storage self, uint256 value) internal view returns (bool) {
        return _contains(self._inner, bytes32(value));
    }

    /**
     * @notice Adds a value to the set.
     * @param self The uint256 set to update.
     * @param value The uint256 value.
     * @return True if the value was added, that is if the value was not already in the set.
     */
    function add(UintSet storage self, uint256 value) internal returns (bool) {
        return _add(self._inner, _UINT_SET_OFFSET, bytes32(value), bytes32(0));
    }

    /**
     * @notice Removes a value from the set.
     * @param self The uint256 set to update.
     * @param value The uint256 value.
     * @return True if the value was removed, that is if the value was in the set.
     */
    function remove(UintSet storage self, uint256 value) internal returns (bool) {
        return _remove(self._inner, _UINT_SET_OFFSET, bytes32(value));
    }

    /** Address Set */

    /**
     * @dev Structure to represent a set of address values.
     */
    struct AddressSet {
        EnumerableMapping _inner;
    }

    // uint256 private constant _ADDRESS_SET_MASK = type(uint160).max; // unused
    uint8 private constant _ADDRESS_SET_OFFSET = 0;

    /**
     * @notice Returns the address value at the given index.
     * @param self The address set to query.
     * @param index The index.
     * @return value The value at the given index.
     */
    function at(AddressSet storage self, uint256 index) internal view returns (address value) {
        value = address(uint160(uint256(_at(self._inner, index))));
    }

    /**
     * @notice Returns the number of elements in the set.
     * @param self The address set to query.
     * @return The number of elements in the set.
     */
    function length(AddressSet storage self) internal view returns (uint256) {
        return _length(self._inner);
    }

    /**
     * @notice Returns true if the set contains the given value.
     * @param self The address set to query.
     * @param value The address value.
     * @return True if the set contains the given value.
     */
    function contains(AddressSet storage self, address value) internal view returns (bool) {
        return _contains(self._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @notice Adds a value to the set.
     * @param self The address set to update.
     * @param value The address value.
     * @return True if the value was added, that is if the value was not already in the set.
     */
    function add(AddressSet storage self, address value) internal returns (bool) {
        return _add(self._inner, _ADDRESS_SET_OFFSET, bytes32(uint256(uint160(value))), bytes32(0));
    }

    /**
     * @notice Removes a value from the set.
     * @param self The address set to update.
     * @param value The address value.
     * @return True if the value was removed, that is if the value was in the set.
     */
    function remove(AddressSet storage self, address value) internal returns (bool) {
        return _remove(self._inner, _ADDRESS_SET_OFFSET, bytes32(uint256(uint160(value))));
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Constants} from "joe-v2/libraries/Constants.sol";
import {IJoeFactory} from "joe-v2/interfaces/IJoeFactory.sol";
import {IJoePair} from "joe-v2/interfaces/IJoePair.sol";
import {ILBFactory} from "joe-v2/interfaces/ILBFactory.sol";
import {ILBLegacyFactory} from "joe-v2/interfaces/ILBLegacyFactory.sol";
import {ILBLegacyPair} from "joe-v2/interfaces/ILBLegacyPair.sol";
import {ILBLegacyRouter} from "joe-v2/interfaces/ILBLegacyRouter.sol";
import {ILBPair} from "joe-v2/interfaces/ILBPair.sol";
import {ILBRouter} from "joe-v2/interfaces/ILBRouter.sol";
import {Uint256x256Math} from "joe-v2/libraries/math/Uint256x256Math.sol";
import {IERC20Metadata, IERC20} from "openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import {
    ISafeAccessControlEnumerable, SafeAccessControlEnumerable
} from "solrary/access/SafeAccessControlEnumerable.sol";

import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";
import {IJoeDexLens} from "./interfaces/IJoeDexLens.sol";

/**
 * @title Joe Dex Lens
 * @author Trader Joe
 * @notice This contract allows to price tokens in either Native or a usd stable token.
 * It could be easily extended to any collateral. Owner can grant or revoke role to add data feeds to price a token
 * and can set the weight of the different data feeds. When no data feed is provided for both collateral, the contract
 * will use cascade through TOKEN/WNative and TOKEN/USD pools on v2.1, v2 and v1 to find a price.
 */
contract JoeDexLens is SafeAccessControlEnumerable, IJoeDexLens {
    using Uint256x256Math for uint256;

    bytes32 public constant DATA_FEED_MANAGER_ROLE = keccak256("DATA_FEED_MANAGER_ROLE");

    uint256 private constant _DECIMALS = 18;
    uint256 private constant _PRECISION = 10 ** _DECIMALS;

    IJoeFactory private immutable _FACTORY_V1;
    ILBLegacyFactory private immutable _LEGACY_FACTORY_V2;
    ILBFactory private immutable _FACTORY_V2_1;
    ILBLegacyRouter private immutable _LEGACY_ROUTER_V2;
    ILBRouter private immutable _ROUTER_V2_1;

    address private immutable _WNATIVE;
    address private immutable _USD_STABLE_COIN;

    uint256 private constant _BIN_WIDTH = 5;

    /**
     * @dev Mapping from a collateral token to a token to an enumerable set of data feeds used to get the price of the token in collateral
     * e.g. STABLECOIN => Native will return datafeeds to get the price of Native in USD
     * And Native => JOE will return datafeeds to get the price of JOE in Native
     */
    mapping(address => mapping(address => DataFeedSet)) private _whitelistedDataFeeds;

    /**
     * Modifiers *
     */

    /**
     * @notice Verify that the two lengths match
     * @dev Revert if length are not equal
     * @param lengthA The length of the first list
     * @param lengthB The length of the second list
     */
    modifier verifyLengths(uint256 lengthA, uint256 lengthB) {
        if (lengthA != lengthB) revert JoeDexLens__LengthsMismatch();
        _;
    }

    /**
     * @notice Verify a data feed
     * @dev Revert if :
     * - The collateral and the token are the same address
     * - The collateral is not one of the two tokens of the pair (if the dfType is V1 or V2)
     * - The token is not one of the two tokens of the pair (if the dfType is V1 or V2)
     * @param collateral The address of the collateral (STABLECOIN or WNATIVE)
     * @param token The address of the token
     * @param dataFeed The data feeds information
     */
    modifier verifyDataFeed(address collateral, address token, DataFeed calldata dataFeed) {
        if (collateral == token) revert JoeDexLens__SameTokens();

        if (dataFeed.dfType == dfType.V1) {
            if (address(_FACTORY_V1) == address(0)) revert JoeDexLens__V1ContractNotSet();
        } else if (dataFeed.dfType == dfType.V2) {
            if (address(_LEGACY_FACTORY_V2) == address(0) || address(_LEGACY_ROUTER_V2) == address(0)) {
                revert JoeDexLens__V2ContractNotSet();
            }
        } else if (dataFeed.dfType == dfType.V2_1) {
            if (address(_FACTORY_V2_1) == address(0) || address(_ROUTER_V2_1) == address(0)) {
                revert JoeDexLens__V2_1ContractNotSet();
            }
        } else if (dataFeed.dfType != dfType.CHAINLINK) {
            (address tokenA, address tokenB) = _getTokens(dataFeed);

            if (tokenA != collateral && tokenB != collateral) {
                revert JoeDexLens__CollateralNotInPair(dataFeed.dfAddress, collateral);
            }
            if (tokenA != token && tokenB != token) revert JoeDexLens__TokenNotInPair(dataFeed.dfAddress, token);
        }
        _;
    }

    /**
     * @notice Verify the weight for a data feed
     * @dev Revert if the weight is equal to 0
     * @param weight The weight of a data feed
     */
    modifier verifyWeight(uint88 weight) {
        if (weight == 0) revert JoeDexLens__NullWeight();
        _;
    }

    /**
     * Constructor *
     */

    constructor(
        ILBRouter lbRouter,
        ILBFactory lbFactory,
        ILBLegacyRouter lbLegacyRouter,
        ILBLegacyFactory lbLegacyFactory,
        IJoeFactory joeFactory,
        address wnative,
        address usdStableCoin
    ) {
        // revert if all addresses are zero
        if (
            address(lbRouter) == address(0) && address(lbFactory) == address(0) && address(lbLegacyRouter) == address(0)
                && address(lbLegacyFactory) == address(0) && address(joeFactory) == address(0)
        ) {
            revert JoeDexLens__ZeroAddress();
        }

        if (address(lbRouter) != address(0)) {
            if (lbRouter.getFactory() != lbFactory) revert JoeDexLens__LBV2_1AddressMismatch();
            if (
                address(lbLegacyRouter) != address(0) && address(lbLegacyFactory) != address(0)
                    && (lbRouter.getLegacyRouter() != lbLegacyRouter || lbRouter.getLegacyFactory() != lbLegacyFactory)
            ) {
                revert JoeDexLens__LBV2AddressMismatch();
            }
            if (address(joeFactory) != address(0) && lbRouter.getV1Factory() != joeFactory) {
                revert JoeDexLens__JoeV1AddressMismatch();
            }
            if (address(lbRouter.getWAVAX()) != wnative) revert JoeDexLens__WNativeMismatch();
        } else if (address(lbFactory) != address(0)) {
            // Make sure that if lbRouter is not set, lbFactory is not set either
            revert JoeDexLens__LBV2_1AddressMismatch();
        }

        if (address(lbLegacyRouter) != address(0)) {
            // Sanity check that the getIdFromPrice function exists
            try lbLegacyRouter.getIdFromPrice(ILBLegacyPair(address(0)), 0) {} catch {}
            lbLegacyFactory.getNumberOfLBPairs(); // Sanity check
        } else if (address(lbLegacyFactory) != address(0)) {
            // Make sure that if lbLegacyRouter is not set, lbLegacyFactory is not set either
            revert JoeDexLens__LBV2AddressMismatch();
        }

        if (address(joeFactory) != address(0)) joeFactory.allPairsLength(); // Sanity check

        if (wnative == address(0) || usdStableCoin == address(0)) revert JoeDexLens__ZeroAddress();

        _ROUTER_V2_1 = lbRouter;
        _FACTORY_V2_1 = lbFactory;

        _LEGACY_ROUTER_V2 = lbLegacyRouter;
        _LEGACY_FACTORY_V2 = lbLegacyFactory;

        _FACTORY_V1 = joeFactory;

        _WNATIVE = wnative;
        _USD_STABLE_COIN = usdStableCoin;
    }

    /**
     * External View Functions *
     */

    /**
     * @notice Returns the address of the wrapped native token
     * @return wNative The address of the wrapped native token
     */
    function getWNative() external view override returns (address wNative) {
        return _WNATIVE;
    }

    /**
     * @notice Returns the address of the usd stable coin
     * @return stableCoin The address of the usd stable coin
     */
    function getUSDStableCoin() external view override returns (address stableCoin) {
        return _USD_STABLE_COIN;
    }

    /**
     * @notice Returns the address of the router v2
     * @return legacyRouterV2 The address of the router v2
     */
    function getLegacyRouterV2() external view override returns (ILBLegacyRouter legacyRouterV2) {
        return _LEGACY_ROUTER_V2;
    }

    /**
     * @notice Returns the address of the router v2.1
     * @return routerV2 The address of the router v2.1
     */
    function getRouterV2() external view override returns (ILBRouter routerV2) {
        return _ROUTER_V2_1;
    }

    /**
     * @notice Returns the address of the factory v1
     * @return factoryV1 The address of the factory v1
     */
    function getFactoryV1() external view override returns (IJoeFactory factoryV1) {
        return _FACTORY_V1;
    }

    /**
     * @notice Returns the address of the factory v2
     * @return legacyFactoryV2 The address of the factory v2
     */
    function getLegacyFactoryV2() external view override returns (ILBLegacyFactory legacyFactoryV2) {
        return _LEGACY_FACTORY_V2;
    }

    /**
     * @notice Returns the address of the factory v2.1
     * @return factoryV2 The address of the factory v2.1
     */
    function getFactoryV2() external view override returns (ILBFactory factoryV2) {
        return _FACTORY_V2_1;
    }

    /**
     * @notice Returns the list of data feeds used to calculate the price of the token in stable coin
     * @param token The address of the token
     * @return dataFeeds The array of data feeds used to price `token` in stable coin
     */
    function getUSDDataFeeds(address token) external view override returns (DataFeed[] memory dataFeeds) {
        return _whitelistedDataFeeds[_USD_STABLE_COIN][token].dataFeeds;
    }

    /**
     * @notice Returns the list of data feeds used to calculate the price of the token in Native
     * @param token The address of the token
     * @return dataFeeds The array of data feeds used to price `token` in Native
     */
    function getNativeDataFeeds(address token) external view override returns (DataFeed[] memory dataFeeds) {
        return _whitelistedDataFeeds[_WNATIVE][token].dataFeeds;
    }

    /**
     * @notice Returns the price of token in USD, scaled with 6 decimals
     * @param token The address of the token
     * @return price The price of the token in USD, with 6 decimals
     */
    function getTokenPriceUSD(address token) external view override returns (uint256 price) {
        return _getTokenWeightedAveragePrice(_USD_STABLE_COIN, token);
    }

    /**
     * @notice Returns the price of token in Native, scaled with `_DECIMALS` decimals
     * @param token The address of the token
     * @return price The price of the token in Native, with `_DECIMALS` decimals
     */
    function getTokenPriceNative(address token) external view override returns (uint256 price) {
        return _getTokenWeightedAveragePrice(_WNATIVE, token);
    }

    /**
     * @notice Returns the prices of each token in USD, scaled with 6 decimals
     * @param tokens The list of address of the tokens
     * @return prices The prices of each token in USD, with 6 decimals
     */
    function getTokensPricesUSD(address[] calldata tokens) external view override returns (uint256[] memory prices) {
        return _getTokenWeightedAveragePrices(_USD_STABLE_COIN, tokens);
    }

    /**
     * @notice Returns the prices of each token in Native, scaled with `_DECIMALS` decimals
     * @param tokens The list of address of the tokens
     * @return prices The prices of each token in Native, with `_DECIMALS` decimals
     */
    function getTokensPricesNative(address[] calldata tokens)
        external
        view
        override
        returns (uint256[] memory prices)
    {
        return _getTokenWeightedAveragePrices(_WNATIVE, tokens);
    }

    /**
     * Owner Functions *
     */

    /**
     * @notice Add a USD data feed for a specific token
     * @dev Can only be called by the owner
     * @param token The address of the token
     * @param dataFeed The USD data feeds information
     */
    function addUSDDataFeed(address token, DataFeed calldata dataFeed)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _addDataFeed(_USD_STABLE_COIN, token, dataFeed);
    }

    /**
     * @notice Add a Native data feed for a specific token
     * @dev Can only be called by the owner
     * @param token The address of the token
     * @param dataFeed The Native data feeds information
     */
    function addNativeDataFeed(address token, DataFeed calldata dataFeed)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _addDataFeed(_WNATIVE, token, dataFeed);
    }

    /**
     * @notice Set the USD weight for a specific data feed of a token
     * @dev Can only be called by the owner
     * @param token The address of the token
     * @param dfAddress The USD data feed address
     * @param newWeight The new weight of the data feed
     */
    function setUSDDataFeedWeight(address token, address dfAddress, uint88 newWeight)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _setDataFeedWeight(_USD_STABLE_COIN, token, dfAddress, newWeight);
    }

    /**
     * @notice Set the Native weight for a specific data feed of a token
     * @dev Can only be called by the owner
     * @param token The address of the token
     * @param dfAddress The data feed address
     * @param newWeight The new weight of the data feed
     */
    function setNativeDataFeedWeight(address token, address dfAddress, uint88 newWeight)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _setDataFeedWeight(_WNATIVE, token, dfAddress, newWeight);
    }

    /**
     * @notice Remove a USD data feed of a token
     * @dev Can only be called by the owner
     * @param token The address of the token
     * @param dfAddress The USD data feed address
     */
    function removeUSDDataFeed(address token, address dfAddress)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _removeDataFeed(_USD_STABLE_COIN, token, dfAddress);
    }

    /**
     * @notice Remove a Native data feed of a token
     * @dev Can only be called by the owner
     * @param token The address of the token
     * @param dfAddress The data feed address
     */
    function removeNativeDataFeed(address token, address dfAddress)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _removeDataFeed(_WNATIVE, token, dfAddress);
    }

    /**
     * @notice Batch add USD data feed for each (token, data feed)
     * @dev Can only be called by the owner
     * @param tokens The addresses of the tokens
     * @param dataFeeds The list of USD data feeds informations
     */
    function addUSDDataFeeds(address[] calldata tokens, DataFeed[] calldata dataFeeds)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _addDataFeeds(_USD_STABLE_COIN, tokens, dataFeeds);
    }

    /**
     * @notice Batch add Native data feed for each (token, data feed)
     * @dev Can only be called by the owner
     * @param tokens The addresses of the tokens
     * @param dataFeeds The list of Native data feeds informations
     */
    function addNativeDataFeeds(address[] calldata tokens, DataFeed[] calldata dataFeeds)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _addDataFeeds(_WNATIVE, tokens, dataFeeds);
    }

    /**
     * @notice Batch set the USD weight for each (token, data feed)
     * @dev Can only be called by the owner
     * @param tokens The list of addresses of the tokens
     * @param dfAddresses The list of USD data feed addresses
     * @param newWeights The list of new weights of the data feeds
     */
    function setUSDDataFeedsWeights(
        address[] calldata tokens,
        address[] calldata dfAddresses,
        uint88[] calldata newWeights
    ) external override onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE) {
        _setDataFeedsWeights(_USD_STABLE_COIN, tokens, dfAddresses, newWeights);
    }

    /**
     * @notice Batch set the Native weight for each (token, data feed)
     * @dev Can only be called by the owner
     * @param tokens The list of addresses of the tokens
     * @param dfAddresses The list of Native data feed addresses
     * @param newWeights The list of new weights of the data feeds
     */
    function setNativeDataFeedsWeights(
        address[] calldata tokens,
        address[] calldata dfAddresses,
        uint88[] calldata newWeights
    ) external override onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE) {
        _setDataFeedsWeights(_WNATIVE, tokens, dfAddresses, newWeights);
    }

    /**
     * @notice Batch remove a list of USD data feeds for each (token, data feed)
     * @dev Can only be called by the owner
     * @param tokens The list of addresses of the tokens
     * @param dfAddresses The list of USD data feed addresses
     */
    function removeUSDDataFeeds(address[] calldata tokens, address[] calldata dfAddresses)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _removeDataFeeds(_USD_STABLE_COIN, tokens, dfAddresses);
    }

    /**
     * @notice Batch remove a list of Native data feeds for each (token, data feed)
     * @dev Can only be called by the owner
     * @param tokens The list of addresses of the tokens
     * @param dfAddresses The list of Native data feed addresses
     */
    function removeNativeDataFeeds(address[] calldata tokens, address[] calldata dfAddresses)
        external
        override
        onlyOwnerOrRole(DATA_FEED_MANAGER_ROLE)
    {
        _removeDataFeeds(_WNATIVE, tokens, dfAddresses);
    }

    /**
     * Private Functions *
     */

    /**
     * @notice Returns the data feed length for a specific collateral and a token
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @return length The number of data feeds
     */
    function _getDataFeedsLength(address collateral, address token) private view returns (uint256 length) {
        return _whitelistedDataFeeds[collateral][token].dataFeeds.length;
    }

    /**
     * @notice Returns the data feed at index `index` for a specific collateral and a token
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @param index The index
     * @return dataFeed the data feed at index `index`
     */
    function _getDataFeedAt(address collateral, address token, uint256 index)
        private
        view
        returns (DataFeed memory dataFeed)
    {
        return _whitelistedDataFeeds[collateral][token].dataFeeds[index];
    }

    /**
     * @notice Returns if a (tokens)'s set contains the data feed address
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @param dfAddress The data feed address
     * @return Whether the set contains the data feed address (true) or not (false)
     */
    function dataFeedContains(address collateral, address token, address dfAddress) private view returns (bool) {
        return _whitelistedDataFeeds[collateral][token].indexes[dfAddress] != 0;
    }

    /**
     * @notice Add a data feed to a set, return true if it was added, false if not
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @param dataFeed The data feeds information
     * @return Whether the data feed was added (true) to the set or not (false)
     */
    function _addToSet(address collateral, address token, DataFeed calldata dataFeed) private returns (bool) {
        if (!dataFeedContains(collateral, token, dataFeed.dfAddress)) {
            DataFeedSet storage set = _whitelistedDataFeeds[collateral][token];

            set.dataFeeds.push(dataFeed);
            set.indexes[dataFeed.dfAddress] = set.dataFeeds.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Remove a data feed from a set, returns true if it was removed, false if not
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @param dfAddress The data feed address
     * @return Whether the data feed was removed (true) from the set or not (false)
     */
    function _removeFromSet(address collateral, address token, address dfAddress) private returns (bool) {
        DataFeedSet storage set = _whitelistedDataFeeds[collateral][token];
        uint256 dataFeedIndex = set.indexes[dfAddress];

        if (dataFeedIndex != 0) {
            uint256 toDeleteIndex = dataFeedIndex - 1;
            uint256 lastIndex = set.dataFeeds.length - 1;

            if (toDeleteIndex != lastIndex) {
                DataFeed memory lastDataFeed = set.dataFeeds[lastIndex];

                set.dataFeeds[toDeleteIndex] = lastDataFeed;
                set.indexes[lastDataFeed.dfAddress] = dataFeedIndex;
            }

            set.dataFeeds.pop();
            delete set.indexes[dfAddress];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Add a data feed to a set, revert if it couldn't add it
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @param dataFeed The data feeds information
     */
    function _addDataFeed(address collateral, address token, DataFeed calldata dataFeed)
        private
        verifyDataFeed(collateral, token, dataFeed)
        verifyWeight(dataFeed.dfWeight)
    {
        if (!_addToSet(collateral, token, dataFeed)) {
            revert JoeDexLens__DataFeedAlreadyAdded(collateral, token, dataFeed.dfAddress);
        }

        emit DataFeedAdded(collateral, token, dataFeed);
    }

    /**
     * @notice Batch add data feed for each (collateral, token, data feed)
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param tokens The addresses of the tokens
     * @param dataFeeds The list of USD data feeds informations
     */
    function _addDataFeeds(address collateral, address[] calldata tokens, DataFeed[] calldata dataFeeds)
        private
        verifyLengths(tokens.length, dataFeeds.length)
    {
        for (uint256 i; i < tokens.length;) {
            _addDataFeed(collateral, tokens[i], dataFeeds[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Set the weight for a specific data feed of a (collateral, token)
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @param dfAddress The data feed address
     * @param newWeight The new weight of the data feed
     */
    function _setDataFeedWeight(address collateral, address token, address dfAddress, uint88 newWeight)
        private
        verifyWeight(newWeight)
    {
        DataFeedSet storage set = _whitelistedDataFeeds[collateral][token];

        uint256 index = set.indexes[dfAddress];

        if (index == 0) revert JoeDexLens__DataFeedNotInSet(collateral, token, dfAddress);

        set.dataFeeds[index - 1].dfWeight = newWeight;

        emit DataFeedsWeightSet(collateral, token, dfAddress, newWeight);
    }

    /**
     * @notice Batch set the weight for each (collateral, token, data feed)
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param tokens The list of addresses of the tokens
     * @param dfAddresses The list of USD data feed addresses
     * @param newWeights The list of new weights of the data feeds
     */
    function _setDataFeedsWeights(
        address collateral,
        address[] calldata tokens,
        address[] calldata dfAddresses,
        uint88[] calldata newWeights
    ) private verifyLengths(tokens.length, dfAddresses.length) verifyLengths(tokens.length, newWeights.length) {
        for (uint256 i; i < tokens.length;) {
            _setDataFeedWeight(collateral, tokens[i], dfAddresses[i], newWeights[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Remove a data feed from a set, revert if it couldn't remove it
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @param dfAddress The data feed address
     */
    function _removeDataFeed(address collateral, address token, address dfAddress) private {
        if (!_removeFromSet(collateral, token, dfAddress)) {
            revert JoeDexLens__DataFeedNotInSet(collateral, token, dfAddress);
        }

        emit DataFeedRemoved(collateral, token, dfAddress);
    }

    /**
     * @notice Batch remove a list of collateral data feeds for each (token, data feed)
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param tokens The list of addresses of the tokens
     * @param dfAddresses The list of USD data feed addresses
     */
    function _removeDataFeeds(address collateral, address[] calldata tokens, address[] calldata dfAddresses)
        private
        verifyLengths(tokens.length, dfAddresses.length)
    {
        for (uint256 i; i < tokens.length;) {
            _removeDataFeed(collateral, tokens[i], dfAddresses[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Return the weighted average price of a token using its collateral data feeds
     * @dev If no data feed was provided, will use `_getPriceAnyToken` to try to find a valid price
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @return price The weighted average price of the token, with the collateral's decimals
     */
    function _getTokenWeightedAveragePrice(address collateral, address token) private view returns (uint256 price) {
        uint256 decimals = IERC20Metadata(collateral).decimals();
        if (collateral == token) return 10 ** decimals;

        uint256 length = _getDataFeedsLength(collateral, token);

        if (length == 0) {
            // fallback on other collateral
            address otherCollateral = collateral == _WNATIVE ? _USD_STABLE_COIN : _WNATIVE;

            uint256 lengthOtherCollateral = _getDataFeedsLength(otherCollateral, token);
            uint256 lengthCollateral = _getDataFeedsLength(otherCollateral, collateral);

            if (lengthOtherCollateral == 0 || lengthCollateral == 0) {
                return _getPriceAnyToken(collateral, token);
            }

            uint256 tokenPrice = _getTokenWeightedAveragePrice(otherCollateral, token);
            uint256 collateralPrice = _getTokenWeightedAveragePrice(otherCollateral, collateral);

            // Both price are in the same decimals
            return tokenPrice * 10 ** decimals / collateralPrice;
        }

        uint256 dfPrice;
        uint256 totalWeights;
        for (uint256 i; i < length;) {
            DataFeed memory dataFeed = _getDataFeedAt(collateral, token, i);

            if (dataFeed.dfType == dfType.V1) {
                dfPrice = _getPriceFromV1(dataFeed.dfAddress, token);
            } else if (dataFeed.dfType == dfType.V2) {
                dfPrice = _getPriceFromV2(dataFeed.dfAddress, token);
            } else if (dataFeed.dfType == dfType.V2_1) {
                dfPrice = _getPriceFromV2_1(dataFeed.dfAddress, token);
            } else if (dataFeed.dfType == dfType.CHAINLINK) {
                dfPrice = _getPriceFromChainlink(dataFeed.dfAddress);
            } else {
                revert JoeDexLens__UnknownDataFeedType();
            }

            price += dfPrice * dataFeed.dfWeight;
            totalWeights += dataFeed.dfWeight;

            unchecked {
                ++i;
            }
        }

        price /= totalWeights;

        // Return the price with the collateral's decimals
        if (decimals < _DECIMALS) price /= 10 ** (_DECIMALS - decimals);
        else if (decimals > _DECIMALS) price *= 10 ** (decimals - _DECIMALS);
    }

    /**
     * @notice Batch function to return the weighted average price of each tokens using its collateral data feeds
     * @dev If no data feed was provided, will use `_getPriceAnyToken` to try to find a valid price
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param tokens The list of addresses of the tokens
     * @return prices The list of weighted average price of each token, with the collateral's decimals
     */
    function _getTokenWeightedAveragePrices(address collateral, address[] calldata tokens)
        private
        view
        returns (uint256[] memory prices)
    {
        prices = new uint256[](tokens.length);
        for (uint256 i; i < tokens.length;) {
            prices[i] = _getTokenWeightedAveragePrice(collateral, tokens[i]);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Return the price tracked by the aggreagator using chainlink's data feed, with `_DECIMALS` decimals
     * @param dfAddress The address of the data feed
     * @return price The price tracked by the aggreagator, with `_DECIMALS` decimals
     */
    function _getPriceFromChainlink(address dfAddress) private view returns (uint256 price) {
        AggregatorV3Interface aggregator = AggregatorV3Interface(dfAddress);

        (, int256 sPrice,,,) = aggregator.latestRoundData();
        if (sPrice <= 0) revert JoeDexLens__InvalidChainLinkPrice();

        price = uint256(sPrice);

        uint256 aggregatorDecimals = aggregator.decimals();

        // Return the price with `_DECIMALS` decimals
        if (aggregatorDecimals < _DECIMALS) price *= 10 ** (_DECIMALS - aggregatorDecimals);
        else if (aggregatorDecimals > _DECIMALS) price /= 10 ** (aggregatorDecimals - _DECIMALS);
    }

    /**
     * @notice Return the price of the token denominated in the second token of the V1 pair, with `_DECIMALS` decimals
     * @dev The `token` token needs to be on of the two paired token of the given pair
     * @param pairAddress The address of the pair
     * @param token The address of the token
     * @return price The price of the token, with `_DECIMALS` decimals
     */
    function _getPriceFromV1(address pairAddress, address token) private view returns (uint256 price) {
        IJoePair pair = IJoePair(pairAddress);

        address token0 = pair.token0();
        address token1 = pair.token1();

        uint256 decimals0 = IERC20Metadata(token0).decimals();
        uint256 decimals1 = IERC20Metadata(token1).decimals();

        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();

        // Return the price with `_DECIMALS` decimals
        if (token == token0) {
            return reserve0 == 0 ? 0 : (reserve1 * 10 ** (decimals0 + _DECIMALS)) / (reserve0 * 10 ** decimals1);
        } else if (token == token1) {
            return reserve1 == 0 ? 0 : (reserve0 * 10 ** (decimals1 + _DECIMALS)) / (reserve1 * 10 ** decimals0);
        } else {
            revert JoeDexLens__WrongPair();
        }
    }

    /**
     * @notice Return the price of the token denominated in the second token of the V2 pair, with `_DECIMALS` decimals
     * @dev The `token` token needs to be on of the two paired token of the given pair
     * @param pairAddress The address of the pair
     * @param token The address of the token
     * @return price The price of the token, with `_DECIMALS` decimals
     */
    function _getPriceFromV2(address pairAddress, address token) private view returns (uint256 price) {
        ILBLegacyPair pair = ILBLegacyPair(pairAddress);

        (,, uint256 activeID) = pair.getReservesAndId();
        uint256 priceScaled = _LEGACY_ROUTER_V2.getPriceFromId(pair, uint24(activeID));

        address tokenX = address(pair.tokenX());
        address tokenY = address(pair.tokenY());

        uint256 decimalsX = IERC20Metadata(tokenX).decimals();
        uint256 decimalsY = IERC20Metadata(tokenY).decimals();

        // Return the price with `_DECIMALS` decimals
        if (token == tokenX) {
            return priceScaled.mulShiftRoundDown(10 ** (18 + decimalsX - decimalsY), Constants.SCALE_OFFSET);
        } else if (token == tokenY) {
            return (type(uint256).max / priceScaled).mulShiftRoundDown(
                10 ** (18 + decimalsY - decimalsX), Constants.SCALE_OFFSET
            );
        } else {
            revert JoeDexLens__WrongPair();
        }
    }

    /**
     * @notice Return the price of the token denominated in the second token of the V2.1 pair, with `_DECIMALS` decimals
     * @dev The `token` token needs to be on of the two paired token of the given pair
     * @param pairAddress The address of the pair
     * @param token The address of the token
     * @return price The price of the token, with `_DECIMALS` decimals
     */
    function _getPriceFromV2_1(address pairAddress, address token) private view returns (uint256 price) {
        ILBPair pair = ILBPair(pairAddress);

        uint256 activeID = pair.getActiveId();
        uint256 priceScaled = _ROUTER_V2_1.getPriceFromId(pair, uint24(activeID));

        address tokenX = address(pair.getTokenX());
        address tokenY = address(pair.getTokenY());

        uint256 decimalsX = IERC20Metadata(tokenX).decimals();
        uint256 decimalsY = IERC20Metadata(tokenY).decimals();

        // Return the price with `_DECIMALS` decimals
        if (token == tokenX) {
            return priceScaled.mulShiftRoundDown(10 ** (18 + decimalsX - decimalsY), Constants.SCALE_OFFSET);
        } else if (token == tokenY) {
            return (type(uint256).max / priceScaled).mulShiftRoundDown(
                10 ** (18 + decimalsY - decimalsX), Constants.SCALE_OFFSET
            );
        } else {
            revert JoeDexLens__WrongPair();
        }
    }

    /**
     * @notice Return the addresses of the two tokens of a pair
     * @dev Work with both V1 or V2 pairs
     * @param dataFeed The data feeds information
     * @return tokenA The address of the first token of the pair
     * @return tokenB The address of the second token of the pair
     */
    function _getTokens(DataFeed calldata dataFeed) private view returns (address tokenA, address tokenB) {
        if (dataFeed.dfType == dfType.V1) {
            IJoePair pair = IJoePair(dataFeed.dfAddress);

            tokenA = pair.token0();
            tokenB = pair.token1();
        } else if (dataFeed.dfType == dfType.V2) {
            ILBLegacyPair pair = ILBLegacyPair(dataFeed.dfAddress);

            tokenA = address(pair.tokenX());
            tokenB = address(pair.tokenY());
        } else if (dataFeed.dfType == dfType.V2_1) {
            ILBPair pair = ILBPair(dataFeed.dfAddress);

            tokenA = address(pair.getTokenX());
            tokenB = address(pair.getTokenY());
        } else {
            revert JoeDexLens__UnknownDataFeedType();
        }
    }

    /**
     * @notice Tries to find the price of the token on v2.1, v2 and v1 pairs.
     * V2.1 and v2 pairs are checked to have enough liquidity in them,
     * to avoid pricing using stale pools
     * @dev Will revert if no pools were created
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param token The address of the token
     * @return price The weighted average, based on pair's liquidity, of the token with the collateral's decimals
     */
    function _getPriceAnyToken(address collateral, address token) private view returns (uint256 price) {
        // First check the token price on v2.1
        price = _v2_1FallbackPrice(collateral, token);

        // Then on v2
        if (price == 0) {
            price = _v2FallbackPrice(collateral, token);
        }

        // If none of the above worked, check with the other collateral
        if (price == 0) {
            address otherCollateral = collateral == _WNATIVE ? _USD_STABLE_COIN : _WNATIVE;

            // First check the token price on v2.1
            uint256 priceTokenOtherCollateral = _v2_1FallbackPrice(otherCollateral, token);

            // Then on v2
            if (priceTokenOtherCollateral == 0) {
                priceTokenOtherCollateral = _v2FallbackPrice(otherCollateral, token);
            }

            // If it worked, convert the price with the correct collateral
            if (priceTokenOtherCollateral > 0) {
                uint256 collateralPrice = _getTokenWeightedAveragePrice(otherCollateral, collateral);

                uint256 collateralDecimals = IERC20Metadata(collateral).decimals();
                uint256 otherCollateralDecimals = IERC20Metadata(otherCollateral).decimals();

                price = collateralPrice == 0
                    ? 0
                    : priceTokenOtherCollateral * 10 ** (_DECIMALS + collateralDecimals - otherCollateralDecimals)
                        / collateralPrice;
            }
        }

        // If none of the above worked, check on v1 pairs
        if (price == 0) {
            price = _v1FallbackPrice(collateral, token);
        }
    }

    /**
     * @notice Loops through all the collateral/token v2.1 pairs and returns the price of the token if a valid one was found
     * @param collateral The address of the collateral
     * @param token The address of the token
     * @return price The price of the token, with the collateral's decimals (0 if no valid pair was found)
     */
    function _v2_1FallbackPrice(address collateral, address token) private view returns (uint256 price) {
        if (address(_FACTORY_V2_1) == address(0) || address(_ROUTER_V2_1) == address(0)) {
            return 0;
        }

        ILBFactory.LBPairInformation[] memory lbPairsAvailable =
            _FACTORY_V2_1.getAllLBPairs(IERC20(collateral), IERC20(token));

        if (lbPairsAvailable.length != 0) {
            for (uint256 i = 0; i < lbPairsAvailable.length; i++) {
                if (
                    _validateV2_1Pair(
                        lbPairsAvailable[i].LBPair,
                        IERC20Metadata(address(lbPairsAvailable[i].LBPair.getTokenX())).decimals(),
                        IERC20Metadata(address(lbPairsAvailable[i].LBPair.getTokenY())).decimals()
                    )
                ) {
                    return _getPriceFromV2_1(address(lbPairsAvailable[i].LBPair), token);
                }
            }
        }
    }

    /**
     * @notice Loops through all the collateral/token v2 pairs and returns the price of the token if a valid one was found
     * @param collateral The address of the collateral
     * @param token The address of the token
     * @return price The price of the token, with the collateral's decimals (0 if no valid pair was found)
     */
    function _v2FallbackPrice(address collateral, address token) private view returns (uint256 price) {
        if (address(_LEGACY_FACTORY_V2) == address(0) || address(_LEGACY_ROUTER_V2) == address(0)) {
            return 0;
        }

        ILBLegacyFactory.LBPairInformation[] memory lbPairsAvailable =
            _LEGACY_FACTORY_V2.getAllLBPairs(IERC20(collateral), IERC20(token));

        if (lbPairsAvailable.length != 0) {
            for (uint256 i = 0; i < lbPairsAvailable.length; i++) {
                if (
                    _validateV2Pair(
                        lbPairsAvailable[i].LBPair,
                        IERC20Metadata(address(lbPairsAvailable[i].LBPair.tokenX())).decimals(),
                        IERC20Metadata(address(lbPairsAvailable[i].LBPair.tokenY())).decimals()
                    )
                ) {
                    return _getPriceFromV2(address(lbPairsAvailable[i].LBPair), token);
                }
            }
        }
    }

    /**
     * @notice Fetchs the collateral/token and otherCollateral/token v1 pairs and returns the price of the token if a valid one was found
     * @param collateral The address of the collateral
     * @param token The address of the token
     * @return price The price of the token, with the collateral's decimals
     */
    function _v1FallbackPrice(address collateral, address token) private view returns (uint256 price) {
        if (address(_FACTORY_V1) == address(0)) return 0;

        address pairTokenWNative = _FACTORY_V1.getPair(token, _WNATIVE);
        address pairTokenUsdc = _FACTORY_V1.getPair(token, _USD_STABLE_COIN);

        if (pairTokenWNative != address(0) && pairTokenUsdc != address(0)) {
            uint256 priceOfNative = _getTokenWeightedAveragePrice(collateral, _WNATIVE);
            uint256 priceOfUSDC = _getTokenWeightedAveragePrice(collateral, _USD_STABLE_COIN);

            uint256 priceInUSDC = _getPriceFromV1(pairTokenUsdc, token);
            uint256 priceInNative = _getPriceFromV1(pairTokenWNative, token);

            uint256 totalReserveInUSDC = _getReserveInTokenAFromV1(pairTokenUsdc, _USD_STABLE_COIN, token);
            uint256 totalReserveinWNative = _getReserveInTokenAFromV1(pairTokenWNative, _WNATIVE, token);

            uint256 weightUSDC = (totalReserveInUSDC * priceOfUSDC) / _PRECISION;
            uint256 weightWNative = (totalReserveinWNative * priceOfNative) / _PRECISION;

            uint256 totalWeights;
            uint256 weightedPriceUSDC = (priceInUSDC * priceOfUSDC * weightUSDC) / _PRECISION;
            if (weightedPriceUSDC != 0) totalWeights += weightUSDC;

            uint256 weightedPriceNative = (priceInNative * priceOfNative * weightWNative) / _PRECISION;
            if (weightedPriceNative != 0) totalWeights += weightWNative;

            return totalWeights == 0 ? 0 : (weightedPriceUSDC + weightedPriceNative) / totalWeights;
        } else if (pairTokenWNative != address(0)) {
            return _getPriceInCollateralFromV1(collateral, pairTokenWNative, _WNATIVE, token);
        } else if (pairTokenUsdc != address(0)) {
            return _getPriceInCollateralFromV1(collateral, pairTokenUsdc, _USD_STABLE_COIN, token);
        }
    }

    /**
     * @notice Checks if a v2.1 pair is valid
     * @dev A pair is valid if the total reserves of the pair are above the minimum threshold
     * and the reserves of the _BIN_WIDTH bin around the active bin are above the minimum threshold
     * @param pair The pair to validate
     * @param tokenXDecimals The decimals of the token X
     * @param tokenYDecimals The decimals of the token Y
     * @return isValid True if the pair is valid, false otherwise
     */
    function _validateV2_1Pair(ILBPair pair, uint256 tokenXDecimals, uint256 tokenYDecimals)
        private
        view
        returns (bool isValid)
    {
        uint256 activeId = pair.getActiveId();

        (uint256 reserveX, uint256 reserveY) = pair.getReserves();

        // Skip if the total reserves of the pair are too low
        if (!_validateReserves(reserveX, reserveY, tokenXDecimals, tokenYDecimals)) {
            return false;
        }

        // Skip if the reserves of the _BIN_WIDTH bin around the active bin are too low
        reserveX = reserveY = 0;
        for (uint256 i = activeId - _BIN_WIDTH; i <= activeId + _BIN_WIDTH; i++) {
            (uint256 binReserveX, uint256 binReserveY) = pair.getBin(uint24(i));
            reserveX += binReserveX;
            reserveY += binReserveY;
        }

        if (!_validateReserves(reserveX, reserveY, tokenXDecimals, tokenYDecimals)) {
            return false;
        }

        return true;
    }

    /**
     * @notice Checks if a v2 pair is valid
     * @dev A pair is valid if the total reserves of the pair are above the minimum threshold
     * and the reserves of the _BIN_WIDTH bin around the active bin are above the minimum threshold
     * @param pair The pair to validate
     * @param tokenXDecimals The decimals of the token X
     * @param tokenYDecimals The decimals of the token Y
     * @return isValid True if the pair is valid, false otherwise
     */
    function _validateV2Pair(ILBLegacyPair pair, uint256 tokenXDecimals, uint256 tokenYDecimals)
        private
        view
        returns (bool isValid)
    {
        (uint256 reserveX, uint256 reserveY, uint256 activeId) = pair.getReservesAndId();

        // Skip if the total reserves of the pair are too low
        if (!_validateReserves(reserveX, reserveY, tokenXDecimals, tokenYDecimals)) {
            return false;
        }

        // Skip if the reserves of the _BIN_WIDTH bin around the active bin are too low
        reserveX = reserveY = 0;
        for (uint256 i = activeId - _BIN_WIDTH; i <= activeId + _BIN_WIDTH; i++) {
            (uint256 binReserveX, uint256 binReserveY) = pair.getBin(uint24(i));
            reserveX += binReserveX;
            reserveY += binReserveY;
        }

        if (!_validateReserves(reserveX, reserveY, tokenXDecimals, tokenYDecimals)) {
            return false;
        }

        return true;
    }

    /**
     * @notice Checks if the pair reserves are above the minimum threshold
     * @param reserveX The reserve of the token X
     * @param reserveY The reserve of the token Y
     * @param tokenXDecimals The decimals of the token X
     * @param tokenYDecimals The decimals of the token Y
     */
    function _validateReserves(uint256 reserveX, uint256 reserveY, uint256 tokenXDecimals, uint256 tokenYDecimals)
        private
        pure
        returns (bool isValid)
    {
        // Need at least one unit of each token in the reserves
        return reserveX > 10 ** tokenXDecimals && reserveY > 10 ** tokenYDecimals;
    }

    /**
     * @notice Return the price in collateral of a token from a V1 pair
     * @param collateral The address of the collateral (USDC or WNATIVE)
     * @param pairAddress The address of the V1 pair
     * @param tokenBase The address of the base token of the pair, i.e. the collateral one
     * @param token The address of the token
     * @return priceInCollateral The price of the token in collateral, with the collateral's decimals
     */
    function _getPriceInCollateralFromV1(address collateral, address pairAddress, address tokenBase, address token)
        private
        view
        returns (uint256 priceInCollateral)
    {
        uint256 priceInBase = _getPriceFromV1(pairAddress, token);
        uint256 priceOfBase = _getTokenWeightedAveragePrice(collateral, tokenBase);

        // Return the price with the collateral's decimals
        return (priceInBase * priceOfBase) / _PRECISION;
    }

    /**
     * @notice Return the entire TVL of a pair in token A, with `_DECIMALS` decimals
     * @dev tokenA and tokenB needs to be the two tokens paired in the given pair
     * @param pairAddress The address of the pair
     * @param tokenA The address of one of the pair's token
     * @param tokenB The address of the other pair's token
     * @return totalReserveInTokenA The total reserve of the pool in token A
     */
    function _getReserveInTokenAFromV1(address pairAddress, address tokenA, address tokenB)
        private
        view
        returns (uint256 totalReserveInTokenA)
    {
        IJoePair pair = IJoePair(pairAddress);

        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        uint8 decimals = IERC20Metadata(tokenA).decimals();

        if (tokenA < tokenB) totalReserveInTokenA = reserve0 * 2;
        else totalReserveInTokenA = reserve1 * 2;

        if (decimals < _DECIMALS) totalReserveInTokenA *= 10 ** (_DECIMALS - decimals);
        else if (decimals > _DECIMALS) totalReserveInTokenA /= 10 ** (decimals - _DECIMALS);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {IJoeFactory} from "joe-v2/interfaces/IJoeFactory.sol";
import {ILBFactory} from "joe-v2/interfaces/ILBFactory.sol";
import {ILBLegacyFactory} from "joe-v2/interfaces/ILBLegacyFactory.sol";
import {ILBLegacyRouter} from "joe-v2/interfaces/ILBLegacyRouter.sol";
import {ILBRouter} from "joe-v2/interfaces/ILBRouter.sol";
import {ISafeAccessControlEnumerable} from "solrary/access/ISafeAccessControlEnumerable.sol";

import {AggregatorV3Interface} from "../interfaces/AggregatorV3Interface.sol";

/// @title Interface of the Joe Dex Lens contract
/// @author Trader Joe
/// @notice The interface needed to interract with the Joe Dex Lens contract
interface IJoeDexLens is ISafeAccessControlEnumerable {
    error JoeDexLens__UnknownDataFeedType();
    error JoeDexLens__CollateralNotInPair(address pair, address collateral);
    error JoeDexLens__TokenNotInPair(address pair, address token);
    error JoeDexLens__SameTokens();
    error JoeDexLens__DataFeedAlreadyAdded(address colateral, address token, address dataFeed);
    error JoeDexLens__DataFeedNotInSet(address colateral, address token, address dataFeed);
    error JoeDexLens__LengthsMismatch();
    error JoeDexLens__NullWeight();
    error JoeDexLens__WrongPair();
    error JoeDexLens__InvalidChainLinkPrice();
    error JoeDexLens__NotEnoughLiquidity();
    error JoeDexLens__V1ContractNotSet();
    error JoeDexLens__V2ContractNotSet();
    error JoeDexLens__V2_1ContractNotSet();
    error JoeDexLens__LBV2_1AddressMismatch();
    error JoeDexLens__LBV2AddressMismatch();
    error JoeDexLens__JoeV1AddressMismatch();
    error JoeDexLens__WNativeMismatch();
    error JoeDexLens__ZeroAddress();

    /// @notice Enumerators of the different data feed types
    enum dfType {
        V1,
        V2,
        V2_1,
        CHAINLINK
    }

    /// @notice Structure for data feeds, contains the data feed's address and its type.
    /// For V1/V2, the`dfAddress` should be the address of the pair
    /// For chainlink, the `dfAddress` should be the address of the aggregator
    struct DataFeed {
        address dfAddress;
        uint88 dfWeight;
        dfType dfType;
    }

    /// @notice Structure for a set of data feeds
    /// `datafeeds` is the list of addresses of all the data feeds
    /// `indexes` is a mapping linking the address of a data feed to its index in the `datafeeds` list.
    struct DataFeedSet {
        DataFeed[] dataFeeds;
        mapping(address => uint256) indexes;
    }

    event DataFeedAdded(address collateral, address token, DataFeed dataFeed);

    event DataFeedsWeightSet(address collateral, address token, address dfAddress, uint256 weight);

    event DataFeedRemoved(address collateral, address token, address dfAddress);

    function getWNative() external view returns (address wNative);

    function getUSDStableCoin() external view returns (address usd);

    function getLegacyRouterV2() external view returns (ILBLegacyRouter legacyRouterV2);

    function getRouterV2() external view returns (ILBRouter routerV2);

    function getFactoryV1() external view returns (IJoeFactory factoryV1);

    function getLegacyFactoryV2() external view returns (ILBLegacyFactory legacyFactoryV2);

    function getFactoryV2() external view returns (ILBFactory factoryV2);

    function getUSDDataFeeds(address token) external view returns (DataFeed[] memory dataFeeds);

    function getNativeDataFeeds(address token) external view returns (DataFeed[] memory dataFeeds);

    function getTokenPriceUSD(address token) external view returns (uint256 price);

    function getTokenPriceNative(address token) external view returns (uint256 price);

    function getTokensPricesUSD(address[] calldata tokens) external view returns (uint256[] memory prices);

    function getTokensPricesNative(address[] calldata tokens) external view returns (uint256[] memory prices);

    function addUSDDataFeed(address token, DataFeed calldata dataFeed) external;

    function addNativeDataFeed(address token, DataFeed calldata dataFeed) external;

    function setUSDDataFeedWeight(address token, address dfAddress, uint88 newWeight) external;

    function setNativeDataFeedWeight(address token, address dfAddress, uint88 newWeight) external;

    function removeUSDDataFeed(address token, address dfAddress) external;

    function removeNativeDataFeed(address token, address dfAddress) external;

    function addUSDDataFeeds(address[] calldata tokens, DataFeed[] calldata dataFeeds) external;

    function addNativeDataFeeds(address[] calldata tokens, DataFeed[] calldata dataFeeds) external;

    function setUSDDataFeedsWeights(
        address[] calldata _tokens,
        address[] calldata _dfAddresses,
        uint88[] calldata _newWeights
    ) external;

    function setNativeDataFeedsWeights(
        address[] calldata _tokens,
        address[] calldata _dfAddresses,
        uint88[] calldata _newWeights
    ) external;

    function removeUSDDataFeeds(address[] calldata tokens, address[] calldata dfAddresses) external;

    function removeNativeDataFeeds(address[] calldata tokens, address[] calldata dfAddresses) external;
}