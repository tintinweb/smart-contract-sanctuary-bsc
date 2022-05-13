// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '../lib/IB8DexTokenSale.sol';
import '../lib/IB8DToken.sol';

contract B8DexTokenSale is IB8DexTokenSale, Ownable {
    using SafeMath for uint256;

    IB8DToken public b8dToken;            // The Token token itself

    uint256 public totalSupply;           // Total Token sale amount
    uint8 public decimals;

    enum Status {
        PreSale,
        Paused,
        Sale,
        Close
    }

    struct Window {
        uint256 startTime;
        uint256 percent;
    }

    mapping(Status => mapping(uint32 => Window)) private _windows;
    mapping(Status => uint256) private _prices;
    mapping(Status => uint256) private _amounts;

    uint32[] private _saleWindowsIds;
    uint32[] private _preSaleWindowsIds;

    bool public tokenSaleRunning;

    Status public status;
    uint256 public totalBoughtTokens;
    uint256 public totalRaisedBUSD;

    mapping(address => mapping(Status => uint256)) public userBuys;
    mapping(address => mapping(Status => mapping(uint32 => bool))) public claimed;

    event LogBuy           (Status status, uint256 time, address user, uint256 amount, uint256 amountBUSD);
    event LogClaim         (uint32 window, uint256 time, address user, uint256 amount);
    event LogCollect       (uint256 amount);
    event LogCollectUnsold (uint256 amount);

    /**
     * @notice Constructor
     * @param _b8dToken: address of the B8D token
     */
    constructor(
        address _b8dToken,
        uint256[] memory _windowStartTimes,
        uint256[] memory _windowsPercents,
        uint256[] memory _windowStartTimesPreSale,
        uint256[] memory _windowsPercentsPreSale,
        uint256[2] memory _saleAmounts,
        uint256[2] memory _pricesB8DInBUSD,
        uint8 _decimals
    ) {
        b8dToken = IB8DToken(_b8dToken);

        // Initializes a windows
        // sale windows
        for (uint32 i = 0; i < _windowStartTimes.length; i++) {
            uint256 thisWindowStartTime = _windowStartTimes[i];
            uint256 thisWindowPercent = _windowsPercents[i];

            _windows[Status.Sale][i] = Window({startTime: thisWindowStartTime, percent: thisWindowPercent});
        }
        _saleWindowsIds = new uint32[](_windowStartTimes.length);

        // pre sale windows
        for (uint32 j = 0; j < _windowStartTimesPreSale.length; j++) {
            uint256 thisWindowStartTimePreSale = _windowStartTimesPreSale[j];
            uint256 thisWindowPercentPreSale = _windowsPercentsPreSale[j];

            _windows[Status.PreSale][j] = Window({startTime: thisWindowStartTimePreSale, percent: thisWindowPercentPreSale});
        }
        _preSaleWindowsIds = new uint32[](_windowStartTimesPreSale.length);

        // prices
        _prices[Status.PreSale] = _pricesB8DInBUSD[0] * 10**uint(_decimals - 2);
        _prices[Status.Sale] = _pricesB8DInBUSD[1] * 10**uint(_decimals - 2);

        // amounts
        _amounts[Status.PreSale] = _saleAmounts[0] * 10**uint(_decimals);
        _amounts[Status.Sale] = _saleAmounts[1] * 10**uint(_decimals);
        totalSupply = _amounts[Status.PreSale].add(_amounts[Status.Sale]);

        tokenSaleRunning = false;

        status = Status.Paused;

        totalRaisedBUSD = 0;
        decimals = _decimals;
    }

    /** @dev Begin Token Sale
     *
     */
    function begin()
    external
    onlyOwner
    {
        b8dToken.transfer(address(this), totalSupply);
        status = Status.PreSale;
        tokenSaleRunning = true;
    }

    /** @dev Buy Tokens by BUSD
     *
     */
    function buy() external payable {
        _buy(_msgSender(), msg.value);
    }

    fallback() external payable {
        _buy(_msgSender(), msg.value);
    }

    receive() external payable {
        _buy(_msgSender(), msg.value);
    }

    /** @dev Claim all tokens by all windows
     *
     */
    function claimAll() external {
        for (uint32 i = 0; i < _preSaleWindowsIds.length; i++) {
            if (_time() > _windows[Status.PreSale][i].startTime) {
                Window memory window = _windows[Status.PreSale][i];

                _claim(window, Status.PreSale, i, _msgSender());
            }
        }

        for (uint32 j = 0; j < _saleWindowsIds.length; j++) {
            if (_time() > _windows[Status.Sale][j].startTime) {
                Window memory window = _windows[Status.Sale][j];

                _claim(window, Status.Sale, j, _msgSender());
            }
        }
    }

    /** @dev Burn B8D Tokens by owner
     *
     */
    function burnTokens(uint256 amount)
    external
    onlyOwner
    {
        b8dToken.burn(amount);
    }

    /** @dev Collect BUSD to owner
     *
     */
    function collect()
    external
    onlyOwner
    {
       _collect();
    }

    /** @dev Collect Unsold Tokens to owner
     *
     */
    function collectUnsoldTokens()
    external
    onlyOwner
    {
        _collectUnsoldTokens();
    }

    /** @dev Change Token Sale Status for actual contract
     *
     * @param _status: new Token Sale Status
     */
    function changeStatus(
        Status _status
    )
    external
    onlyOwner
    {
        _changeStatus(_status);
    }

    /** @dev Start and Stop actual contract
     *
     */
    function startStopTokenSale()
    external
    onlyOwner
    returns (bool) {
        _startStopTokenSale();
        return true;
    }

    /** @dev Return actual time
     *
     */
    function _time()
    internal
    view
    returns (uint)
    {
        return block.timestamp;
    }

    /** @dev Buy Tokens by BUSD
     *
     * @param sender: user address
     * @param busdCount: BUSD count
     */
    function _buy(
        address sender,
        uint256 busdCount
    ) internal {
        require(tokenSaleRunning == true, "tokenSaleRunning should be == true");
        require(status != Status.Close, "Token Sale is Closed");
        require(status != Status.Paused, "Token Sale is Paused");

        uint256 b8dAmount = busdCount.div(_prices[status]) * 10**uint(decimals);
        uint256 totalBoughtTokensWithAmount = totalBoughtTokens.add(b8dAmount);
        uint256 time = _time();

        if (status == Status.PreSale) {
            require(totalBoughtTokensWithAmount <= _amounts[Status.PreSale], "totalBoughtTokensWithAmount should be <= preSale Amount");
        }

        require(totalBoughtTokensWithAmount <= totalSupply, "totalBoughtTokensWithAmount should be <= totalSupply");

        userBuys[sender][status] = userBuys[sender][status].add(b8dAmount);
        totalRaisedBUSD = totalRaisedBUSD.add(busdCount);
        totalBoughtTokens = totalBoughtTokens.add(b8dAmount);

        emit LogBuy(status, time, sender, b8dAmount, busdCount);
    }

    /** @dev Claim Tokens By Window
     *
     * @param window: current claim window
     * @param buyStatus: user buy status
     * @param windowIndex: window index in array
     * @param sender: user address
     */
    function _claim(
        Window memory window,
        Status buyStatus,
        uint32 windowIndex,
        address sender
    ) internal {
        require(_time() > window.startTime, "_time() should be > window start time");

        if (claimed[sender][buyStatus][windowIndex] || userBuys[sender][buyStatus] == 0) {
            return;
        }

        uint256 percent = window.percent.div(100);
        uint256 reward = userBuys[sender][buyStatus].mul(percent);
        uint256 time = _time();

        claimed[sender][buyStatus][windowIndex] = true;
        b8dToken.transfer(sender, reward);

        emit LogClaim(windowIndex, time, sender, reward);
    }

    /** @dev Collect BUSD to owner
     *
     */
    function _collect() internal {
        require(_time() > 0, "_time() should be > 0");

        uint balance = address(this).balance;

        require(balance > 0, "balance should be > 0");


        payable(owner()).transfer(balance);

        emit LogCollect(balance);
    }

    /** @dev Collect Unsold Tokens to owner
     *
     */
    function _collectUnsoldTokens() internal {
        require(_time() > 0, "_time() should be > 0");

        uint256 unsoldTokens = totalSupply.sub(totalBoughtTokens);

        require(unsoldTokens > 0, "unsoldTokens should be > 0");

        b8dToken.transfer(owner(), unsoldTokens);

        emit LogCollectUnsold(unsoldTokens);
    }

    /** @dev Change Token Sale Status for actual contract
     *
     * @param _status: new Token Sale Status
     */
    function _changeStatus(Status _status) internal {
        status = _status;
    }

    /** @dev Start and Stop actual contract
     *
     */
    function _startStopTokenSale() internal {
        if (tokenSaleRunning) {
            tokenSaleRunning = false;
        } else {
            tokenSaleRunning = true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IB8DexTokenSale {
    /**
     * @notice Buy tokens for the current token sale
     * @dev Callable by users
     */
    function buy() external payable;

    /**
     * @notice Claim free tokens for the current date
     * @dev Callable by users
     */
    function claimAll() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IB8DToken is IERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     */
    function burn(uint256 amount) external;

    /**
     * @dev Multiple translation
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `values`.
     * - arrays of the same length.
     * - arrays no more than a thousand.
     */
    function multiTransfer(address[] memory to, uint[] memory values) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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