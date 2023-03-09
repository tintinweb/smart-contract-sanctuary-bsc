// SPDX-License-Identifier: MIT

import "../libraries/math/SafeMath.sol";

import "./interfaces/IVaultPriceFeed.sol";
import "../oracle/interfaces/IPriceFeed.sol";
import "../oracle/interfaces/ISecondaryPriceFeed.sol";
import "../amm/interfaces/IPancakePair.sol";

pragma solidity 0.6.12;

contract VaultPriceFeed is IVaultPriceFeed {
    using SafeMath for uint256;

    uint256 public constant PRICE_PRECISION = 10 ** 30;
    uint256 public constant ONE_USD = PRICE_PRECISION;
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant MAX_SPREAD_BASIS_POINTS = 50;
    uint256 public constant MAX_ADJUSTMENT_INTERVAL = 2 hours;
    uint256 public constant MAX_ADJUSTMENT_BASIS_POINTS = 20;

    address public gov;

    bool public isSecondaryPriceEnabled;
    uint256 public priceSampleSpace;
    uint256 public maxStrictPriceDeviation;
    address public secondaryPriceFeed;

    mapping(address => address) public priceFeeds;
    mapping(address => uint256) public priceDecimals;
    mapping(address => uint256) public spreadBasisPoints;
    // Chainlink can return prices for stablecoins
    // that differs from 1 USD by a larger percentage than stableSwapFeeBasisPoints
    // we use strictStableTokens to cap the price to 1 USD
    // this allows us to configure stablecoins like DAI as being a stableToken
    // while not being a strictStableToken
    mapping(address => bool) public strictStableTokens;

    mapping(address => uint256) public override adjustmentBasisPoints;
    mapping(address => bool) public override isAdjustmentAdditive;
    mapping(address => uint256) public lastAdjustmentTimings;

    event SetGov(address gov);
    event SetAdjustment(address token, bool additive, uint256 adjustmentBps);
    event SecondaryPriceEnabled(bool enabled);
    event SetSecondaryPriceFeed(address secondaryPriceFeed);
    event SetSpreadBasisPoints(address token, uint256 spreadBasisPoints);
    event SetPriceSampleSpace(uint256 priceSampleSpace);
    event SetMaxStrictPriceDeviation(uint256 maxStrictPriceDeviation);
    event SetTokenConfig(
        address token,
        address priceFeed,
        uint256 priceDecimals,
        bool isStrictStable
    );

    modifier onlyGov() {
        require(msg.sender == gov, "VaultPriceFeed: forbidden");
        _;
    }

    constructor() public {
        gov = msg.sender;
        priceSampleSpace = 1;
    }

    function setGov(address _gov) external onlyGov {
        require(_gov != address(0));
        gov = _gov;
        emit SetGov(_gov);
    }

    function setAdjustment(
        address _token,
        bool _isAdditive,
        uint256 _adjustmentBps
    ) external override onlyGov {
        require(_token != address(0));
        require(
            lastAdjustmentTimings[_token].add(MAX_ADJUSTMENT_INTERVAL) <
                block.timestamp,
            "VaultPriceFeed: adjustment frequency exceeded"
        );
        require(
            _adjustmentBps <= MAX_ADJUSTMENT_BASIS_POINTS,
            "invalid _adjustmentBps"
        );
        isAdjustmentAdditive[_token] = _isAdditive;
        adjustmentBasisPoints[_token] = _adjustmentBps;
        lastAdjustmentTimings[_token] = block.timestamp;
        emit SetAdjustment(_token, _isAdditive, _adjustmentBps);
    }

    function setIsSecondaryPriceEnabled(
        bool _isEnabled
    ) external override onlyGov {
        isSecondaryPriceEnabled = _isEnabled;
        emit SecondaryPriceEnabled(_isEnabled);
    }

    function setSecondaryPriceFeed(
        address _secondaryPriceFeed
    ) external override onlyGov {
        secondaryPriceFeed = _secondaryPriceFeed;
        emit SetSecondaryPriceFeed(_secondaryPriceFeed);
    }

    function setSpreadBasisPoints(
        address _token,
        uint256 _spreadBasisPoints
    ) external override onlyGov {
        require(
            _spreadBasisPoints <= MAX_SPREAD_BASIS_POINTS,
            "VaultPriceFeed: invalid _spreadBasisPoints"
        );
        spreadBasisPoints[_token] = _spreadBasisPoints;
        emit SetSpreadBasisPoints(_token, _spreadBasisPoints);
    }

    function setPriceSampleSpace(
        uint256 _priceSampleSpace
    ) external override onlyGov {
        require(
            _priceSampleSpace > 0,
            "VaultPriceFeed: invalid _priceSampleSpace"
        );
        priceSampleSpace = _priceSampleSpace;
        emit SetPriceSampleSpace(_priceSampleSpace);
    }

    function setMaxStrictPriceDeviation(
        uint256 _maxStrictPriceDeviation
    ) external override onlyGov {
        maxStrictPriceDeviation = _maxStrictPriceDeviation;
        emit SetMaxStrictPriceDeviation(_maxStrictPriceDeviation);
    }

    function setTokenConfig(
        address _token,
        address _priceFeed,
        uint256 _priceDecimals,
        bool _isStrictStable
    ) external override onlyGov {
        priceFeeds[_token] = _priceFeed;
        priceDecimals[_token] = _priceDecimals;
        strictStableTokens[_token] = _isStrictStable;
        emit SetTokenConfig(
            _token,
            _priceFeed,
            _priceDecimals,
            _isStrictStable
        );
    }

    function getPrice(
        address _token,
        bool _maximise,
        bool /* _useSwapPricing */
    ) public view override returns (uint256) {
        uint256 price = getPriceV1(_token, _maximise);

        uint256 adjustmentBps = adjustmentBasisPoints[_token];
        if (adjustmentBps > 0) {
            bool isAdditive = isAdjustmentAdditive[_token];
            if (isAdditive) {
                price = price.mul(BASIS_POINTS_DIVISOR.add(adjustmentBps)).div(
                    BASIS_POINTS_DIVISOR
                );
            } else {
                price = price.mul(BASIS_POINTS_DIVISOR.sub(adjustmentBps)).div(
                    BASIS_POINTS_DIVISOR
                );
            }
        }

        return price;
    }

    function getPriceV1(
        address _token,
        bool _maximise
    ) public view returns (uint256) {
        uint256 price = getPrimaryPrice(_token, _maximise);

        if (isSecondaryPriceEnabled) {
            price = getSecondaryPrice(_token, price, _maximise);
        }

        if (strictStableTokens[_token]) {
            uint256 delta = price > ONE_USD
                ? price.sub(ONE_USD)
                : ONE_USD.sub(price);
            if (delta <= maxStrictPriceDeviation) {
                return ONE_USD;
            }

            // if _maximise and price is e.g. 1.02, return 1.02
            if (_maximise && price > ONE_USD) {
                return price;
            }

            // if !_maximise and price is e.g. 0.98, return 0.98
            if (!_maximise && price < ONE_USD) {
                return price;
            }

            return ONE_USD;
        }

        uint256 _spreadBasisPoints = spreadBasisPoints[_token];

        if (_maximise) {
            return
                price.mul(BASIS_POINTS_DIVISOR.add(_spreadBasisPoints)).div(
                    BASIS_POINTS_DIVISOR
                );
        }

        return
            price.mul(BASIS_POINTS_DIVISOR.sub(_spreadBasisPoints)).div(
                BASIS_POINTS_DIVISOR
            );
    }

    function getLatestPrimaryPrice(
        address _token
    ) public view override returns (uint256) {
        address priceFeedAddress = priceFeeds[_token];
        require(
            priceFeedAddress != address(0),
            "VaultPriceFeed: invalid price feed"
        );

        IPriceFeed priceFeed = IPriceFeed(priceFeedAddress);

        (, int256 price, , uint256 updatedAt, ) = priceFeed.latestRoundData();
        require(price > 0 && updatedAt > 0, "VaultPriceFeed: invalid price");

        return uint256(price);
    }

    function getPrimaryPrice(
        address _token,
        bool _maximise
    ) public view override returns (uint256) {
        address priceFeedAddress = priceFeeds[_token];
        require(
            priceFeedAddress != address(0),
            "VaultPriceFeed: invalid price feed"
        );

        IPriceFeed priceFeed = IPriceFeed(priceFeedAddress);

        uint256 price = 0;
        (uint80 roundId, int256 _price, , uint256 updatedAt, ) = priceFeed
            .latestRoundData();

        for (uint80 i = 0; i < priceSampleSpace; i++) {
            if (roundId <= i) {
                break;
            }
            uint256 p;

            if (i == 0) {
                require(
                    _price > 0 && updatedAt > 0,
                    "VaultPriceFeed: invalid price"
                );
                p = uint256(_price);
            } else {
                (, int256 _p, , uint256 _t, ) = priceFeed.getRoundData(
                    roundId - i
                );
                require(_p > 0 && _t > 0, "VaultPriceFeed: invalid price");
                p = uint256(_p);
            }

            if (price == 0) {
                price = p;
                continue;
            }

            if (_maximise && p > price) {
                price = p;
                continue;
            }

            if (!_maximise && p < price) {
                price = p;
            }
        }

        require(price > 0, "VaultPriceFeed: could not fetch price");
        // normalise price precision
        uint256 _priceDecimals = priceDecimals[_token];
        return price.mul(PRICE_PRECISION).div(10 ** _priceDecimals);
    }

    function getSecondaryPrice(
        address _token,
        uint256 _referencePrice,
        bool _maximise
    ) public view returns (uint256) {
        if (secondaryPriceFeed == address(0)) {
            return _referencePrice;
        }
        return
            ISecondaryPriceFeed(secondaryPriceFeed).getPrice(
                _token,
                _referencePrice,
                _maximise
            );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IVaultPriceFeed {
    function adjustmentBasisPoints(
        address _token
    ) external view returns (uint256);

    function isAdjustmentAdditive(address _token) external view returns (bool);

    function setAdjustment(
        address _token,
        bool _isAdditive,
        uint256 _adjustmentBps
    ) external;

    function setIsSecondaryPriceEnabled(bool _isEnabled) external;

    function setSpreadBasisPoints(
        address _token,
        uint256 _spreadBasisPoints
    ) external;

    function setPriceSampleSpace(uint256 _priceSampleSpace) external;

    function setMaxStrictPriceDeviation(
        uint256 _maxStrictPriceDeviation
    ) external;

    function getPrice(
        address _token,
        bool _maximise,
        bool _useSwapPricing
    ) external view returns (uint256);

    function getLatestPrimaryPrice(
        address _token
    ) external view returns (uint256);

    function getPrimaryPrice(
        address _token,
        bool _maximise
    ) external view returns (uint256);

    function setTokenConfig(
        address _token,
        address _priceFeed,
        uint256 _priceDecimals,
        bool _isStrictStable
    ) external;

    function setSecondaryPriceFeed(address _secondaryPriceFeed) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IPriceFeed {
    function description() external view returns (string memory);

    function aggregator() external view returns (address);

    function latestAnswer() external view returns (int256);

    function latestRound() external view returns (uint80);

    function getRoundData(uint80 roundId)
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ISecondaryPriceFeed {
    function getPrice(address _token, uint256 _referencePrice, bool _maximise) external view returns (uint256);
}