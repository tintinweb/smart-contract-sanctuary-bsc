pragma solidity 0.5.16;

interface IETF {
  function rebase(uint256 epoch, uint256 supplyDelta, bool positive) external;
  function mint(address to, uint256 amount) external;
  function getPriorBalance(address account, uint blockNumber) external view returns (uint256);
  function mintForReferral(address to, uint256 amount) external;
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function transferForRewards(address to, uint256 value) external returns (bool);
  function transfer(address to, uint256 value) external returns (bool);
}

//SPDX-License-Identifier: Unlicense
pragma solidity 0.5.16;

interface INFTFactory {
    function isHandler(address) external view returns (bool);
    function getHandler(uint256) external view returns (address);
    function alertLevel(uint256, uint256) external;
    function alertSelfTaxClaimed(uint256, uint256) external;
    function alertReferralClaimed(uint256, uint256) external;
    function getTierManager() external view returns(address);
    function getTaxManager() external view returns(address);
    function getRebaser() external view returns(address);
    function getRewarder() external view returns(address);
    function getHandlerForUser(address) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

interface IReferralHandler {
    function checkExistence(uint256, address) external view returns (address);
    function coupledNFT() external view returns (address);
    function referredBy() external view returns (address);
    function ownedBy() external view returns (address);
    function getTier() external view returns (uint256);
    function getTransferLimit() external view returns(uint256);
    function updateReferralTree(uint256 depth, uint256 NFTtier) external;
    function addToReferralTree(uint256 depth, address referred, uint256 NFTtier) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

interface ITaxManager {
    function getSelfTaxPool() external returns (address);
    function getRightUpTaxPool() external view returns (address);
    function getMaintenancePool() external view returns (address);
    function getDevPool() external view returns (address);
    function getRewardAllocationPool() external view returns (address);
    function getPerpetualPool() external view returns (address);
    function getTierPool() external view returns (address);
    function getMarketingPool() external view returns (address);
    function getRevenuePool() external view returns (address);

    function getSelfTaxRate() external returns (uint256);
    function getRightUpTaxRate() external view returns (uint256);
    function getMaintenanceTaxRate() external view returns (uint256);
    function getProtocolTaxRate() external view returns (uint256);
    function getTotalTaxAtMint() external view returns (uint256);
    function getPerpetualPoolTaxRate() external view returns (uint256);
    function getTaxBaseDivisor() external view returns (uint256);
    function getReferralRate(uint256, uint256) external view returns (uint256);
    function getTierPoolRate() external view returns (uint256);
    // function getDevPoolRate() external view returns (uint256);
    function getMarketingTaxRate() external view returns (uint256);
    function getRewardPoolRate() external view returns (uint256);
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.5.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
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

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

pragma solidity ^0.5.0;
import "./ERC20.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

import "./IERC20.sol";
// File: @openzeppelin/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


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
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

pragma solidity ^0.5.0;

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

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

pragma solidity ^0.5.0;
import "../openzeppelin/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
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
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol
import "./SafeMath.sol";
import "./Address.sol";
import "./IERC20.sol";
pragma solidity ^0.5.0;

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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.0;

import "../openzeppelin/Ownable.sol";

interface INotifier {
    function notifyStaked(address user, uint256 amount) external;
    function notifyWithdrawn(address user, uint256 amount) external;
}

contract IPerpRewardDistribution is Ownable {
    INotifier public notifier;
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == address(rewardDistribution), "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }

    function setNotifier(INotifier _notifier)
        external
        onlyOwner
    {
        notifier = _notifier;
    }
}

pragma solidity 0.5.16;
import "../openzeppelin/ERC20.sol";
import "../openzeppelin/ERC20Detailed.sol";
import "../openzeppelin/ERC20Burnable.sol";
import "../openzeppelin/Roles.sol";



contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

contract MintableEscrowToken is ERC20, ERC20Detailed, ERC20Burnable, ERC20Mintable {

    constructor() public
    ERC20Detailed("4.0 Escrow LP", "4.0 ESC", 18)
    {
    }

}

pragma solidity ^0.5.0;

import "../openzeppelin/SafeMath.sol";
import "../openzeppelin/SafeERC20.sol";
import "./PerpetualTokenRewards.sol";
import "../interfaces/ITaxManagerOld.sol";
import "../interfaces/INFTFactoryOld.sol";
import "../interfaces/IReferralHandlerOld.sol";
import "../interfaces/IETF.sol";

contract PerpetualPoolEscrow {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    modifier onlyGov() {
        require(msg.sender == governance, "only governance");
        _;
    }

    address public shareToken;
    address public pool;
    address public token;
    address public factory;
    address public governance;

    event RewardClaimed(address indexed userNFT, uint256 amount, uint256 time);

    constructor(address _shareToken,
        address _pool,
        address _token,
        address _factory) public {
        shareToken = _shareToken;
        pool = _pool;
        token = _token;
        factory = _factory;
        governance = msg.sender;
    }

    function setGovernance(address account) external onlyGov {
        governance = account;
    }

    function setFactory(address account) external onlyGov {
        factory = account;
    }

    function recoverTokens(
        address _token,
        address benefactor
    ) public onlyGov {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(benefactor, tokenBalance);
    }

    function release(address recipient, uint256 shareAmount) external {
        require(msg.sender == pool, "only pool can release tokens");
        IERC20(shareToken).safeTransferFrom(msg.sender, address(this), shareAmount);
        uint256 reward = getTokenNumber(shareAmount);
        ITaxManager taxManager = ITaxManager(INFTFactory(factory).getTaxManager());
        uint256 protocolTaxRate = taxManager.getProtocolTaxRate();
        uint256 taxDivisor = taxManager.getTaxBaseDivisor();
        distributeTaxAndReward(recipient, reward, protocolTaxRate, taxDivisor);
        IERC20Burnable(shareToken).burn(shareAmount);
    }

    function getTokenNumber(uint256 shareAmount) public view returns(uint256) {
        return IETF(token).balanceOf(address(this))
            .mul(shareAmount)
            .div(IERC20(shareToken).totalSupply());
    }

    /**
    * Functionality for secondary pool escrow. Transfers Rebasing tokens from msg.sender to this
    * escrow. It adds equal amount of escrow share token to the staking pool and notifies it to
    * extend reward period.
    */
    function notifySecondaryTokens(uint256 amount) external {
        IETF(token).transferFrom(msg.sender, address(this), amount);
        IERC20Mintable(shareToken).mint(pool, amount);
        PerpetualTokenRewards(pool).notifyRewardAmount(amount);
    }

    function distributeTaxAndReward(address owner, uint256 currentClaimable, uint256 protocolTaxRate, uint256 taxDivisor) internal {
        ITaxManager taxManager = ITaxManager(INFTFactory(factory).getTaxManager());
        uint256 leftOverTaxRate = protocolTaxRate;
        address handler = INFTFactory(factory).getHandlerForUser(owner);
        address [5] memory referral; // Used to store above referrals, saving variable space
        // User Distribution
        // Block Scoping to reduce local Variables spillage
        {
        uint256 taxedAmount = currentClaimable.mul(protocolTaxRate).div(taxDivisor);
        uint256 userReward = currentClaimable.sub(taxedAmount);
        IETF(token).transferForRewards(owner, userReward);
        emit RewardClaimed(owner, userReward, block.timestamp);
        }
        {
        uint256 perpetualTaxRate = taxManager.getPerpetualPoolTaxRate();
        uint256 perpetualAmount = currentClaimable.mul(perpetualTaxRate).div(taxDivisor);
        leftOverTaxRate = leftOverTaxRate.sub(perpetualTaxRate);
        address perpetualPool = taxManager.getPerpetualPool();
        IERC20(token).safeApprove(perpetualPool, 0);
        IERC20(token).safeApprove(perpetualPool, perpetualAmount);
        PerpetualPoolEscrow(perpetualPool).notifySecondaryTokens(perpetualAmount);
        }
        // Block Scoping to reduce local Variables spillage
        {
        uint256 protocolMaintenanceRate = taxManager.getMaintenanceTaxRate();
        uint256 protocolMaintenanceAmount = currentClaimable.mul(protocolMaintenanceRate).div(taxDivisor);
        address maintenancePool = taxManager.getMaintenancePool();
        IETF(token).transferForRewards(maintenancePool, protocolMaintenanceAmount);
        leftOverTaxRate = leftOverTaxRate.sub(protocolMaintenanceRate); // Minted above
        }
        // Transfer taxes to referrers
        if(handler != address(0))
        {
            referral[1]  = IReferralHandler(handler).referredBy();
            if(referral[1] != address(0)) {
                // Block Scoping to reduce local Variables spillage
                {
                // Rightup Reward
                uint256 rightUpRate = taxManager.getRightUpTaxRate();
                uint256 rightUpAmount = currentClaimable.mul(rightUpRate).div(taxDivisor);
                IETF(token).transferForRewards(referral[1], rightUpAmount);
                leftOverTaxRate = leftOverTaxRate.sub(rightUpRate);
                // Normal Referral Reward
                uint256 firstTier = IReferralHandler(referral[1]).getTier();
                uint256 firstRewardRate = taxManager.getReferralRate(1, firstTier);
                leftOverTaxRate = leftOverTaxRate.sub(firstRewardRate);
                uint256 firstReward = currentClaimable.mul(firstRewardRate).div(taxDivisor);
                IETF(token).transferForRewards(referral[1], firstReward);
                }
                referral[2] = IReferralHandler(referral[1]).referredBy();
                if(referral[2] != address(0)) {
                    // Block Scoping to reduce local Variables spillage
                    {
                    uint256 secondTier = IReferralHandler(referral[2]).getTier();
                    uint256 secondRewardRate = taxManager.getReferralRate(2, secondTier);
                    leftOverTaxRate = leftOverTaxRate.sub(secondRewardRate);
                    uint256 secondReward = currentClaimable.mul(secondRewardRate).div(taxDivisor);
                    IETF(token).transferForRewards(referral[2], secondReward);
                    }
                    referral[3] = IReferralHandler(referral[2]).referredBy();
                    if(referral[3] != address(0)) {
                    // Block Scoping to reduce local Variables spillage
                        {
                        uint256 thirdTier = IReferralHandler(referral[3]).getTier();
                        uint256 thirdRewardRate = taxManager.getReferralRate(3, thirdTier);
                        leftOverTaxRate = leftOverTaxRate.sub(thirdRewardRate);
                        uint256 thirdReward = currentClaimable.mul(thirdRewardRate).div(taxDivisor);
                        IETF(token).transferForRewards(referral[3], thirdReward);
                        }
                        referral[4] = IReferralHandler(referral[3]).referredBy();
                        if(referral[4] != address(0)) {
                            // Block Scoping to reduce local Variables spillage
                            {
                            uint256 fourthTier = IReferralHandler(referral[4]).getTier();
                            uint256 fourthRewardRate = taxManager.getReferralRate(4, fourthTier);
                            leftOverTaxRate = leftOverTaxRate.sub(fourthRewardRate);
                            uint256 fourthReward = currentClaimable.mul(fourthRewardRate).div(taxDivisor);
                            IETF(token).transferForRewards(referral[4], fourthReward);
                            }
                        }
                    }
                }
            }
        }
        // Reward Allocation
        {
        uint256 rewardTaxRate = taxManager.getRewardPoolRate();
        uint256 rewardPoolAmount = currentClaimable.mul(rewardTaxRate).div(taxDivisor);
        address rewardPool = taxManager.getRewardAllocationPool();
        IETF(token).transferForRewards(rewardPool, rewardPoolAmount);
        leftOverTaxRate = leftOverTaxRate.sub(rewardTaxRate);
        }
        // Dev Allocation & // Revenue Allocation
        {
        uint256 leftOverTax = currentClaimable.mul(leftOverTaxRate).div(taxDivisor);
        address devPool = taxManager.getDevPool();
        address revenuePool = taxManager.getRevenuePool();
        IETF(token).transferForRewards(devPool, leftOverTax.div(2));
        IETF(token).transferForRewards(revenuePool, leftOverTax.div(2));
        }
    }
}


interface IERC20Burnable {
    function burn(uint256 amount) external;
}

interface IERC20Mintable {
    function mint(address to, uint256 amount) external;
}

pragma solidity ^0.5.0;

import "../openzeppelin/Math.sol";
import "./IPerpRewardDistribution.sol";
import "../staking/LPTokenWrapper.sol";
import "./PerpetualPoolEscrow.sol";
import "../staking/StakingWhitelist.sol";

contract PerpetualTokenRewards is LPTokenWrapper, IPerpRewardDistribution, StakingWhitelistable {
    IERC20 public snx;
    uint256 public constant DURATION = 14 days;

    address public escrow;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    bool public onlyWhitelisted = true;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier checkWhitelistStatus(address account) {
        require(isWhitelisted(account) == true || onlyWhitelisted == false, "Currently only Whitelisted Addresses can stake");
        _;
    }

    constructor (address _token, address _lp) LPTokenWrapper(_lp) public {
      snx = IERC20(_token);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    // returns the earned amount as it will be paid out by the escrow (accounting for rebases)
    function earnedTokens(address account) public view returns (uint256) {
        return PerpetualPoolEscrow(escrow).getTokenNumber(
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account])
        );
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    // Duration here is in days
    function stake(uint256 amount, uint256 duration) public updateReward(msg.sender) checkWhitelistStatus(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount, duration);
        emit Staked(msg.sender, amount);
        notifier.notifyStaked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
        notifier.notifyWithdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            // the pool is distributing placeholder tokens with fixed supply
            snx.safeApprove(escrow, 0);
            snx.safeApprove(escrow, reward);
            PerpetualPoolEscrow(escrow).release(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {
        // overflow fix https://sips.synthetix.io/sips/sip-77
        require(reward < uint256(-1) / 1e18, "amount too high");

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }

    function setEscrow(address newEscrow) external onlyOwner {
        require(escrow == address(0), "escrow already set");
        escrow = newEscrow;
    }

    function setStatus(bool status) external onlyOwner {
        onlyWhitelisted = status;
    }
    function whitelistAddress(address target) external onlyOwner {
        _whitelistAccount(target);
    }

    function delistAddress(address target) external onlyOwner {
        _delistAccount(target);
    }

    function recoverTokens(
        address _token,
        address benefactor
    ) public onlyOwner {
        require(_token != address(uni), "Cannot transfer LP tokens");
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(benefactor, tokenBalance);
    }
}

import "./MintableEscrowToken.sol";
import "./PerpetualTokenRewards.sol";

pragma solidity 0.5.16;

contract PerpStakingFactory {

    address public token;
    address public nftFactory;
    INotifier public notifier;
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    address[] pools;

    constructor(address _token, INotifier _notifier, address _nftFactory) public {
        token = _token;
        nftFactory = _nftFactory;
        notifier = _notifier;
        owner = msg.sender;
    }

    function setOwner(address account) public onlyOwner {
        owner = account;
    }

    function initialize (address lp) public onlyOwner {
        address escrowToken = address(new MintableEscrowToken());
        address stakingPool = address(new PerpetualTokenRewards(escrowToken, lp));
        pools.push(stakingPool);
        address poolEscrow = address(new PerpetualPoolEscrow(escrowToken, stakingPool, token, nftFactory));
        IEscrowToken(escrowToken).addMinter(poolEscrow);
        PerpetualTokenRewards(stakingPool).setEscrow(poolEscrow);
        PerpetualTokenRewards(stakingPool).setRewardDistribution(poolEscrow);
        PerpetualTokenRewards(stakingPool).setNotifier(notifier);
        PerpetualTokenRewards(stakingPool).transferOwnership(owner);
        PerpetualPoolEscrow(poolEscrow).setGovernance(owner);
    }

    function getPools() public view returns(address[] memory) {
        return pools;
    }

    // function recoverTokens(
    //     address _token,
    //     address benefactor
    // ) public onlyOwner {
    //     uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
    //     IERC20(_token).transfer(benefactor, tokenBalance);
    // }

}

interface IEscrowToken {
        function addMinter(address account) external;
}

pragma solidity ^0.5.0;

import "../openzeppelin/SafeMath.sol";
import "../openzeppelin/SafeERC20.sol";

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public uni;

    constructor (address _uni) public {
        uni = IERC20(_uni);
    }

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _unlockTime;
    mapping(address => uint256) private _lastLockDuration; // This is stored in days not seconds


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function unlocksAt(address account) public view returns (uint256) {
        return _unlockTime[account];
    }

    function latestLockDuration(address account) public view returns (uint256) {
        return _lastLockDuration[account];
    }

    function stake(uint256 amount, uint256 duration) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        // Incase user has no locked up tokens
        if(_unlockTime[msg.sender] <= block.timestamp) {
            _lastLockDuration[msg.sender] = duration;
        // Incase user currently has tokens locked up
        } else {
            if(_lastLockDuration[msg.sender] < duration)
                _lastLockDuration[msg.sender] = duration; // If the lock duration previously was lower, allow to lock duration to be increased, lock duration cannot be reduced.
        }
        uint256 durationInSeconds = _lastLockDuration[msg.sender].mul(1 days);
        _unlockTime[msg.sender] = block.timestamp.add(durationInSeconds); // The duration for lock resets each time user stakes
        uni.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        require(_unlockTime[msg.sender] <= block.timestamp, "Cannot unlock tokens yet");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        uni.safeTransfer(msg.sender, amount);
    }
}

pragma solidity ^0.5.0;
// File: Modifier from : @openzeppelin/contracts/access/roles/MinterRole.sol

import "../openzeppelin/Roles.sol";

contract StakingWhitelistable {
  using Roles for Roles.Role;

  event AddressWhitelisted(address indexed account);
  event AddressDelisted(address indexed account);

  Roles.Role private _whitelist;

  modifier checkWhitelist(address account) {
    require(isWhitelisted(account), "Whitelistable: Account is not whitelisted");
    _;
  }

  function isWhitelisted(address account) public view returns (bool) {
    return _whitelist.has(account);
  }

  function _whitelistAccount(address account) internal {
    _whitelist.add(account);
    emit AddressWhitelisted(account);
  }

  function _delistAccount(address account) internal {
    _whitelist.remove(account);
    emit AddressDelisted(account);
  }
}