// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../interfaces/IPositionHouse.sol";
import "../interfaces/IPositionHouseViewer.sol";
import "../interfaces/IPositionManager.sol";
import "./libraries/types/PositionStrategyOrderStorage.sol";
import {Errors} from "./libraries/helpers/Errors.sol";

contract PositionStrategyOrder is
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    PositionStrategyOrderStorage
{
    using Position for Position.Data;

    event TPSLCreated(address pmAddress, address trader, uint128 higherPip, uint128 lowerPip);
    event TPOrSlCanceled(address pmAddress, address trader, bool isHigherPrice);
    event TPAndSLCanceled(address pmAddress, address trader);
    event TPSLTriggered(address pmAddress, address trader);

    function initialize(
        IPositionHouse _positionHouse,
        IPositionHouseViewer _positionHouseViewer
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        positionHouse = _positionHouse;
        positionHouseViewer = _positionHouseViewer;
    }

    function triggerTPSL(IPositionManager _positionManager, address _trader) external nonReentrant {
        address _pmAddress = address(_positionManager);
        uint128 currentPip = _positionManager.getCurrentPip();
        TPSLCondition memory condition = TPSLMap[_pmAddress][_trader];
        require(reachTPSL(condition, currentPip), Errors.VL_MUST_REACH_CONDITION);
        positionHouse.triggerClosePosition(_positionManager, _trader);
        emit TPSLTriggered(_pmAddress, _trader);
    }

    function setTPSL(address _pmAddress, uint128 _higherPip, uint128 _lowerPip, SetTPSLOption _option) external nonReentrant {
        IPositionManager _positionManager = IPositionManager(_pmAddress);
        uint128 currentPip = _positionManager.getCurrentPip();
        require(isValidInput(currentPip, _higherPip, _lowerPip, _option), Errors.VL_INVALID_CONDITION);
        address _trader = msg.sender;
        Position.Data memory positionData = positionHouseViewer.getPosition(_pmAddress, _trader);
        require(positionData.quantity != 0, Errors.VL_MUST_HAVE_POSITION);

        if (_option == SetTPSLOption.ONLY_HIGHER) {
            TPSLMap[_pmAddress][_trader].higherPip = uint120(_higherPip);
        } else if (_option == SetTPSLOption.ONLY_LOWER) {
            TPSLMap[_pmAddress][_trader].lowerPip = uint120(_lowerPip);
        } else if (_option == SetTPSLOption.BOTH) {
            TPSLMap[_pmAddress][_trader].higherPip = uint120(_higherPip);
            TPSLMap[_pmAddress][_trader].lowerPip = uint120(_lowerPip);
        }
        TPSLMap[_pmAddress][_trader].__dummy = 1;
        emit TPSLCreated(_pmAddress, _trader, _higherPip, _lowerPip);
    }

    function unsetTPOrSL(address _pmAddress, bool _isHigherPrice) external nonReentrant {
        address _trader = msg.sender;
        Position.Data memory positionData = positionHouseViewer.getPosition(_pmAddress, _trader);
        require(positionData.quantity != 0, Errors.VL_MUST_HAVE_POSITION);
        if (_isHigherPrice) {
            TPSLMap[_pmAddress][_trader].higherPip = 0;
        } else {
            TPSLMap[_pmAddress][_trader].lowerPip = 0;
        }
        emit TPOrSlCanceled(_pmAddress, _trader, _isHigherPrice);
    }

    function unsetTPAndSL(address _pmAddress) external nonReentrant {
        address _trader = msg.sender;
        Position.Data memory positionData = positionHouseViewer.getPosition(_pmAddress, _trader);
        require(positionData.quantity != 0, Errors.VL_MUST_HAVE_POSITION);
        _internalUnsetTPAndSL(_pmAddress, _trader);
    }

    function unsetTPAndSLWhenClosePosition(address _pmAddress, address _trader) external onlyPositionHouse {
        _internalUnsetTPAndSL(_pmAddress, _trader);
    }

    function updateValidatedTriggererStatus(address _triggerer, bool _isValidated) external onlyOwner {
        validatedTriggerers[_triggerer] = _isValidated;
    }

    function getTPSLDetail(address _pmAddress, address _trader) public view returns (uint120 lowerPip, uint120 higherPip) {
        TPSLCondition memory condition = TPSLMap[_pmAddress][_trader];
        lowerPip = condition.lowerPip;
        higherPip = condition.higherPip;
    }

    function hasTPOrSL(address _pmAddress, address _trader) public view returns (bool) {
        TPSLCondition memory condition = TPSLMap[_pmAddress][_trader];
        return condition.lowerPip != 0 || condition.higherPip != 0;
    }

    function _internalUnsetTPAndSL(address _pmAddress, address _trader) internal {
        TPSLMap[_pmAddress][_trader].lowerPip = 0;
        TPSLMap[_pmAddress][_trader].higherPip = 0;
        emit TPAndSLCanceled(_pmAddress, _trader);
    }

    // REQUIRE FUNCTION
    function reachTPSL(TPSLCondition memory condition, uint128 currentPip) internal returns (bool) {
        return (condition.lowerPip != 0 && currentPip <= condition.lowerPip) || (currentPip >= condition.higherPip && condition.higherPip != 0);
    }

    function isValidInput(uint128 currentPrice, uint128 _higherPip, uint128 _lowerPip, SetTPSLOption _option) internal returns (bool){
        if (_option == SetTPSLOption.BOTH) {
            return _higherPip != 0 && _lowerPip != 0 && _higherPip > currentPrice && currentPrice > _lowerPip;
        } else if (_option == SetTPSLOption.ONLY_HIGHER) {
            return _higherPip != 0 && _lowerPip == 0 && _higherPip > currentPrice;
        } else if (_option == SetTPSLOption.ONLY_LOWER) {
            return _higherPip == 0 && _lowerPip != 0 && currentPrice > _lowerPip;
        }
    }

    modifier onlyPositionHouse() {
        require(msg.sender == address(positionHouse), Errors.VL_ONLY_POSITION_HOUSE);
        _;
    }

    modifier onlyValidatedTriggerer() {
        require(validatedTriggerers[msg.sender], Errors.VL_ONLY_VALIDATED_TRIGGERS);
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import "../protocol/libraries/position/Position.sol";
import "../protocol/libraries/position/PositionLimitOrder.sol";

interface IPositionHouse {
    function getPosition(address _pmAddress, address _trader)
    external
    view
    returns (Position.Data memory positionData);

    function positionMap(address _pmAddress, address _trader) external view returns (Position.Data memory positionData);

    function _getLimitOrders(address _pmAddress, address _trader)
    external
    view
    returns (PositionLimitOrder.Data[] memory);

    function _getReduceLimitOrders(address _pmAddress, address _trader)
    external
    view
    returns (PositionLimitOrder.Data[] memory);

    function _getManualMargin(address _pmAddress, address _trader)
    external
    view
    returns (int256);

    function getClaimableAmount(address _pmAddress, address _trader)
    external
    view
    returns (uint256);

    function getLatestCumulativePremiumFraction(address _pmAddress)
    external
    view
    returns (int128);

    function getLimitOrderPremiumFraction(address _pmAddress, address _trader)
    external
    view
    returns (int128);

    function getAddedMargin(address _positionManager, address _trader)
    external
    view
    returns (int256);

    function getDebtPosition(address _pmAddress, address _trader)
    external
    view
    returns (Position.LiquidatedData memory);

    function triggerClosePosition(IPositionManager _positionManager, address _trader)
    external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IPositionManager.sol";
import "../protocol/libraries/types/PositionHouseStorage.sol";

interface IPositionHouseViewer {
    function getMaintenanceDetail(
        IPositionManager _positionManager,
        address _trader,
        PositionHouseStorage.PnlCalcOption _calcOption
    )
        external
        view
        returns (
            uint256 maintenanceMargin,
            int256 marginBalance,
            uint256 marginRatio,
            uint256 liquidationPrice
        );

    function getPositionNotionalAndUnrealizedPnl(
        IPositionManager _positionManager,
        address _trader,
        PositionHouseStorage.PnlCalcOption _pnlCalcOption,
        Position.Data memory _oldPosition
    ) external view returns (uint256 positionNotional, int256 unrealizedPnl);

    function getPosition(
        address _pmAddress,
        address _trader
    ) external view returns (Position.Data memory positionData);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../protocol/libraries/types/PositionManagerStorage.sol";
import "../protocol/libraries/types/MarketMaker.sol";

interface IPositionManager {
    // EVENT

    // Events that supports building order book
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 passedPipCount,
        uint128 remainingLiquidity
    );
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );
    event LimitOrderCancelled(
        bool isBuy,
        uint64 orderId,
        uint128 pip,
        uint256 remainingSize
    );

    event UpdateMaxFindingWordsIndex(uint128 newMaxFindingWordsIndex);
    event MaxWordRangeForLimitOrderUpdated(uint128 newMaxWordRangeForLimitOrder);
    event MaxWordRangeForMarketOrderUpdated(uint128 newMaxWordRangeForMarketOrder);
    event UpdateBasisPoint(uint256 newBasicPoint);
    event UpdateBaseBasicPoint(uint256 newBaseBasisPoint);
    event UpdateTollRatio(uint256 newTollRatio);
    event UpdateSpotPriceTwapInterval(uint256 newSpotPriceTwapInterval);
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);
    event FundingRateUpdated(int256 fundingRate, uint256 underlyingPrice);
    event LimitOrderUpdated(uint64 orderId, uint128 pip, uint256 size);
    event LeverageUpdated(uint128 oldLeverage, uint128 newLeverage);
    event MaxMarketMakerSlipageUpdated(
        uint32 oldMaxMarketMakerSlipage,
        uint32 newMaxMarketMakerSlipage
    );

    // FUNCTIONS
    function pause() external;

    function unpause() external;

    function updateMaxFindingWordsIndex(uint128 _newMaxFindingWordsIndex)
        external;

    function updateMaxWordRangeForLimitOrder(uint128 _newMaxWordRangeForLimitOrder)
        external;

    function updateMaxWordRangeForMarketOrder(uint128 _newMaxWordRangeForMarketOrder)
        external;

    function updateBasisPoint(uint64 _newBasisPoint) external;

    function updateBaseBasicPoint(uint64 _newBaseBasisPoint) external;

    function updateTollRatio(uint256 _newTollRatio) external;

    function setCounterParty(address _counterParty) external;

    function updateSpotPriceTwapInterval(uint256 _spotPriceTwapInterval)
        external;

    function getBasisPointFactors() external view returns (uint64 base, uint64 basisPoint);

    function hasLiquidity(uint128 _pip) external returns (bool);

    function getLeverage() external view returns (uint128);

    function getCurrentPip() external view returns (uint128);

    function getBaseBasisPoint() external view returns (uint256);

    function getBasisPoint() external view returns (uint256);

    function getCurrentSingleSlot() external view returns (uint128, uint8);

    function getLiquidityInCurrentPip() external view returns (uint128);

    function getPrice() external view returns (uint256);

    function getUnderlyingPriceInPip() external view returns (uint256);

    function pipToPrice(uint128 pip) external view returns (uint256);

    function getQuoteAsset() external view returns (IERC20);

    function getUnderlyingPrice() external view returns (uint256);

    function getNextFundingTime() external view returns (uint256);

    function getPremiumFraction() external view returns (int256, uint256);

    function updatePartialFilledOrder(uint128 pip, uint64 orderId) external;

    function getUnderlyingTwapPrice(uint256 _intervalInSeconds)
        external
        view
        returns (uint256);

    function implGetReserveTwapPrice(uint256 _intervalInSeconds)
        external
        view
        returns (uint256);

    function getTwapPrice(uint256 _intervalInSeconds)
        external
        view
        returns (uint256);

    function calcTwap(
        PositionManagerStorage.TwapPriceCalcParams memory _params,
        uint256 _intervalInSeconds
    ) external view returns (uint256);

    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    function getNotionalMarginAndFee(
        uint256 _pQuantity,
        uint128 _pip,
        uint16 _leverage
    )
        external
        view
        returns (
            uint256 notional,
            uint256 margin,
            uint256 fee
        );

    function marketMakerRemove(MarketMaker.MMCancelOrder[] memory _orders)
        external;

    function marketMakerSupply(
        MarketMaker.MMOrder[] memory _orders,
        uint256 leverage
    ) external;

    function marketMakerFill(
        MarketMaker.MMFill[] memory _mmFills,
        uint256 _leverage
    ) external;

    function openLimitPosition(
        uint128 pip,
        uint128 size,
        bool isBuy
    )
        external
        returns (
            uint64 orderId,
            uint256 sizeOut,
            uint256 openNotional
        );

    function getLiquidityInPipRange(
        uint128 _fromPip,
        uint256 _dataLength,
        bool _toHigher
    )
        external
        view
        returns (PositionManagerStorage.PipLiquidity[] memory, uint128, uint8);

    function openMarketPosition(uint256 size, bool isBuy)
        external
        returns (
            uint256 sizeOut,
            uint256 openNotional,
            uint256 entryPrice,
            uint256 fee
        );

    function calcFee(uint256 _positionNotional) external view returns (uint256);

    function getCurrentFundingRate() external view returns (int256 fundingRate);

    function cancelLimitOrder(uint128 pip, uint64 orderId)
        external
        returns (uint256 refundSize, uint256 partialFilled);

    function settleFunding() external returns (int256 premiumFraction);

    function updateLeverage(uint128 _newLeverage) external;

    function deposit(
        address _trader,
        uint256 _amount,
        uint256 _fee
    ) external;

    function withdraw(
        address _trader,
        uint256 _amount
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;
import "../../../interfaces/IPositionHouse.sol";
import "../../../interfaces/IPositionHouseViewer.sol";


abstract contract PositionStrategyOrderStorage {
    using Position for Position.Data;

    enum SetTPSLOption {
        BOTH,
        ONLY_HIGHER,
        ONLY_LOWER
    }

    struct TPSLCondition {
        uint120 higherPip;
        uint120 lowerPip;
        uint8 __dummy;
    }

    mapping (address => bool) public validatedTriggerers;
    mapping (address => mapping(address => TPSLCondition)) public TPSLMap;
    IPositionHouse public positionHouse;
    IPositionHouseViewer public positionHouseViewer;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

/**
 * @title Errors libraries
 * @author Position Exchange
 * @notice Defines the error messages emitted by the different contracts of the Position Exchange protocol
 * @dev Error messages prefix glossary:
 *  - VL = ValidationLogic
 *  - MATH = Math libraries
 *  - CT = Common errors between tokens (AToken, VariableDebtToken and StableDebtToken)
 *  - P = Pausable
 *  - A = Amm
 */
library Errors {
    //common errors

    //contract specific errors
    //    string public constant VL_INVALID_AMOUNT = '1'; // 'Amount must be greater than 0'
    string public constant VL_EMPTY_ADDRESS = "2";
    //    string public constant VL_INVALID_QUANTITY = '3'; // 'IQ'
    string public constant VL_INVALID_LEVERAGE = "4"; // 'IL'
    string public constant VL_INVALID_CLOSE_QUANTITY = "5"; // 'ICQ'
    string public constant VL_INVALID_CLAIM_FUND = "6"; // 'ICF'
    string public constant VL_NOT_ENOUGH_MARGIN_RATIO = "7"; // 'NEMR'
    string public constant VL_NO_POSITION_TO_REMOVE = "8"; // 'NPTR'
    string public constant VL_NO_POSITION_TO_ADD = "9"; // 'NPTA'
    string public constant VL_INVALID_QUANTITY_INTERNAL_CLOSE = "10"; // 'IQIC'
    string public constant VL_NOT_ENOUGH_LIQUIDITY = "11"; // 'NELQ'
    string public constant VL_INVALID_REMOVE_MARGIN = "12"; // 'IRM'
    string public constant VL_NOT_COUNTERPARTY = "13"; // 'IRM'
    string public constant VL_INVALID_INPUT = "14"; // 'IP'
    string public constant VL_SETTLE_FUNDING_TOO_EARLY = "15"; // 'SFTE'
    string public constant VL_LONG_PRICE_THAN_CURRENT_PRICE = "16"; // '!B'
    string public constant VL_SHORT_PRICE_LESS_CURRENT_PRICE = "17"; // '!S'
    string public constant VL_INVALID_SIZE = "18"; // ''
    string public constant VL_NOT_WHITELIST_MANAGER = "19"; // ''
    string public constant VL_INVALID_ORDER = "20"; // ''
    string public constant VL_ONLY_PENDING_ORDER = "21"; // ''
    string public constant VL_MUST_SAME_SIDE_SHORT = "22.1";
    string public constant VL_MUST_SAME_SIDE_LONG = "22.2";
    string public constant VL_MUST_SMALLER_REVERSE_QUANTITY = "23";
    string public constant VL_MUST_CLOSE_TO_INDEX_PRICE_SHORT = "24.1";
    string public constant VL_MUST_CLOSE_TO_INDEX_PRICE_LONG = "24.2";
    string public constant VL_MARKET_ORDER_MUST_CLOSE_TO_INDEX_PRICE = "25";
    string public constant VL_EXCEED_MAX_NOTIONAL = "26";
    string public constant VL_MUST_HAVE_POSITION = "27";
    string public constant VL_MUST_REACH_CONDITION = "28";
    string public constant VL_ONLY_POSITION_STRATEGY_ORDER = "29";
    string public constant VL_ONLY_POSITION_HOUSE = "30";
    string public constant VL_ONLY_VALIDATED_TRIGGERS = "31";
    string public constant VL_INVALID_CONDITION = "32";
    string public constant VL_MUST_BE_INTEGER = "33";

    enum CollateralManagerErrors {
        NO_ERROR
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../helpers/Quantity.sol";
//import "hardhat/console.sol";
import "../../../interfaces/IPositionManager.sol";

library Position {
    using Quantity for int256;
    enum Side {
        LONG,
        SHORT
    }
    struct Data {
        int256 quantity;
        uint256 margin;
        uint256 openNotional;
        // Packed slot
        int128 lastUpdatedCumulativePremiumFraction;
        uint64 blockNumber;
        uint16 leverage;
        // this slot leaves 48 bit
        // use 8 bit for this dummy
        // set __dummy to 1 when clear position
        // to avoid reinitializing a new slot
        // when open a new position
        // saved ~20,000 gas
        uint8 __dummy;
    }

    struct LiquidatedData {
        int256 quantity;
        uint256 margin;
        uint256 notional;
    }

    function updateDebt(
        Position.LiquidatedData storage _self,
        int256 _quantity,
        uint256 _margin,
        uint256 _notional
    ) internal {
        _self.quantity += _quantity;
        _self.margin += _margin;
        _self.notional += _notional;
    }

    function update(
        Position.Data storage _self,
        Position.Data memory _newPosition
    ) internal {
        _self.quantity = _newPosition.quantity;
        _self.margin = _newPosition.margin;
        _self.openNotional = _newPosition.openNotional;
        _self.lastUpdatedCumulativePremiumFraction = _newPosition
            .lastUpdatedCumulativePremiumFraction;
        _self.blockNumber = _newPosition.blockNumber;
        _self.leverage = _newPosition.leverage;
    }

    function updateMargin(Position.Data storage _self, uint256 _newMargin)
        internal
    {
        _self.margin = _newMargin;
    }

    function updatePartialLiquidate(
        Position.Data storage _self,
        Position.Data memory _newPosition
    ) internal {
        _self.quantity += _newPosition.quantity;
        _self.margin -= _newPosition.margin;
        _self.openNotional -= _newPosition.openNotional;
        _self.lastUpdatedCumulativePremiumFraction += _newPosition
            .lastUpdatedCumulativePremiumFraction;
        _self.blockNumber += _newPosition.blockNumber;
        _self.leverage = _self.leverage;
    }

    function clearDebt(Position.LiquidatedData storage _self) internal {
        _self.quantity = 0;
        _self.margin = 0;
        _self.notional = 0;
    }

    function clear(Position.Data storage _self) internal {
        _self.quantity = 0;
        _self.margin = 0;
        _self.openNotional = 0;
        _self.lastUpdatedCumulativePremiumFraction = 0;
        _self.blockNumber = uint64(block.number);
        _self.leverage = 0;
        _self.__dummy = 1;
    }

    function side(Position.Data memory _self)
        internal
        view
        returns (Position.Side)
    {
        return _self.quantity > 0 ? Position.Side.LONG : Position.Side.SHORT;
    }

    function getEntryPrice(
        Position.Data memory _self,
        address _addressPositionManager
    ) internal view returns (uint256) {
        IPositionManager _positionManager = IPositionManager(
            _addressPositionManager
        );
        return
            (_self.openNotional * _positionManager.getBaseBasisPoint()) /
            _self.quantity.abs();
    }

    function accumulateLimitOrder(
        Position.Data memory _self,
        int256 _quantity,
        uint256 _orderMargin,
        uint256 _orderNotional
    ) internal view returns (Position.Data memory) {
        // same side
        if (_self.quantity * _quantity > 0) {
            _self.margin = _self.margin + _orderMargin;
            _self.openNotional = _self.openNotional + _orderNotional;
        } else {
            _self.margin = _self.margin > _orderMargin
                ? _self.margin - _orderMargin
                : _orderMargin - _self.margin;
            _self.openNotional = _self.openNotional > _orderNotional
                ? _self.openNotional - _orderNotional
                : _orderNotional - _self.openNotional;
        }
        _self.quantity = _self.quantity + _quantity;
        return _self;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Position.sol";
//import "hardhat/console.sol";
import "../../../interfaces/IPositionManager.sol";

library PositionLimitOrder {
    enum OrderType {
        OPEN_LIMIT,
        CLOSE_LIMIT
    }
    struct Data {
        uint128 pip;
        uint64 orderId;
        uint16 leverage;
        //        OrderType typeLimitOrder;
        uint8 isBuy;
        uint256 entryPrice;
        uint256 reduceLimitOrderId;
        uint256 reduceQuantity;
        uint64 blockNumber;
    }

    //    struct ReduceData {
    //        int128 pip;
    //        uint64 orderId;
    //        uint16 leverage;
    ////        OrderType typeLimitOrder;
    //        uint8 isBuy;
    //    }
    //
    //    function clearLimitOrder(
    //        PositionLimitOrder.Data self
    //    ) internal {
    //        self.pip = 0;
    //        self.orderId = 0;
    //        self.leverage = 0;
    //    }

    //    function checkFilledToSelfOrders(
    //        mapping(address => mapping(address => PositionLimitOrder.Data[])) storage limitOrderMap,
    //        IPositionManager _positionManager,
    //        address _trader,
    //        int128 startPip,
    //        int128 endPip,
    //        Position.Side side
    //    ) internal view returns (uint256 selfFilledQuantity) {
    //        uint256 gasBefore = gasleft();
    //        // check if fill to self limit orders
    //        PositionLimitOrder.Data[] memory listLimitOrder = limitOrderMap[address(_positionManager)][_trader];
    //        for(uint256 i; i<listLimitOrder.length; i++){
    //            PositionLimitOrder.Data memory limitOrder = listLimitOrder[i];
    //            if(limitOrder.isBuy == 1 && side == Position.Side.SHORT){
    //                if(endPip <= limitOrder.pip && startPip >= limitOrder.pip){
    //                    (,,uint256 size, uint256 partialFilledSize) = _positionManager.getPendingOrderDetail(limitOrder.pip, limitOrder.orderId);
    //                    selfFilledQuantity += (size > partialFilledSize ? size - partialFilledSize : size);
    //                }
    //            }
    //            if(limitOrder.isBuy == 2 && side == Position.Side.LONG){
    //                if(endPip >= limitOrder.pip){
    //                    (,,uint256 size, uint256 partialFilledSize) = _positionManager.getPendingOrderDetail(limitOrder.pip, limitOrder.orderId);
    //                    selfFilledQuantity += (size > partialFilledSize ? size - partialFilledSize : size);
    //                }
    //            }
    //        }
    //    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

library Quantity {
    function getExchangedQuoteAssetAmount(
        int256 _quantity,
        uint256 _openNotional,
        uint256 _oldPQuantity
    ) internal pure returns (uint256) {
        return (abs(_quantity) * _openNotional) / _oldPQuantity;
    }

    function getPartiallyLiquidate(
        int256 _quantity,
        uint256 _liquidationPenaltyRatio
    ) internal pure returns (int256) {
        return (_quantity * int256(_liquidationPenaltyRatio)) / 100;
    }

    function isSameSide(int256 qA, int256 qB) internal pure returns (bool) {
        return qA * qB > 0;
    }

    function u8Side(int256 _quantity) internal pure returns (uint8) {
        return _quantity > 0 ? 1 : 2;
    }

    function abs(int256 _quantity) internal pure returns (uint256) {
        return uint256(_quantity >= 0 ? _quantity : -_quantity);
    }

    // TODO write unit test
    /// @dev return the value of Quantity minus amount
    function subAmount(int256 _quantity, uint256 _amount) internal pure returns(int256){
        return _quantity < 0 ? _quantity + int256(_amount) : _quantity - int256(_amount);
    }

    function abs128(int256 _quantity) internal pure returns (uint128) {
        return uint128(abs(_quantity));
    }

    function sumWithUint256(int256 a, uint256 b)
        internal
        pure
        returns (int256)
    {
        return a >= 0 ? a + int256(b) : a - int256(b);
    }

    function minusWithUint256(int256 a, uint256 b)
        internal
        pure
        returns (int256)
    {
        return a >= 0 ? a - int256(b) : a + int256(b);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../../interfaces/IChainLinkPriceFeed.sol";
import "../../../interfaces/IInsuranceFund.sol";
import "../position/TickPosition.sol";
import "../position/LiquidityBitmap.sol";

contract PositionManagerStorage {
    using TickPosition for TickPosition.Data;
    using LiquidityBitmap for mapping(uint128 => uint256);

    uint64 public basisPoint; //0.01
    uint64 public BASE_BASIC_POINT;
    // fee = quoteAssetAmount / tollRatio (means if fee = 0.001% then tollRatio = 100000)
    uint256 tollRatio;

    int256 public fundingRate;

    uint256 public spotPriceTwapInterval;
    uint256 public fundingPeriod;
    uint256 public fundingBufferPeriod;
    uint256 public nextFundingTime;
    bytes32 public priceFeedKey;
    // Max finding word can be 3500
    uint128 public maxFindingWordsIndex;

    address public counterParty;

    uint128 public leverage;

    bool internal _isInitiatedPip;

    //    bool public paused;

    IChainLinkPriceFeed public priceFeed;

    struct SingleSlot {
        uint128 pip;
        //0: not set
        //1: buy
        //2: sell
        uint8 isFullBuy;
        // highest pip order buy
        uint128 highestBuyPip;
        uint128 lowestSellPip;
    }

    struct PipLiquidity {
        uint128 pip;
        uint256 liquidity;
    }

    struct Orderbook {
        uint128[][] asks;
        uint128[][] bids;
    }

    IERC20 quoteAsset;

    struct ReserveSnapshot {
        uint128 pip;
        uint64 timestamp;
        uint64 blockNumber;
    }

    enum TwapCalcOption {
        RESERVE_ASSET,
        INPUT_ASSET
    }

    struct TwapPriceCalcParams {
        TwapCalcOption opt;
        uint256 snapshotIndex;
    }

    struct SwapState {
        uint128 remainingSize;
        // the tick associated with the current price
        uint128 pip;
    }

    struct StepComputations {
        uint128 pipNext;
    }

    enum CurrentLiquiditySide {
        NotSet,
        Buy,
        Sell
    }

    // array of reserveSnapshots
    ReserveSnapshot[] public reserveSnapshots;

    SingleSlot public singleSlot;
    mapping(uint128 => TickPosition.Data) public tickPosition;
    mapping(uint128 => uint256) public tickStore;
    // a packed array of bit, where liquidity is filled or not
    mapping(uint128 => uint256) public liquidityBitmap;

    uint16 public maxMarketMakerSlipage;
    uint32 internal constant PERCENT_BASE = 1000000;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
    uint128 public maxWordRangeForLimitOrder;
    uint128 public maxWordRangeForMarketOrder;
    IInsuranceFund public insuranceFund;
    bool isRFIToken;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library MarketMaker {
    struct MMCancelOrder {
        uint128 pip;
        uint64 orderId;
    }

    struct MMOrder {
        uint128 pip;
        int256 quantity;
    }

    struct MMFill {
        uint256 quantity;
        bool isBuy;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IChainLinkPriceFeed {
    // get latest price
    function getPrice(bytes32 _priceFeedKey) external view returns (uint256);

    // get latest timestamp
    function getLatestTimestamp(bytes32 _priceFeedKey)
        external
        view
        returns (uint256);

    // get previous price with _back rounds
    function getPreviousPrice(bytes32 _priceFeedKey, uint256 _numOfRoundBack)
        external
        view
        returns (uint256);

    // get previous timestamp with _back rounds
    function getPreviousTimestamp(
        bytes32 _priceFeedKey,
        uint256 _numOfRoundBack
    ) external view returns (uint256);

    // get twap price depending on _period
    function getTwapPrice(bytes32 _priceFeedKey, uint256 _interval)
        external
        view
        returns (uint256);

    //    function setLatestData(
    //        bytes32 _priceFeedKey,
    //        uint256 _price,
    //        uint256 _timestamp,
    //        uint256 _roundId
    //    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IInsuranceFund {
    function deposit(
        address positionManager,
        address trader,
        uint256 amount,
        uint256 fee
    ) external;

    function withdraw(
        address positionManager,
        address trader,
        uint256 amount
    ) external;

    function buyBackAndBurn(address token, uint256 amount) external;

    function transferFeeFromTrader(
        address token,
        address trader,
        uint256 amountFee
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./LimitOrder.sol";

//import "hardhat/console.sol";

/*
 * A library storing data and logic at a pip
 */
library TickPosition {
    using SafeMath for uint128;
    using SafeMath for uint64;
    using LimitOrder for LimitOrder.Data;
    struct Data {
        uint128 liquidity;
        uint64 filledIndex;
        uint64 currentIndex;
        // position at a certain tick
        // index => order data
        mapping(uint64 => LimitOrder.Data) orderQueue;
    }

    function insertLimitOrder(
        TickPosition.Data storage _self,
        uint128 _size,
        bool _hasLiquidity,
        bool _isBuy
    ) internal returns (uint64) {
        _self.currentIndex++;
        if (
            !_hasLiquidity &&
            _self.filledIndex != _self.currentIndex &&
            _self.liquidity != 0
        ) {
            // means it has liquidity but is not set currentIndex yet
            // reset the filledIndex to fill all
            _self.filledIndex = _self.currentIndex;
            _self.liquidity = _size;
        } else {
            _self.liquidity = _self.liquidity + _size;
        }
        _self.orderQueue[_self.currentIndex].update(_isBuy, _size);
        return _self.currentIndex;
    }

    function updateOrderWhenClose(
        TickPosition.Data storage _self,
        uint64 _orderId
    ) internal returns (uint256) {
        return _self.orderQueue[_orderId].updateWhenClose();
    }

    function getQueueOrder(TickPosition.Data storage _self, uint64 _orderId)
        internal
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        (isBuy, size, partialFilled) = _self.orderQueue[_orderId].getData();
        if (_self.filledIndex > _orderId && size != 0) {
            isFilled = true;
        } else if (_self.filledIndex < _orderId) {
            isFilled = false;
        } else {
            isFilled = partialFilled >= size && size != 0 ? true : false;
        }
    }

    function partiallyFill(TickPosition.Data storage _self, uint128 _amount)
        internal
    {
        _self.liquidity -= _amount;
        unchecked {
            uint64 index = _self.filledIndex;
            uint128 totalSize = 0;
            if (
                _self.orderQueue[index].size ==
                _self.orderQueue[index].partialFilled
            ) {
                index++;
            }
            if (_self.orderQueue[index].partialFilled != 0) {
                totalSize += (_self.orderQueue[index].size -
                    _self.orderQueue[index].partialFilled);
                index++;
            }
            while (totalSize < _amount) {
                totalSize += _self.orderQueue[index].size;
                index++;
            }
            index--;
            _self.filledIndex = index;
            _self.orderQueue[index].updatePartialFill(
                uint120(totalSize - _amount)
            );
        }
    }

    function cancelLimitOrder(TickPosition.Data storage _self, uint64 _orderId)
        internal
        returns (
            uint256,
            uint256,
            bool
        )
    {
        (bool isBuy, uint256 size, uint256 partialFilled) = _self
            .orderQueue[_orderId]
            .getData();
        if (_self.liquidity >= uint128(size - partialFilled)) {
            _self.liquidity = _self.liquidity - uint128(size - partialFilled);
        }
        _self.orderQueue[_orderId].update(isBuy, partialFilled);
        return (size - partialFilled, partialFilled, isBuy);
    }

    function closeLimitOrder(
        TickPosition.Data storage _self,
        uint64 _orderId,
        uint256 _amountClose
    ) internal returns (uint256 remainAmountClose) {
        (bool isBuy, uint256 size, uint256 partialFilled) = _self
            .orderQueue[_orderId]
            .getData();

        uint256 amount = _amountClose > partialFilled ? 0 : _amountClose;
        if (_amountClose > partialFilled) {
            uint256 amount = size - partialFilled;
            _self.orderQueue[_orderId].update(isBuy, amount);
            remainAmountClose = _amountClose - partialFilled;
        } else {
            uint256 amount = partialFilled - _amountClose;
            _self.orderQueue[_orderId].update(isBuy, amount);
            remainAmountClose = 0;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

//import "hardhat/console.sol";

import "./BitMath.sol";

library LiquidityBitmap {
    uint256 public constant MAX_UINT256 =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    /// @notice Get the position in the mapping
    /// @param _pip The bip index for computing the position
    /// @return mapIndex the index in the map
    /// @return bitPos the position in the bitmap
    function position(uint128 _pip)
        private
        pure
        returns (uint128 mapIndex, uint8 bitPos)
    {
        mapIndex = _pip >> 8;
        bitPos = uint8((_pip) & 0xff);
        // % 256
    }

    /// @notice find the next pip has liquidity
    /// @param _pip The current pip index
    /// @param _lte  Whether to search for the next initialized tick to the left (less than or equal to the starting tick)
    /// @return next The next bit position has liquidity, 0 means no liquidity found
    function findHasLiquidityInOneWords(
        mapping(uint128 => uint256) storage _self,
        uint128 _pip,
        bool _lte
    ) internal view returns (uint128 next) {
        if (_lte) {
            // main is find the next pip has liquidity
            (uint128 wordPos, uint8 bitPos) = position(_pip);
            // all the 1s at or to the right of the current bitPos
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = _self[wordPos] & mask;
            //            bool hasLiquidity = (_self[wordPos] & 1 << bitPos) != 0;

            // if there are no initialized ticks to the right of or at the current tick, return rightmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (_pip - (bitPos - BitMath.mostSignificantBit(masked)))
                : 0;

            //            if (!hasLiquidity && next != 0) {
            //                next = next + 1;
            //            }
        } else {
            // start from the word of the next tick, since the current tick state doesn't matter
            (uint128 wordPos, uint8 bitPos) = position(_pip);
            // all the 1s at or to the left of the bitPos
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = _self[wordPos] & mask;
            // if there are no initialized ticks to the left of the current tick, return leftmost in the word
            bool initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (_pip + (BitMath.leastSignificantBit(masked) - bitPos)) // +1
                : 0;

            //            if (!hasLiquidity && next != 0) {
            //                next = next + 1;
            //            }
        }
    }

    // find nearest pip has liquidity in multiple word
    function findHasLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage _self,
        uint128 _pip,
        uint128 _maxWords,
        bool _lte
    ) internal view returns (uint128 next) {
        uint128 startWord = _pip >> 8;
        if (_lte) {
            if (startWord != 0) {
                uint128 i = startWord;
                for (
                    i;
                    i > (startWord < _maxWords ? 0 : startWord - _maxWords);
                    i--
                ) {
                    if (_self[i] != 0) {
                        next = findHasLiquidityInOneWords(
                            _self,
                            i < startWord ? 256 * i + 255 : _pip,
                            true
                        );
                        if (next != 0) {
                            return next;
                        }
                    }
                }
                if (i == 0 && _self[0] != 0) {
                    next = findHasLiquidityInOneWords(_self, 255, true);
                    if (next != 0) {
                        return next;
                    }
                }
            } else {
                if (_self[startWord] != 0) {
                    next = findHasLiquidityInOneWords(_self, _pip, true);
                    if (next != 0) {
                        return next;
                    }
                }
            }
        } else {
            for (uint128 i = startWord; i < startWord + _maxWords; i++) {
                if (_self[i] != 0) {
                    next = findHasLiquidityInOneWords(
                        _self,
                        i > startWord ? 256 * i : _pip,
                        false
                    );
                    if (next != 0) {
                        return next;
                    }
                }
            }
        }
    }

    // find all pip has liquidity in multiple word
    function findAllLiquidityInMultipleWords(
        mapping(uint128 => uint256) storage _self,
        uint128 _startPip,
        uint256 _dataLength,
        bool _toHigher
    ) internal view returns (uint128[] memory) {
        uint128 startWord = _startPip >> 8;
        uint128 index = 0;
        uint128[] memory allPip = new uint128[](uint128(_dataLength));
        if (!_toHigher) {
            for (uint128 i = startWord; i >= (startWord > 1000 ? startWord - 1000 : 1); i--) {
                if (_self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        _self,
                        i < startWord ? 256 * i + 255 : _startPip,
                        true
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                        if (index >= _dataLength) break;
                    }
                    while (true) {
                        next = findHasLiquidityInOneWords(
                            _self,
                            next - 1,
                            true
                        );
                        if (next != 0 && index <= _dataLength) {
                            allPip[index] = next;
                            index++;
                            if (index >= _dataLength) break;
                        } else {
                            break;
                        }
                    }
                }
                if (index == _dataLength) return allPip;
            }
        } else {
            for (uint128 i = startWord; i <= startWord + 1000; i++) {
                if (_self[i] != 0) {
                    uint128 next;
                    next = findHasLiquidityInOneWords(
                        _self,
                        i > startWord ? 256 * i : _startPip,
                        false
                    );
                    if (next != 0) {
                        allPip[index] = next;
                        index++;
                        if (index >= _dataLength) break;
                    }
                    while (true) {
                        next = findHasLiquidityInOneWords(
                            _self,
                            next + 1,
                            false
                        );
                        if (next != 0 && index <= _dataLength) {
                            allPip[index] = next;
                            index++;
                            if (index >= _dataLength) break;
                        } else {
                            break;
                        }
                    }
                }
            }
            if (index == _dataLength) return allPip;
        }

        return allPip;
    }

    function hasLiquidity(
        mapping(uint128 => uint256) storage _self,
        uint128 _pip
    ) internal view returns (bool) {
        (uint128 mapIndex, uint8 bitPos) = position(_pip);
        return (_self[mapIndex] & (1 << bitPos)) != 0;
    }

    /// @notice Set all bits in a given range
    /// @dev WARNING THIS FUNCTION IS NOT READY FOR PRODUCTION
    /// only use for generating test data purpose
    /// @param _fromPip the pip to set from
    /// @param _toPip the pip to set to
    function setBitsInRange(
        mapping(uint128 => uint256) storage _self,
        uint128 _fromPip,
        uint128 _toPip
    ) internal {
        (uint128 fromMapIndex, uint8 fromBitPos) = position(_fromPip);
        (uint128 toMapIndex, uint8 toBitPos) = position(_toPip);
        if (toMapIndex == fromMapIndex) {
            // in the same storage
            // Set all the bits in given range of a number
            _self[toMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << toBitPos) - 1));
        } else {
            // need to shift the map index
            // TODO fromMapIndex needs set separately
            _self[fromMapIndex] |= (((1 << (fromBitPos - 1)) - 1) ^
                ((1 << 255) - 1));
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                // pass uint256.MAX to avoid gas for computing
                _self[i] = MAX_UINT256;
            }
            // set bits for the last index
            _self[toMapIndex] = MAX_UINT256 >> (256 - toBitPos);
        }
    }

    function unsetBitsRange(
        mapping(uint128 => uint256) storage _self,
        uint128 _fromPip,
        uint128 _toPip
    ) internal {
        if (_fromPip == _toPip) return toggleSingleBit(_self, _fromPip, false);
        _fromPip++;
        _toPip++;
        if (_toPip < _fromPip) {
            uint128 n = _fromPip;
            _fromPip = _toPip;
            _toPip = n;
        }
        (uint128 fromMapIndex, uint8 fromBitPos) = position(_fromPip);
        (uint128 toMapIndex, uint8 toBitPos) = position(_toPip);
        if (toMapIndex == fromMapIndex) {
            //            if(fromBitPos > toBitPos){
            //                uint8 n = fromBitPos;
            //                fromBitPos = toBitPos;
            //                toBitPos = n;
            //            }
            _self[toMapIndex] &= unsetBitsFromLToR(
                MAX_UINT256,
                fromBitPos,
                toBitPos
            );
        } else {
            //TODO check overflow here
            fromBitPos--;
            _self[fromMapIndex] &= ~toggleLastMBits(MAX_UINT256, fromBitPos);
            for (uint128 i = fromMapIndex + 1; i < toMapIndex; i++) {
                _self[i] = 0;
            }
            _self[toMapIndex] &= toggleLastMBits(MAX_UINT256, toBitPos);
        }
    }

    function toggleSingleBit(
        mapping(uint128 => uint256) storage _self,
        uint128 _pip,
        bool _isSet
    ) internal {
        (uint128 mapIndex, uint8 bitPos) = position(_pip);
        if (_isSet) {
            _self[mapIndex] |= 1 << bitPos;
        } else {
            _self[mapIndex] &= ~(1 << bitPos);
        }
    }

    function unsetBitsFromLToR(
        uint256 _n,
        uint8 _l,
        uint8 _r
    ) private returns (uint256) {
        if(_l == 0){
            // NOTE this code support unset at index 0 only
            // avoid overflow in the next line (_l - 1)
            _n |= 1;
            _l++;
        }
        // calculating a number 'num'
        // having 'r' number of bits
        // and bits in the range l
        // to r are the only set bits
        // Important NOTE this code could toggle 0 -> 1
        uint256 num = ((1 << _r) - 1) ^ ((1 << (_l - 1)) - 1);

        // toggle the bits in the
        // range l to r in 'n'
        // and return the number
        return (_n ^ num);
    }

    // Function to toggle the last m bits
    function toggleLastMBits(uint256 _n, uint8 _m) private returns (uint256) {
        // Calculating a number 'num' having
        // 'm' bits and all are set
        uint256 num = (1 << _m) - 1;

        // Toggle the last m bits and
        // return the number
        return (_n ^ num);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

//import "hardhat/console.sol";

library LimitOrder {
    struct Data {
        // Type order LONG or SHORT
        uint8 isBuy;
        uint120 size;
        // NOTICE need to add leverage
        uint120 partialFilled;
    }

    function getData(LimitOrder.Data storage _self)
        internal
        view
        returns (
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        )
    {
        isBuy = _self.isBuy == 1;
        size = uint256(_self.size);
        partialFilled = uint256(_self.partialFilled);
    }

    function update(
        LimitOrder.Data storage _self,
        bool _isBuy,
        uint256 _size
    ) internal {
        _self.isBuy = _isBuy ? 1 : 2;
        _self.size = uint120(_size);
    }

    function updatePartialFill(
        LimitOrder.Data storage _self,
        uint120 _remainSize
    ) internal {
        // remainingSize should be negative
        _self.partialFilled += (_self.size - _self.partialFilled - _remainSize);
    }

    function updateWhenClose(LimitOrder.Data storage _self)
        internal
        returns (uint256)
    {
        _self.size -= _self.partialFilled;
        _self.partialFilled = 0;
        return (uint256(_self.size));
    }

    function getPartialFilled(LimitOrder.Data storage _self)
        internal
        view
        returns (bool isPartial, uint256 remainingSize)
    {
        remainingSize = _self.size - _self.partialFilled;
        isPartial = remainingSize > 0;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title BitMath
/// @dev This libraries provides functionality for computing bit properties of an unsigned integer
library BitMath {
    /// @notice Returns the index of the most significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    /// @param x the value for which to compute the most significant bit, must be greater than 0
    /// @return r the index of the most significant bit// SPDX-License-Identifier: GPL-2.0-or-later
    //pragma solidity >=0.5.0;
    //
    ///// @title BitMath
    ///// @dev This libraries provides functionality for computing bit properties of an unsigned integer
    //libraries BitMath {
    //    /// @notice Returns the index of the most significant bit of the number,
    //    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    //    /// @dev The function satisfies the property:
    //    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    //    /// @param x the value for which to compute the most significant bit, must be greater than 0
    //    /// @return r the index of the most significant bit
    //    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
    //        require(x > 0);
    //
    //        if (x >= 0x100000000000000000000000000000000) {
    //            x >>= 128;
    //            r += 128;
    //        }
    //        if (x >= 0x10000000000000000) {
    //            x >>= 64;
    //            r += 64;
    //        }
    //        if (x >= 0x100000000) {
    //            x >>= 32;
    //            r += 32;
    //        }
    //        if (x >= 0x10000) {
    //            x >>= 16;
    //            r += 16;
    //        }
    //        if (x >= 0x100) {
    //            x >>= 8;
    //            r += 8;
    //        }
    //        if (x >= 0x10) {
    //            x >>= 4;
    //            r += 4;
    //        }
    //        if (x >= 0x4) {
    //            x >>= 2;
    //            r += 2;
    //        }
    //        if (x >= 0x2) r += 1;
    //    }
    //
    //    /// @notice Returns the index of the least significant bit of the number,
    //    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    //    /// @dev The function satisfies the property:
    //    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    //    /// @param x the value for which to compute the least significant bit, must be greater than 0
    //    /// @return r the index of the least significant bit
    //    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
    //        require(x > 0);
    //
    //        r = 255;
    //        if (x & type(uint128).max > 0) {
    //            r -= 128;
    //        } else {
    //            x >>= 128;
    //        }
    //        if (x & type(uint64).max > 0) {
    //            r -= 64;
    //        } else {
    //            x >>= 64;
    //        }
    //        if (x & type(uint32).max > 0) {
    //            r -= 32;
    //        } else {
    //            x >>= 32;
    //        }
    //        if (x & type(uint16).max > 0) {
    //            r -= 16;
    //        } else {
    //            x >>= 16;
    //        }
    //        if (x & type(uint8).max > 0) {
    //            r -= 8;
    //        } else {
    //            x >>= 8;
    //        }
    //        if (x & 0xf > 0) {
    //            r -= 4;
    //        } else {
    //            x >>= 4;
    //        }
    //        if (x & 0x3 > 0) {
    //            r -= 2;
    //        } else {
    //            x >>= 2;
    //        }
    //        if (x & 0x1 > 0) r -= 1;
    //    }
    //}
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    /// @notice Returns the index of the least significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    /// @param x the value for which to compute the least significant bit, must be greater than 0
    /// @return r the index of the least significant bit
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint8).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import "../position/PositionLimitOrder.sol";
import "../../../interfaces/IInsuranceFund.sol";
import "../../../interfaces/IPositionHouseConfigurationProxy.sol";
import "../../../interfaces/IPositionNotionalConfigProxy.sol";
import "../../../interfaces/IPositionStrategyOrder.sol";

abstract contract PositionHouseStorage {
    using PositionLimitOrder for mapping(address => mapping(address => PositionLimitOrder.Data[]));
    using Quantity for int256;
    using Quantity for int128;

    using Position for Position.Data;
    using Position for Position.LiquidatedData;

    enum PnlCalcOption {
        TWAP,
        SPOT_PRICE,
        ORACLE
    }

    struct PositionResp {
        Position.Data position;
        int256 marginToVault;
        int256 realizedPnl;
        int256 unrealizedPnl;
        int256 exchangedPositionSize;
        uint256 exchangedQuoteAssetAmount;
        uint256 fundingPayment;
        uint256 entryPrice;
        uint256 fee;
    }

    struct LimitOrderPending {
        bool isBuy;
        uint256 quantity;
        uint256 partialFilled;
        uint128 pip;
        // can change leverage to uint16 to save gas
        uint16 leverage;
        uint8 isReduce;
        uint64 blockNumber;
        uint256 orderIdx;
        uint256 orderId;
    }

    struct OpenLimitResp {
        uint64 orderId;
        uint256 sizeOut;
    }

    //    struct PositionManagerData {
    //        uint24 blockNumber;
    //        int256[] cumulativePremiumFraction;
    //        // Position data of each trader
    //        mapping(address => Position.Data) positionMap;
    //        mapping(address => PositionLimitOrder.Data[]) limitOrders;
    //        mapping(address => PositionLimitOrder.Data[]) reduceLimitOrders;
    //        // Amount that trader can claim from exchange
    //        mapping(address => int256) canClaimAmount;
    //        mapping(address => int256) manualMargin;
    //    }
    //    // TODO change separate mapping to positionManagerMap
    //    mapping(address => PositionManagerData) public positionManagerMap;

    // Can join positionMap and cumulativePremiumFractionsMap into a map of struct with key is PositionManager's address
    // Mapping from position manager address of each pair to position data of each trader
    mapping(address => mapping(address => Position.Data)) public positionMap;
    //    mapping(address => int256[]) public cumulativePremiumFractionsMap;

    mapping(address => mapping(address => Position.LiquidatedData))
        public debtPosition;

    // update added margin type from int256 to uint256
    mapping(address => mapping(address => int256)) internal manualMargin;
    //can update with index => no need delete array when close all

    IInsuranceFund public insuranceFund;
    IPositionHouseConfigurationProxy public positionHouseConfigurationProxy;
    IPositionNotionalConfigProxy public positionNotionalConfigProxy;

    mapping(address => bytes32) internal configNotionalKey;
    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IPositionHouseConfigurationProxy {
    function maintenanceMarginRatio() external view returns (uint256);

    function partialLiquidationRatio() external view returns (uint256);

    function liquidationFeeRatio() external view returns (uint256);

    function liquidationPenaltyRatio() external view returns (uint256);

    function getLiquidationRatio() external view returns (uint256, uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;


interface IPositionNotionalConfigProxy {
    function getMaxNotional(bytes32 key, uint16 leverage) external returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;


interface IPositionStrategyOrder {
    function unsetTPAndSL(address _pmAddress) external;

    function unsetTPOrSL(address _pmAddress, bool _isHigherPrice) external;

    function unsetTPAndSLWhenClosePosition(address _pmAddress, address _trader) external;

    function getTPSLDetail(address _pmAddress, address _trader) external view returns (uint120 lowerThanPrice, uint120 higherThanPrice);

    function hasTPOrSL(address _pmAddress, address _trader) external view returns (bool);
}