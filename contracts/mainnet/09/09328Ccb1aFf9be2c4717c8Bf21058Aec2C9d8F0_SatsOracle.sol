// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.4;

import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "../../interface/IOracle.sol";

contract SatsOracle is IOracle {
    using SignedSafeMath for int256;
    IOracle public immutable btcOracle;

    constructor(address _btcOracle) {
        btcOracle = IOracle(_btcOracle);
    }

    function isMarketClosed() external override returns (bool) {
        return btcOracle.isMarketClosed();
    }

    function isTerminated() external override returns (bool) {
        // return btcOracle.isTerminated();
        return true; // the perpetual will settle at Apr.25 2022
    }

    function collateral() external pure override returns (string memory) {
        return "SATS";
    }

    function underlyingAsset() external pure override returns (string memory) {
        return "USD";
    }

    function priceTWAPLong() external override returns (int256, uint256) {
        int256 btcPrice;
        uint256 timestamp;
        (btcPrice, timestamp) = btcOracle.priceTWAPLong();
        return (int256(10**44).div(btcPrice), timestamp);
    }

    function priceTWAPShort() external override returns (int256, uint256) {
        int256 btcPrice;
        uint256 timestamp;
        (btcPrice, timestamp) = btcOracle.priceTWAPShort();
        return (int256(10**44).div(btcPrice), timestamp);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */
library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
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
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.4;

interface IOracle {
    /**
     * @dev The market is closed if the market is not in its regular trading period.
     */
    function isMarketClosed() external returns (bool);

    /**
     * @dev The oracle service was shutdown and never online again.
     */
    function isTerminated() external returns (bool);

    /**
     * @dev Get collateral symbol. Also known as quote.
     */
    function collateral() external view returns (string memory);

    /**
     * @dev Get underlying asset symbol. Also known as base.
     */
    function underlyingAsset() external view returns (string memory);

    /**
     * @dev Mark price. Used to evaluate the account margin balance and liquidation.
     *
     *      It does not need to be a TWAP. This name is only for backward compatibility.
     */
    function priceTWAPLong() external returns (int256 newPrice, uint256 newTimestamp);

    /**
     * @dev Index price. It is AMM reference price.
     *
     *      It does not need to be a TWAP. This name is only for backward compatibility.
     */
    function priceTWAPShort() external returns (int256 newPrice, uint256 newTimestamp);
}