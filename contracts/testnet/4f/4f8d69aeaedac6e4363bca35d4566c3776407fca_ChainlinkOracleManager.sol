// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

import "../../interfaces/external/chainlink/IEACAggregatorProxy.sol";
import "../../interfaces/IPriceRegistry.sol";
import "./ProviderOracleManager.sol";
import "../../libraries/QuantMath.sol";
import "../../interfaces/IChainlinkOracleManager.sol";

/// @title For managing chainlink oracles for assets and submitting chainlink prices to the registry
/// @author Rolla
/// @notice Once an oracle is added for an asset it can't be changed!
contract ChainlinkOracleManager is
    ProviderOracleManager,
    IChainlinkOracleManager
{
    using QuantMath for uint256;
    using QuantMath for QuantMath.FixedPointInt;

    struct BinarySearchResult {
        uint80 firstRound;
        uint80 lastRound;
        uint80 firstRoundProxy;
        uint80 lastRoundProxy;
    }

    uint256 public immutable override fallbackPeriodSeconds;
    uint8 public immutable override strikeAssetDecimals;

    /// @param _fallbackPeriodSeconds amount of seconds before fallback price submitter can submit
    constructor(
        address _priceRegistry,
        uint8 _strikeAssetDecimals,
        uint88 _fallbackPeriodSeconds
    ) ProviderOracleManager(_priceRegistry) {
        fallbackPeriodSeconds = _fallbackPeriodSeconds;
        strikeAssetDecimals = _strikeAssetDecimals;
    }

    /// @inheritdoc IChainlinkOracleManager
    function setExpiryPriceInRegistryByRound(
        address _asset,
        uint88 _expiryTimestamp,
        uint256 _roundIdAfterExpiry
    ) external override {
        _setExpiryPriceInRegistryByRound(
            _asset,
            _expiryTimestamp,
            _roundIdAfterExpiry
        );
    }

    /// @inheritdoc IProviderOracleManager
    function setExpiryPriceInRegistry(
        address _asset,
        uint88 _expiryTimestamp,
        bytes memory
    ) external override(ProviderOracleManager, IProviderOracleManager) {
        //search and get round
        uint80 roundAfterExpiry = searchRoundToSubmit(_asset, _expiryTimestamp);

        //submit price to registry
        _setExpiryPriceInRegistryByRound(
            _asset,
            _expiryTimestamp,
            roundAfterExpiry
        );
    }

    /// @inheritdoc IOracleFallbackMechanism
    function setExpiryPriceInRegistryFallback(
        address _asset,
        uint88 _expiryTimestamp,
        uint256 _price
    ) external override onlyOwner {
        require(
            block.timestamp >= _expiryTimestamp + fallbackPeriodSeconds,
            "ChainlinkOracleManager: The fallback price period has not passed since the timestamp"
        );

        emit PriceRegistrySubmission(
            _asset,
            _expiryTimestamp,
            _price,
            0,
            msg.sender,
            true
        );

        IPriceRegistry(priceRegistry).setSettlementPrice(
            _asset,
            _expiryTimestamp,
            IEACAggregatorProxy(getAssetOracle(_asset)).decimals(),
            _price
        );
    }

    /// @inheritdoc IProviderOracleManager
    function getCurrentPrice(address _asset)
        external
        view
        override(ProviderOracleManager, IProviderOracleManager)
        returns (uint256)
    {
        address assetOracle = getAssetOracle(_asset);
        IEACAggregatorProxy aggregator = IEACAggregatorProxy(assetOracle);
        (, int256 answer, , , ) = aggregator.latestRoundData();
        require(
            answer > 0,
            "ChainlinkOracleManager: No pricing data available"
        );

        return
            uint256(answer).fromScaledUint(aggregator.decimals()).toScaledUint(
                strikeAssetDecimals,
                true
            );
    }

    /// @inheritdoc IProviderOracleManager
    function isValidOption(
        address _underlyingAsset,
        uint88,
        uint256
    )
        external
        view
        virtual
        override(ProviderOracleManager, IProviderOracleManager)
        returns (bool)
    {
        return assetOracles[_underlyingAsset] != address(0);
    }

    /// @inheritdoc IChainlinkOracleManager
    function searchRoundToSubmit(address _asset, uint88 _expiryTimestamp)
        public
        view
        override
        returns (uint80)
    {
        address assetOracle = getAssetOracle(_asset);

        IEACAggregatorProxy aggregator = IEACAggregatorProxy(assetOracle);

        require(
            aggregator.latestTimestamp() > _expiryTimestamp,
            "ChainlinkOracleManager: The latest round timestamp is not after the expiry timestamp"
        );

        uint80 latestRound = uint80(aggregator.latestRound());

        uint16 phaseOffset = 64;
        uint16 phaseId = uint16(latestRound >> phaseOffset);

        uint80 lowestPossibleRound = uint80((phaseId << phaseOffset) | 1);
        uint80 highestPossibleRound = latestRound;
        uint80 firstId = lowestPossibleRound;
        uint80 lastId = highestPossibleRound;

        require(
            lastId > firstId,
            "ChainlinkOracleManager: Not enough rounds to find round after"
        );

        //binary search until we find two values our desired timestamp lies between
        while (lastId - firstId != 1) {
            BinarySearchResult memory result = _binarySearchStep(
                aggregator,
                _expiryTimestamp,
                lowestPossibleRound,
                highestPossibleRound
            );

            lowestPossibleRound = result.firstRound;
            highestPossibleRound = result.lastRound;
            firstId = result.firstRoundProxy;
            lastId = result.lastRoundProxy;
        }

        return highestPossibleRound; //return round above
    }

    /// @notice Get the expiry price from chainlink asset oracle and store it in the price registry
    /// @param _asset asset to set price of
    /// @param _expiryTimestamp timestamp of price
    /// @param _roundIdAfterExpiry the chainlink round id immediately after the option expired
    function _setExpiryPriceInRegistryByRound(
        address _asset,
        uint88 _expiryTimestamp,
        uint256 _roundIdAfterExpiry
    ) internal {
        address assetOracle = getAssetOracle(_asset);

        IEACAggregatorProxy aggregator = IEACAggregatorProxy(assetOracle);

        require(
            aggregator.getTimestamp(_roundIdAfterExpiry) > _expiryTimestamp,
            "ChainlinkOracleManager: The round posted is not after the expiry timestamp"
        );

        uint16 phaseOffset = 64;
        uint16 phaseId = uint16(_roundIdAfterExpiry >> phaseOffset);

        uint64 expiryRound = uint64(_roundIdAfterExpiry) - 1;
        uint80 expiryRoundId = uint80(
            (uint256(phaseId) << phaseOffset) | expiryRound
        );

        require(
            aggregator.getTimestamp(uint256(expiryRoundId)) <= _expiryTimestamp,
            "ChainlinkOracleManager: Expiry round prior to the one posted is after the expiry timestamp"
        );

        (uint256 price, uint256 roundId) = _getExpiryPrice(
            aggregator,
            _expiryTimestamp,
            _roundIdAfterExpiry,
            expiryRoundId
        );

        emit PriceRegistrySubmission(
            _asset,
            _expiryTimestamp,
            price,
            roundId,
            msg.sender,
            false
        );

        IPriceRegistry(priceRegistry).setSettlementPrice(
            _asset,
            _expiryTimestamp,
            aggregator.decimals(),
            price
        );
    }

    function _getExpiryPrice(
        IEACAggregatorProxy aggregator,
        uint88,
        uint256,
        uint256 _expiryRoundId
    ) internal view virtual returns (uint256, uint256) {
        (, int256 answer, , , ) = aggregator.getRoundData(
            uint80(_expiryRoundId)
        );
        return (uint256(answer), _expiryRoundId);
    }

    /// @notice Performs a binary search step between the first and last round in the aggregator proxy
    /// @param _expiryTimestamp expiry timestamp to find the price at
    /// @param _firstRoundProxy the lowest possible round for the timestamp
    /// @param _lastRoundProxy the highest possible round for the timestamp
    /// @return a binary search result object representing lowest and highest possible rounds of the timestamp
    function _binarySearchStep(
        IEACAggregatorProxy aggregator,
        uint88 _expiryTimestamp,
        uint80 _firstRoundProxy,
        uint80 _lastRoundProxy
    ) internal view returns (BinarySearchResult memory) {
        uint16 phaseOffset = 64;
        uint16 phaseId = uint16(_lastRoundProxy >> phaseOffset);

        uint64 lastRoundId = uint64(_lastRoundProxy);
        uint64 firstRoundId = uint64(_firstRoundProxy);

        uint80 roundToCheck = uint80(
            (uint256(firstRoundId) + uint256(lastRoundId)) / 2
        );
        uint80 roundToCheckProxy = uint80(
            (uint256(phaseId) << phaseOffset) | roundToCheck
        );

        uint256 roundToCheckTimestamp = aggregator.getTimestamp(
            uint256(roundToCheckProxy)
        );

        if (roundToCheckTimestamp <= _expiryTimestamp) {
            return
                BinarySearchResult(
                    roundToCheckProxy,
                    _lastRoundProxy,
                    roundToCheck,
                    lastRoundId
                );
        }

        return
            BinarySearchResult(
                _firstRoundProxy,
                roundToCheckProxy,
                firstRoundId,
                roundToCheck
            );
    }
}

// SPDX-License-Identifier: BUSL-1.1
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol. SEE BELOW FOR SOURCE. !!
pragma solidity ^0.8.0;

interface IEACAggregatorProxy {
    event AnswerUpdated(
        int256 indexed current,
        uint256 indexed roundId,
        uint256 updatedAt
    );
    event NewRound(
        uint256 indexed roundId,
        address indexed startedBy,
        uint256 startedAt
    );
    event OwnershipTransferRequested(address indexed from, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);

    function acceptOwnership() external;

    function confirmAggregator(address _aggregator) external;

    function proposeAggregator(address _aggregator) external;

    function setController(address _accessController) external;

    function transferOwnership(address _to) external;

    function accessController() external view returns (address);

    function aggregator() external view returns (address);

    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function getAnswer(uint256 _roundId) external view returns (int256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function getTimestamp(uint256 _roundId) external view returns (uint256);

    function latestAnswer() external view returns (int256);

    function latestRound() external view returns (uint256);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestTimestamp() external view returns (uint256);

    function owner() external view returns (address);

    function phaseAggregators(uint16) external view returns (address);

    function phaseId() external view returns (uint16);

    function proposedAggregator() external view returns (address);

    function proposedGetRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function proposedLatestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function version() external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @dev Current pricing status of option. Only SETTLED options can be exercised
enum PriceStatus {
    ACTIVE,
    AWAITING_SETTLEMENT_PRICE,
    SETTLED
}

struct PriceWithDecimals {
    uint256 price;
    uint8 decimals;
}

/// @title For centrally managing a log of settlement prices, for each option.
/// @author Rolla
interface IPriceRegistry {
    event PriceStored(
        address indexed _oracle,
        address indexed _asset,
        uint88 indexed _expiryTime,
        uint8 _settlementPriceDecimals,
        uint256 _settlementPrice
    );

    /// @notice Set the price at settlement for a particular asset, expiry
    /// @param _asset asset to set price for
    /// @param _expiryTime timestamp of price to set
    /// @param _settlementPriceDecimals number of decimals in settlement price
    /// @param _settlementPrice price at settlement
    function setSettlementPrice(
        address _asset,
        uint88 _expiryTime,
        uint8 _settlementPriceDecimals,
        uint256 _settlementPrice
    ) external;

    /// @notice Fetch the settlement price with decimals from an oracle for an asset at a particular timestamp.
    /// @param _oracle oracle which price should come from
    /// @param _expiryTime timestamp we want the price for
    /// @param _asset asset to fetch price for
    /// @return the price (with decimals) which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPriceWithDecimals(
        address _oracle,
        uint88 _expiryTime,
        address _asset
    ) external view returns (PriceWithDecimals memory);

    /// @notice Fetch the settlement price from an oracle for an asset at a particular timestamp.
    /// @notice Rounds down if there's extra precision from the oracle
    /// @param _oracle oracle which price should come from
    /// @param _expiryTime timestamp we want the price for
    /// @param _asset asset to fetch price for
    /// @return the price which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPrice(
        address _oracle,
        uint88 _expiryTime,
        address _asset
    ) external view returns (uint256);

    /// @notice Get the price status of the option.
    /// @return the price status of the option. option is either active, awaiting settlement price or settled
    function getOptionPriceStatus(
        address _oracle,
        uint88 _expiryTime,
        address _asset
    ) external view returns (PriceStatus);

    /// @notice Check if the settlement price for an asset exists from an oracle at a particular timestamp
    /// @param _oracle oracle from which price comes from
    /// @param _expiryTime timestamp of price
    /// @param _asset asset to check price for
    /// @return whether or not a price has been submitted for the asset at the timestamp by that oracle
    function hasSettlementPrice(
        address _oracle,
        uint88 _expiryTime,
        address _asset
    ) external view returns (bool);

    function oracleRegistry() external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../interfaces/IProviderOracleManager.sol";

/// @title Oracle manager for holding asset addresses and their oracle addresses for a single provider
/// @author Rolla
/// @notice Once an oracle is added for an asset it can't be changed!
abstract contract ProviderOracleManager is Ownable, IProviderOracleManager {
    /// @inheritdoc IProviderOracleManager
    mapping(address => address) public override assetOracles;

    /// @inheritdoc IProviderOracleManager
    address[] public override assets;

    address public immutable priceRegistry;

    constructor(address _priceRegistry) {
        require(
            _priceRegistry != address(0),
            "ProviderOracleManager: invalid price registry address"
        );

        priceRegistry = _priceRegistry;
    }

    /// @inheritdoc IProviderOracleManager
    function addAssetOracle(address _asset, address _oracle)
        external
        override
        onlyOwner
    {
        require(
            _oracle != address(0),
            "ProviderOracleManager: Oracle is zero address"
        );
        require(
            assetOracles[_asset] == address(0),
            "ProviderOracleManager: Oracle already set for asset"
        );
        assets.push(_asset);
        assetOracles[_asset] = _oracle;

        emit OracleAdded(_asset, _oracle);
    }

    /// @inheritdoc IProviderOracleManager
    function setExpiryPriceInRegistry(
        address _asset,
        uint88 _expiryTimestamp,
        bytes memory _calldata
    ) external virtual override;

    /// @inheritdoc IProviderOracleManager
    function getAssetsLength() external view override returns (uint256) {
        return assets.length;
    }

    /// @inheritdoc IProviderOracleManager
    function getCurrentPrice(address _asset)
        external
        view
        virtual
        override
        returns (uint256);

    function isValidOption(
        address _underlyingAsset,
        uint88 _expiryTime,
        uint256 _strikePrice
    ) external view virtual override returns (bool);

    /// @inheritdoc IProviderOracleManager
    function getAssetOracle(address _asset)
        public
        view
        override
        returns (address)
    {
        address assetOracle = assetOracles[_asset];
        require(
            assetOracle != address(0),
            "ProviderOracleManager: Oracle doesn't exist for that asset"
        );
        return assetOracle;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

import "./SignedConverter.sol";

/**
 * @title QuantMath
 * @author Rolla
 * @notice FixedPoint library
 */
library QuantMath {
    using SignedConverter for int256;
    using SignedConverter for uint256;

    struct FixedPointInt {
        int256 value;
    }

    int256 private constant _SCALING_FACTOR = 1e27;
    uint256 private constant _BASE_DECIMALS = 27;

    /**
     * @notice constructs an `FixedPointInt` from an unscaled int, e.g., `b=5` gets stored internally as `5**27`.
     * @param a int to convert into a FixedPoint.
     * @return the converted FixedPoint.
     */
    function fromUnscaledInt(int256 a)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return FixedPointInt(a * _SCALING_FACTOR);
    }

    /**
     * @notice constructs an FixedPointInt from an scaled uint with {_decimals} decimals
     * Examples:
     * (1)  USDC    decimals = 6
     *      Input:  5 * 1e6 USDC  =>    Output: 5 * 1e27 (FixedPoint 8.0 USDC)
     * (2)  cUSDC   decimals = 8
     *      Input:  5 * 1e6 cUSDC =>    Output: 5 * 1e25 (FixedPoint 0.08 cUSDC)
     * @param _a uint256 to convert into a FixedPoint.
     * @param _decimals  original decimals _a has
     * @return the converted FixedPoint, with 27 decimals.
     */
    function fromScaledUint(uint256 _a, uint256 _decimals)
        internal
        pure
        returns (FixedPointInt memory)
    {
        FixedPointInt memory fixedPoint;

        if (_decimals == _BASE_DECIMALS) {
            fixedPoint = FixedPointInt(_a.uintToInt());
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            fixedPoint = FixedPointInt((_a / 10**exp).uintToInt());
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            fixedPoint = FixedPointInt((_a * 10**exp).uintToInt());
        }

        return fixedPoint;
    }

    /**
     * @notice convert a FixedPointInt number to an uint256 with a specific number of decimals
     * @param _a FixedPointInt to convert
     * @param _decimals number of decimals that the uint256 should be scaled to
     * @param _roundDown True to round down the result, False to round up
     * @return the converted uint256
     */
    function toScaledUint(
        FixedPointInt memory _a,
        uint256 _decimals,
        bool _roundDown
    ) internal pure returns (uint256) {
        uint256 scaledUint;

        if (_decimals == _BASE_DECIMALS) {
            scaledUint = _a.value.intToUint();
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            scaledUint = (_a.value).intToUint() * 10**exp;
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            uint256 tailing;
            if (!_roundDown) {
                uint256 remainder = (_a.value).intToUint() % 10**exp;
                if (remainder > 0) tailing = 1;
            }
            scaledUint = (_a.value).intToUint() / 10**exp + tailing;
        }

        return scaledUint;
    }

    /**
     * @notice add two signed integers, a + b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return sum of the two signed integers
     */
    function add(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return FixedPointInt(a.value + b.value);
    }

    /**
     * @notice subtract two signed integers, a-b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return difference of two signed integers
     */
    function sub(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return FixedPointInt(a.value - b.value);
    }

    /**
     * @notice multiply two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return mul of two signed integers
     */
    function mul(
        FixedPointInt memory a,
        FixedPointInt memory b,
        bool roundDown
    ) internal pure returns (FixedPointInt memory) {
        int256 remainder = (a.value * b.value) % _SCALING_FACTOR;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt((a.value * b.value) / _SCALING_FACTOR + tailing);
    }

    /**
     * @notice divide two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return div of two signed integers
     */
    function div(
        FixedPointInt memory a,
        FixedPointInt memory b,
        bool roundDown
    ) internal pure returns (FixedPointInt memory) {
        int256 remainder = (a.value * _SCALING_FACTOR) % b.value;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt((a.value * _SCALING_FACTOR) / b.value + tailing);
    }

    /**
     * @notice minimum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return min of two signed integers
     */
    function min(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return a.value < b.value ? a : b;
    }

    /**
     * @notice maximum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return max of two signed integers
     */
    function max(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return a.value > b.value ? a : b;
    }

    /**
     * @notice is a is equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if equal, False if not
     */
    function isEqual(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value == b.value;
    }

    /**
     * @notice is a greater than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a > b, False if not
     */
    function isGreaterThan(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value > b.value;
    }

    /**
     * @notice is a greater than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a >= b, False if not
     */
    function isGreaterThanOrEqual(
        FixedPointInt memory a,
        FixedPointInt memory b
    ) internal pure returns (bool) {
        return a.value >= b.value;
    }

    /**
     * @notice is a is less than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a < b, False if not
     */
    function isLessThan(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value < b.value;
    }

    /**
     * @notice is a less than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a <= b, False if not
     */
    function isLessThanOrEqual(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value <= b.value;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IProviderOracleManager.sol";
import "./IOracleFallbackMechanism.sol";

interface IChainlinkOracleManager is
    IProviderOracleManager,
    IOracleFallbackMechanism
{
    event PriceRegistrySubmission(
        address asset,
        uint88 expiryTimestamp,
        uint256 price,
        uint256 expiryRoundId,
        address priceSubmitter,
        bool isFallback
    );

    /// @notice Set the price of an asset at a timestamp using a chainlink round id
    /// @param _asset address of asset to set price for
    /// @param _expiryTimestamp expiry timestamp to set the price at
    /// @param _roundIdAfterExpiry the chainlink round id immediately after the expiry timestamp
    function setExpiryPriceInRegistryByRound(
        address _asset,
        uint88 _expiryTimestamp,
        uint256 _roundIdAfterExpiry
    ) external;

    function fallbackPeriodSeconds() external view returns (uint256);

    /// @notice Searches for the round in the asset oracle immediately after the expiry timestamp
    /// @param _asset address of asset to search price for
    /// @param _expiryTimestamp expiry timestamp to find the price at or before
    /// @return the round id immediately after the timestamp submitted
    function searchRoundToSubmit(address _asset, uint88 _expiryTimestamp)
        external
        view
        returns (uint80);

    /// @notice The amount of decimals the strike asset has
    function strikeAssetDecimals() external view returns (uint8);
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title Oracle manager for holding asset addresses and their oracle addresses for a single provider
/// @author Rolla
/// @notice Once an oracle is added for an asset it can't be changed!
interface IProviderOracleManager {
    event OracleAdded(address asset, address oracle);

    /// @notice Add an asset to the oracle manager with its corresponding oracle address
    /// @dev Once this is set for an asset, it can't be changed or removed
    /// @param _asset the address of the asset token we are adding the oracle for
    /// @param _oracle the address of the oracle
    function addAssetOracle(address _asset, address _oracle) external;

    /// @notice Get the expiry price from oracle and store it in the price registry so we have a copy
    /// @param _asset asset to set price of
    /// @param _expiryTimestamp timestamp of price
    /// @param _calldata additional parameter that the method may need to execute
    function setExpiryPriceInRegistry(
        address _asset,
        uint88 _expiryTimestamp,
        bytes memory _calldata
    ) external;

    /// @notice asset address => oracle address
    function assetOracles(address) external view returns (address);

    /// @notice exhaustive list of asset addresses in map
    function assets(uint256) external view returns (address);

    /// @notice Get the oracle address associated with an asset
    /// @param _asset asset to get price of
    function getAssetOracle(address _asset) external view returns (address);

    /// @notice Get the total number of assets managed by the oracle manager
    /// @return total number of assets managed by the oracle manager
    function getAssetsLength() external view returns (uint256);

    /// @notice Function that should be overridden which should return the current price of an asset from the provider
    /// @param _asset the address of the asset token we want the price for
    /// @return the current price of the asset
    function getCurrentPrice(address _asset) external view returns (uint256);

    /// @notice Checks if the option is valid for the oracle manager with the given parameters
    /// @param _underlyingAsset the address of the underlying asset
    /// @param _expiryTime the expiry timestamp of the option
    /// @param _strikePrice the strike price of the option
    function isValidOption(
        address _underlyingAsset,
        uint88 _expiryTime,
        uint256 _strikePrice
    ) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

/**
 * @title SignedConverter
 * @author Rolla
 * @notice A library to convert an unsigned integer to signed integer or signed integer to unsigned integer.
 */
library SignedConverter {
    /**
     * @notice convert an unsigned integer to a signed integer
     * @param a uint to convert into a signed integer
     * @return converted signed integer
     */
    function uintToInt(uint256 a) internal pure returns (int256) {
        require(a < 2**255, "QuantMath: out of int range");

        return int256(a);
    }

    /**
     * @notice convert a signed integer to an unsigned integer
     * @param a int to convert into an unsigned integer
     * @return converted unsigned integer
     */
    function intToUint(int256 a) internal pure returns (uint256) {
        require(a >= 0, "QuantMath: negative int");

        return uint256(a);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IOracleFallbackMechanism {
    /// @notice Fallback mechanism to submit price to the registry (should enforce a locking period)
    /// @param _asset asset to set price of
    /// @param _expiryTimestamp timestamp of price
    /// @param _price price to submit
    function setExpiryPriceInRegistryFallback(
        address _asset,
        uint88 _expiryTimestamp,
        uint256 _price
    ) external;
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