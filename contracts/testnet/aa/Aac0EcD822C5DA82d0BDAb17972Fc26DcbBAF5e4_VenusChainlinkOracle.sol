// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/VBep20Interface.sol";
import "./interfaces/AggregatorV2V3Interface.sol";

contract VenusChainlinkOracle {
    using SafeMath for uint256;
    uint256 public constant VAI_VALUE = 1e18;
    address public admin;

    mapping(address => uint256) internal prices;
    mapping(address => uint256) internal maxStalePeriods;
    mapping(address => AggregatorV2V3Interface) internal feeds;

    event PricePosted(
        address asset,
        uint256 previousPriceMantissa,
        uint256 requestedPriceMantissa,
        uint256 newPriceMantissa
    );
    event NewAdmin(address oldAdmin, address newAdmin);
    event FeedSet(address feed, address asset, uint256 maxStalePeriod);

    constructor() {
        admin = msg.sender;
    }

    function getUnderlyingPrice(VBep20Interface vToken) public view returns (uint256) {
        string memory symbol = vToken.symbol();
        // VBNB token doesn't have `underlying` method 
        if (compareStrings(symbol, "vBNB")) {
            return getChainlinkPrice(getFeed(address(vToken)));
        // VAI price is constantly 1
        } else if (compareStrings(symbol, "VAI")) {
            return VAI_VALUE;
        // @todo: This is some history code, keep it here in case of messing up 
        } else if (compareStrings(symbol, "XVS")) {
            return prices[address(vToken)];
        } else {
            return getUnderlyingPriceInternal(vToken);
        }
    }

    function getUnderlyingPriceInternal(VBep20Interface vToken) internal view returns (uint256 price) {
        VBep20Interface token = VBep20Interface(vToken.underlying());

        if (prices[address(token)] != 0) {
            price = prices[address(token)];
        } else {
            price = getChainlinkPrice(getFeed(address(vToken)));
        }

        uint256 decimalDelta = uint256(18).sub(uint256(token.decimals()));
        // Ensure that we don't multiply the result by 0
        if (decimalDelta > 0) {
            return price.mul(10**decimalDelta);
        } else {
            return price;
        }
    }

    function getChainlinkPrice(AggregatorV2V3Interface feed) internal view returns (uint256) {
        // Chainlink USD-denominated feeds store answers at 8 decimals
        uint256 decimalDelta = uint256(18).sub(feed.decimals());

        (, int256 answer, , uint256 updatedAt, ) = feed.latestRoundData();

        // a feed with 0 max stale period or doesn't exist, return 0
        uint256 maxStalePeriod = maxStalePeriods[address(feed)];
        if (maxStalePeriod == 0) {
            return 0;
        }

        // Ensure that we don't multiply the result by 0
        if (block.timestamp.sub(updatedAt, "updatedAt exceeds block time") > maxStalePeriod) {
            return 0;
        }

        if (decimalDelta > 0) {
            return uint256(answer).mul(10**decimalDelta);
        } else {
            return uint256(answer);
        }
    }

    function setUnderlyingPrice(VBep20Interface vToken, uint256 underlyingPriceMantissa) external onlyAdmin {
        address asset = address(vToken.underlying());
        emit PricePosted(asset, prices[asset], underlyingPriceMantissa, underlyingPriceMantissa);
        prices[asset] = underlyingPriceMantissa;
    }

    function setDirectPrice(address asset, uint256 price) external onlyAdmin {
        emit PricePosted(asset, prices[asset], price, price);
        prices[asset] = price;
    }

    function batchSetFeeds(
        address[] calldata assets_,
        address[] calldata feeds_,
        uint256[] calldata maxStalePeriods_
    ) external onlyAdmin {
        require(assets_.length == feeds_.length, "invalid length");
        require(assets_.length == maxStalePeriods_.length, "invalid length");
        require(assets_.length > 0, "empty feeds");
        for (uint256 i = 0; i < assets_.length; i++) {
            setFeed(assets_[i], feeds_[i], maxStalePeriods_[i]);
        }
    }

    function setFeed(address asset, address feed, uint256 maxStalePeriod) public onlyAdmin {
        require(feed != address(0) && feed != address(this), "invalid feed address");
        require(maxStalePeriod > 0, "stale period can't be zero");
        feeds[asset] = AggregatorV2V3Interface(feed);
        maxStalePeriods[feed] = maxStalePeriod;
        emit FeedSet(feed, asset, maxStalePeriod);
    }

    function getFeed(address vToken) public view returns (AggregatorV2V3Interface) {
        return feeds[vToken];
    }

    function getMaxStalePeriod(address feed) external view returns (uint256) {
        return maxStalePeriods[feed];
    }

    function assetPrices(address asset) external view returns (uint256) {
        return prices[asset];
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        address oldAdmin = admin;
        admin = newAdmin;

        emit NewAdmin(oldAdmin, newAdmin);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin may call");
        _;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title The V2 & V3 Aggregator Interface
 * @notice Solidity V0.5 does not allow interfaces to inherit from other
 * interfaces so this contract is a combination of v0.5 AggregatorInterface.sol
 * and v0.5 AggregatorV3Interface.sol.
 */
interface AggregatorV2V3Interface {
    //
    // V2 Interface:
    //
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function latestRound() external view returns (uint256);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
    event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);

    //
    // V3 Interface:
    //
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface BEP20Interface {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./BEP20Interface.sol";

interface VBep20Interface is BEP20Interface {
    /**
     * @notice Underlying asset for this VToken
     */
    function underlying() external view returns (address);
}