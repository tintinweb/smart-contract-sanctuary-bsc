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

pragma solidity 0.6.12;

interface IEpoch {
    function epoch() external view returns (uint256);

    function nextEpochPoint() external view returns (uint256);

    function nextEpochLength() external view returns (uint256);

    function getPegPrice() external view returns (int256);

    function getPegPriceUpdated() external view returns (int256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IRegulationStats {
    function addEpochInfo(uint256 epochNumber, uint256 priceInOunce, uint256 expanded,
        uint256 boardroomFunding, uint256 daoFunding, uint256 safeFunding, uint256 marketingFunding, uint256 goldenVerseFunding) external;

    function addBonded(uint256 epochNumber, uint256 added) external;

    function addRedeemed(uint256 epochNumber, uint256 added) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IEpoch.sol";

interface ITreasury is IEpoch {
    function getGrainPrice() external view returns (uint256);

    function getGrainUpdatedPrice() external view returns (uint256);

    function getGrainLockedBalance() external view returns (uint256);

    function getGrainCirculatingSupply() external view returns (uint256);

    function getGrainExpansionRate() external view returns (uint256);

    function getGrainExpansionAmount() external view returns (uint256);

    function boardroom() external view returns (address);

    function boardroomSharedPercent() external view returns (uint256);

    function daoFund() external view returns (address);

    function daoFundSharedPercent() external view returns (uint256);

    function safeFund() external view returns (address);

    function safeFundSharedPercent() external view returns (uint256);

    function marketingFund() external view returns (address);

    function marketingFundSharedPercent() external view returns (uint256);

    function goldenVerse() external view returns (address);

    function goldenVerseSharedPercent() external view returns (uint256);

    function getBondDiscountRate() external view returns (uint256);

    function getBondPremiumRate() external view returns (uint256);

    function buyBonds(uint256 amount, uint256 targetPrice) external;

    function redeemBonds(uint256 amount, uint256 targetPrice) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IRegulationStats.sol";
import "../interfaces/ITreasury.sol";

contract RegulationStats is IRegulationStats {
    using SafeMath for uint256;

    struct Epoch {
        uint256 priceInOunce;
        uint256 expanded;
        uint256 bonded;
        uint256 redeemed;
        uint256 boardroomFunding;
        uint256 daoFunding;
        uint256 safeFunding;
        uint256 marketingFunding;
        uint256 goldenVerseFunding;
    }

    /* ========== STATE VARIABLES ========== */

    // governance
    address public operator;
    address public treasury;

    // flags
    bool private initialized = false;

    mapping(uint256 => Epoch) public epochInfo;

    /* =================== Added variables (need to keep orders for proxy to work) =================== */
    // ...

    /* =================== Events =================== */

    event Initialized(address indexed executor, uint256 at);

    /* =================== Modifier =================== */

    modifier onlyOperator() {
        require(operator == msg.sender, "!operator");
        _;
    }

    modifier onlyTreasuryOrOperator() {
        require(treasury == msg.sender || operator == msg.sender, "!operator && !treasury");
        _;
    }

    modifier notInitialized {
        require(!initialized, "RegulationStats: already initialized");

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function isInitialized() public view returns (bool) {
        return initialized;
    }

    function getCurrentEpoch() public view returns (uint256) {
        return ITreasury(treasury).epoch();
    }

    function getNextEpochPoint() public view returns (uint256) {
        return ITreasury(treasury).nextEpochPoint();
    }

    function getEpochInfo(uint256 _start, uint256 _numEpochs) public view returns (uint256[] memory results) {
        results = new uint256[](_numEpochs * 9);
        uint256 _rindex = 0;
        for (uint256 i = 0; i < _numEpochs; i++) {
            Epoch memory _epochInfo = epochInfo[_start + i];
            results[_rindex++] = _epochInfo.priceInOunce;
            results[_rindex++] = _epochInfo.expanded;
            results[_rindex++] = _epochInfo.bonded;
            results[_rindex++] = _epochInfo.redeemed;
            results[_rindex++] = _epochInfo.boardroomFunding;
            results[_rindex++] = _epochInfo.daoFunding;
            results[_rindex++] = _epochInfo.safeFunding;
            results[_rindex++] = _epochInfo.marketingFunding;
            results[_rindex++] = _epochInfo.goldenVerseFunding;
        }
    }

    /* ========== GOVERNANCE ========== */

    function initialize(address _treasury) public notInitialized {
        treasury = _treasury;

        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.timestamp);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setTreasury(address _treasury) external onlyOperator {
        treasury = _treasury;
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    function addEpochInfo(uint256 epochNumber, uint256 priceInOunce, uint256 expanded,
        uint256 boardroomFunding, uint256 daoFunding, uint256 safeFunding, uint256 marketingFunding, uint256 goldenVerseFunding) external override onlyTreasuryOrOperator {
        Epoch storage _epochInfo = epochInfo[epochNumber];
        _epochInfo.priceInOunce = priceInOunce;
        _epochInfo.expanded = expanded;
        _epochInfo.boardroomFunding = boardroomFunding;
        _epochInfo.daoFunding = daoFunding;
        _epochInfo.safeFunding = safeFunding;
        _epochInfo.marketingFunding = marketingFunding;
        _epochInfo.goldenVerseFunding = goldenVerseFunding;
    }

    function addBonded(uint256 epochNumber, uint256 added) external override onlyTreasuryOrOperator {
        Epoch storage _epochInfo = epochInfo[epochNumber];
        _epochInfo.bonded = _epochInfo.bonded.add(added);
    }

    function addRedeemed(uint256 epochNumber, uint256 added) external override onlyTreasuryOrOperator {
        Epoch storage _epochInfo = epochInfo[epochNumber];
        _epochInfo.redeemed = _epochInfo.redeemed.add(added);
    }

    /* ========== EMERGENCY ========== */

    function rescueStuckErc20(IERC20 _token) external onlyOperator {
        _token.transfer(operator, _token.balanceOf(address(this)));
    }
}