// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "../interfaces/IPriceRegistry.sol";
import "../interfaces/IOracleRegistry.sol";
import "../libraries/QuantMath.sol";

/// @title For centrally managing a log of settlement prices, for each option.
/// @author Rolla
contract PriceRegistry is IPriceRegistry {
    using QuantMath for uint256;
    using QuantMath for QuantMath.FixedPointInt;

    uint8 private immutable _strikeAssetDecimals;

    /// @inheritdoc IPriceRegistry
    address public immutable oracleRegistry;

    /// @dev oracle => asset => expiry => price
    mapping(address => mapping(address => mapping(uint88 => PriceWithDecimals))) private _settlementPrices;

    /// @param strikeAssetDecimals_ address of quant central configuration
    constructor(uint8 strikeAssetDecimals_, address _oracleRegistry) {
        require(_oracleRegistry != address(0), "PriceRegistry: invalid oracle registry address");

        _strikeAssetDecimals = strikeAssetDecimals_;
        oracleRegistry = _oracleRegistry;
    }

    /// @inheritdoc IPriceRegistry
    function setSettlementPrice(
        address _asset,
        uint88 _expiryTime,
        uint8 _settlementPriceDecimals,
        uint256 _settlementPrice
    )
        external
        override
    {
        address oracle = msg.sender;

        require(
            IOracleRegistry(oracleRegistry).isOracleRegistered(oracle) && IOracleRegistry(oracleRegistry).isOracleActive(oracle),
            "PriceRegistry: Price submitter is not an active oracle"
        );

        uint256 currentSettlementPrice = _settlementPrices[oracle][_asset][_expiryTime].price;

        require(currentSettlementPrice == 0, "PriceRegistry: Settlement price has already been set");

        require(_expiryTime <= block.timestamp, "PriceRegistry: Can't set a price for a time in the future");

        _settlementPrices[oracle][_asset][_expiryTime] = PriceWithDecimals(_settlementPrice, _settlementPriceDecimals);

        emit PriceStored(oracle, _asset, _expiryTime, _settlementPriceDecimals, _settlementPrice);
    }

    /// @inheritdoc IPriceRegistry
    function getSettlementPriceWithDecimals(address _oracle, uint88 _expiryTime, address _asset)
        external
        view
        override
        returns (PriceWithDecimals memory settlementPrice)
    {
        settlementPrice = _settlementPrices[_oracle][_asset][_expiryTime];
        require(settlementPrice.price != 0, "PriceRegistry: No settlement price has been set");
    }

    /// @inheritdoc IPriceRegistry
    function getSettlementPrice(address _oracle, uint88 _expiryTime, address _asset)
        external
        view
        override
        returns (uint256)
    {
        PriceWithDecimals memory settlementPrice = _settlementPrices[_oracle][_asset][_expiryTime];
        require(settlementPrice.price != 0, "PriceRegistry: No settlement price has been set");

        //convert price to the correct number of decimals
        return settlementPrice.price.fromScaledUint(settlementPrice.decimals).toScaledUint(_strikeAssetDecimals, true);
    }

    function getOptionPriceStatus(address _oracle, uint88 _expiryTime, address _asset)
        external
        view
        override
        returns (PriceStatus)
    {
        if (block.timestamp > _expiryTime) {
            if (hasSettlementPrice(_oracle, _expiryTime, _asset)) {
                return PriceStatus.SETTLED;
            }
            return PriceStatus.AWAITING_SETTLEMENT_PRICE;
        } else {
            return PriceStatus.ACTIVE;
        }
    }

    /// @inheritdoc IPriceRegistry
    function hasSettlementPrice(address _oracle, uint88 _expiryTime, address _asset)
        public
        view
        override
        returns (bool)
    {
        return _settlementPrices[_oracle][_asset][_expiryTime].price != 0;
    }
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
    )
        external;

    /// @notice Fetch the settlement price with decimals from an oracle for an asset at a particular timestamp.
    /// @param _oracle oracle which price should come from
    /// @param _expiryTime timestamp we want the price for
    /// @param _asset asset to fetch price for
    /// @return the price (with decimals) which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPriceWithDecimals(address _oracle, uint88 _expiryTime, address _asset)
        external
        view
        returns (PriceWithDecimals memory);

    /// @notice Fetch the settlement price from an oracle for an asset at a particular timestamp.
    /// @notice Rounds down if there's extra precision from the oracle
    /// @param _oracle oracle which price should come from
    /// @param _expiryTime timestamp we want the price for
    /// @param _asset asset to fetch price for
    /// @return the price which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPrice(address _oracle, uint88 _expiryTime, address _asset) external view returns (uint256);

    /// @notice Get the price status of the option.
    /// @return the price status of the option. option is either active, awaiting settlement price or settled
    function getOptionPriceStatus(address _oracle, uint88 _expiryTime, address _asset)
        external
        view
        returns (PriceStatus);

    /// @notice Check if the settlement price for an asset exists from an oracle at a particular timestamp
    /// @param _oracle oracle from which price comes from
    /// @param _expiryTime timestamp of price
    /// @param _asset asset to check price for
    /// @return whether or not a price has been submitted for the asset at the timestamp by that oracle
    function hasSettlementPrice(address _oracle, uint88 _expiryTime, address _asset) external view returns (bool);

    // @notice The address of the OracleRegistry contract
    function oracleRegistry() external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title For centrally managing a list of oracle providers
/// @author Rolla
/// @notice oracle provider registry for holding a list of oracle providers and their id
interface IOracleRegistry {
    event AddedOracle(address oracle, uint248 oracleId);

    event ActivatedOracle(address oracle);

    event DeactivatedOracle(address oracle);

    /// @notice Add an oracle to the oracle registry which will generate an id. By default oracles are deactivated
    /// @param _oracle the address of the oracle
    /// @return the id of the oracle
    function addOracle(address _oracle) external returns (uint248);

    /// @notice Deactivate an oracle so no new options can be created with this oracle address.
    /// @param _oracle the oracle to deactivate
    function deactivateOracle(address _oracle) external returns (bool);

    /// @notice Activate an oracle so options can be created with this oracle address.
    /// @param _oracle the oracle to activate
    function activateOracle(address _oracle) external returns (bool);

    /// @notice oracle address => OracleInfo
    function oracleInfo(address) external view returns (bool, uint248);

    /// @notice exhaustive list of oracles in map
    function oracles(uint256) external view returns (address);

    /// @notice Check if an oracle is registered in the registry
    /// @param _oracle the oracle to check
    function isOracleRegistered(address _oracle) external view returns (bool);

    /// @notice Check if an oracle is active i.e. are we allowed to create options with this oracle
    /// @param _oracle the oracle to check
    function isOracleActive(address _oracle) external view returns (bool);

    /// @notice Get the numeric id of an oracle
    /// @param _oracle the oracle to get the id of
    function getOracleId(address _oracle) external view returns (uint248);

    /// @notice Get total number of oracles in registry
    /// @return the number of oracles in the registry
    function getOraclesLength() external view returns (uint248);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

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
    function fromUnscaledInt(int256 a) internal pure returns (FixedPointInt memory) {
        return FixedPointInt(a * _SCALING_FACTOR);
    }

    /**
     * @notice constructs an FixedPointInt from an scaled uint with {_decimals} decimals
     * Examples:
     * (1)  USDC    decimals = 6
     * Input:  5 * 1e6 USDC  =>    Output: 5 * 1e27 (FixedPoint 5.0 USDC)
     * (2)  cUSDC   decimals = 8
     * Input:  5 * 1e6 cUSDC =>    Output: 5 * 1e25 (FixedPoint 0.05 cUSDC)
     * @param _a uint256 to convert into a FixedPoint.
     * @param _decimals  original decimals _a has
     * @return the converted FixedPoint, with 27 decimals.
     */
    function fromScaledUint(uint256 _a, uint256 _decimals) internal pure returns (FixedPointInt memory) {
        FixedPointInt memory fixedPoint;

        if (_decimals == _BASE_DECIMALS) {
            fixedPoint = FixedPointInt(_a.uintToInt());
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            fixedPoint = FixedPointInt(uint256(_a / 10 ** exp).uintToInt());
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            fixedPoint = FixedPointInt(uint256(_a * 10 ** exp).uintToInt());
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
    function toScaledUint(FixedPointInt memory _a, uint256 _decimals, bool _roundDown)
        internal
        pure
        returns (uint256)
    {
        uint256 scaledUint;

        if (_decimals == _BASE_DECIMALS) {
            scaledUint = _a.value.intToUint();
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            scaledUint = _a.value.intToUint() * 10 ** exp;
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            uint256 tailing;
            if (!_roundDown) {
                uint256 remainder = _a.value.intToUint() % 10 ** exp;
                if (remainder > 0) {
                    tailing = 1;
                }
            }
            scaledUint = _a.value.intToUint() / 10 ** exp + tailing;
        }

        return scaledUint;
    }

    /**
     * @notice add two signed integers, a + b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return sum of the two signed integers
     */
    function add(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return FixedPointInt(a.value + b.value);
    }

    /**
     * @notice subtract two signed integers, a-b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return difference of two signed integers
     */
    function sub(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return FixedPointInt(a.value - b.value);
    }

    /**
     * @notice multiply two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return mul of two signed integers
     */
    function mul(FixedPointInt memory a, FixedPointInt memory b, bool roundDown)
        internal
        pure
        returns (FixedPointInt memory)
    {
        int256 remainder = a.value * b.value % _SCALING_FACTOR;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt(a.value * b.value / _SCALING_FACTOR + tailing);
    }

    /**
     * @notice divide two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return div of two signed integers
     */
    function div(FixedPointInt memory a, FixedPointInt memory b, bool roundDown)
        internal
        pure
        returns (FixedPointInt memory)
    {
        int256 remainder = a.value * _SCALING_FACTOR % b.value;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt(a.value * _SCALING_FACTOR / b.value + tailing);
    }

    /**
     * @notice minimum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return min of two signed integers
     */
    function min(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return a.value < b.value ? a : b;
    }

    /**
     * @notice maximum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return max of two signed integers
     */
    function max(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (FixedPointInt memory) {
        return a.value > b.value ? a : b;
    }

    /**
     * @notice is a is equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if equal, False if not
     */
    function isEqual(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value == b.value;
    }

    /**
     * @notice is a greater than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a > b, False if not
     */
    function isGreaterThan(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value > b.value;
    }

    /**
     * @notice is a greater than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a >= b, False if not
     */
    function isGreaterThanOrEqual(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value >= b.value;
    }

    /**
     * @notice is a is less than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a < b, False if not
     */
    function isLessThan(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value < b.value;
    }

    /**
     * @notice is a less than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a <= b, False if not
     */
    function isLessThanOrEqual(FixedPointInt memory a, FixedPointInt memory b) internal pure returns (bool) {
        return a.value <= b.value;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

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
        require(a < 2 ** 255, "QuantMath: out of int range");

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