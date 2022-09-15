// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./DefxInterfaces.sol";
import "./interfaces/IDefxStat.sol";
import "./interfaces/IDefxFactory.sol";

// DeFX User Statistics contract
contract DefxStat is IDefxStat {
    address public factory;

    constructor() {
        factory = msg.sender;
    }

    modifier onlyPair() {
        require(IDefxFactory(factory).isPair(msg.sender), "DefxFactory: !PAIR");
        _;
    }

    mapping(address => UserProfile) public userProfile;
    mapping(address => mapping(address => bool)) /* from */ /* to */
        public feedbackAllowed;

    function getUserProfile(address account) public view returns (UserProfile memory) {
        return userProfile[account];
    }

    function setFeedbackAllowed(address a, address b) external onlyPair {
        feedbackAllowed[a][b] = true;
        feedbackAllowed[b][a] = true;
    }

    function _setFirstDeal(address account) internal {
        if (userProfile[account].firstDealBlock == 0) {
            userProfile[account].firstDealBlock = block.number;
        }
    }

    function _incrementCompletedDeal(address account) internal {
        userProfile[account].completedDeals++;
        _setFirstDeal(account);
    }

    function _incrementFailedDeal(address account) internal {
        userProfile[account].failedDeals++;
    }

    function incrementCompletedDeal(address a, address b) external onlyPair {
        _incrementCompletedDeal(a);
        _incrementCompletedDeal(b);
    }

    function incrementFailedDeal(address a, address b) external onlyPair {
        _incrementFailedDeal(a);
        _incrementFailedDeal(b);
    }

    function _submitFeedback(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) internal {
        userProfile[to].feedbacks.push(Feedback({isPositive: isPositive, desc: desc, from: from, blockNumber: block.number}));
        feedbackAllowed[from][to] = false;
    }

    function submitFeedback(
        address to,
        bool isPositive,
        string calldata desc
    ) external {
        require(feedbackAllowed[msg.sender][to], "DefxFactory: NOT_ALLOWED");
        _submitFeedback(msg.sender, to, isPositive, desc);
    }

    function submitFeedbackFrom(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) external onlyPair {
        _submitFeedback(from, to, isPositive, desc);
    }

    function setName(string calldata name) external {
        userProfile[msg.sender].name = name;
    }

    function setSocialAccounts(string calldata data) external {
        userProfile[msg.sender].socialAccounts = data;
    }

    function setUserProfile(string calldata name, string calldata socialAccounts) external {
        userProfile[msg.sender].name = name;
        userProfile[msg.sender].socialAccounts = socialAccounts;
    }
}

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

struct Message {
    string encryptedForSeller;
    string encryptedForBuyer;
    address from;
}

struct Deal {
    uint256 amountCrypto;
    uint256 collateral;
    uint256 amountFiat;
    bool isBuyerOwner;
    string paymentMethod;
    Message[] messages;
    bool fiatSent;
    uint256 bankSentAtBlock;
}

struct Offer {
    uint256 min;
    uint256 max;
    uint256 available;
    uint256 collateral;
    uint256 price;
    string[] paymentMethods;
    string desc;
    uint256 ratio;
    uint256 lastUpdatedBlock;
}

struct DealLinks {
    mapping(address => address[]) buyers;
    mapping(address => address[]) sellers;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./IDefxFactory.sol";

struct UserProfile {
    string name;
    string socialAccounts;
    uint256 completedDeals;
    uint256 failedDeals;
    uint256 firstDealBlock;
    Feedback[] feedbacks;
}

struct Feedback {
    bool isPositive;
    string desc;
    address from;
    uint256 blockNumber;
}

interface IDefxStat {
    function getUserProfile(address account) external view returns (UserProfile memory);

    function setFeedbackAllowed(address a, address b) external;

    function incrementCompletedDeal(address a, address b) external;

    function incrementFailedDeal(address a, address b) external;

    function submitFeedback(
        address to,
        bool isPositive,
        string calldata desc
    ) external;

    function submitFeedbackFrom(
        address from,
        address to,
        bool isPositive,
        string calldata desc
    ) external;

    function setName(string calldata name) external;

    function setSocialAccounts(string calldata data) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

interface IDefxFactory {
    event PairCreated(address cryptoAddress, string fiatAddress, address pair, uint256);

    function getPair(address tokenA, string memory fiatAddress) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function encKeys(address account) external view returns (string memory);

    function isPair(address pairAddr) external view returns (bool);

    function statAddress() external view returns (address);

    function setStatAddress(address _addr) external;

    function setAllowedCoin(address _coinAddress) external;

    function payFee(address _coinAddres) external;
}