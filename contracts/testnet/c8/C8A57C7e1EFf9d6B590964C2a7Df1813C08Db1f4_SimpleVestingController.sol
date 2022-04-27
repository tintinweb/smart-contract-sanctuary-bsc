// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBEP20.sol";

contract SimpleVestingController is Ownable {
    IBEP20 public immutable vestedToken;
    uint public immutable totalAmount;
    uint public immutable tgePercent;
    uint public immutable vestingPeriodDurationSeconds;
    uint public immutable vestingPeriodCount;
    address public whitelisted;
    uint public startTimestamp;
    uint public claimed;

    constructor(
        address _token,
        uint _totalAmount,
        uint _tgePercent,
        uint _vestingPeriodDurationSeconds,
        uint _vestingPeriodCount
    ) {
        vestedToken = IBEP20(_token);
        totalAmount = _totalAmount;
        tgePercent = _tgePercent;
        vestingPeriodDurationSeconds = _vestingPeriodDurationSeconds;
        vestingPeriodCount = _vestingPeriodCount;
    }

    function withdrawAll(address _token) public onlyOwner {
        if (_token == address(vestedToken)) {
            require (_vestedTokenBalance() + claimed > totalAmount, "no tokens available for withdrawal");
            vestedToken.transfer(owner(), _vestedTokenBalance() + claimed - totalAmount);
        } else {
            require(IBEP20(_token).balanceOf(address(this)) > 0, "no tokens available for withdrawal");
            IBEP20(_token).transfer(owner(), IBEP20(_token).balanceOf(address(this)));
        }
    }

    modifier onlyWhitelisted() {
        require(_msgSender() == whitelisted, "caller is not whitelisted");
        _;
    }

    function setWhitelisted(address _whitelisted) public onlyOwner {
        require(whitelisted == address(0), "whitelisted address already set");
        whitelisted = _whitelisted;
    }

    function _vestedTokenBalance() internal view returns (uint) {
        return vestedToken.balanceOf(address(this));
    }

    function _availableAmount() internal view returns (uint) {
        uint tgeAmount = totalAmount * tgePercent / 100;
        uint vestedAmount = totalAmount - tgeAmount;
        uint timeSinceStart = block.timestamp - startTimestamp;
        uint periodsSinceStart = timeSinceStart / vestingPeriodDurationSeconds;
        uint availableVestedAmount = (vestedAmount * periodsSinceStart) / vestingPeriodCount;
        uint availableAmount = availableVestedAmount + tgeAmount - claimed;
        if (availableAmount > totalAmount - claimed) {
            return totalAmount - claimed;
        }
        return availableAmount;
    }

    function claimTokens() public onlyWhitelisted {
        if (startTimestamp == 0) {
            require(_vestedTokenBalance() >= totalAmount, "not enough tokens to activate vesting");
            startTimestamp = block.timestamp;
        }
        uint availableAmount = _availableAmount();
        require(availableAmount > 0, "no more tokens available to claim");
        claimed = claimed + availableAmount;
        vestedToken.transfer(whitelisted, availableAmount);
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

// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

interface IBEP20 {
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
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) external;

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) external;

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