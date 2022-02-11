// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./utils/SafeMath.sol";
import "./IBEP20.sol";
import './utils/AdminRole.sol';
import "./utils/Ownable.sol";

contract GLXP is Context, AdminRole {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    address payable _glxContractAddress;

    struct LockInfo {
        uint256 amountUnlock;
        uint256 swapped;
        uint256 timestampLock;
        bool lockedByAdmin;
        bool unlockManual;
    }
    mapping(address => LockInfo) _addressLockInfo;
    uint256 _SWAP_DATE = 1612340544;
    uint256 _TIME_ONE_MONTH = 2629743;
    uint256 _TIME_ONE_WEEK = 604800;

    event BalanceUnlocked(address indexed from, address indexed addressUnlocked);
    event GLXPSwapped(address indexed from, uint256 amount);

    constructor(string memory name_, string memory symbol_, uint256 decimals_, address payable glxContractAddress_){
        _name = name_;
        _symbol = symbol_;
        _decimals = uint8(decimals_);
        _glxContractAddress = glxContractAddress_;
    }

    function changeTokenContract(
        address payable tokenContract_
    )
    public
    onlyAdmin
    returns (bool)
    {
        _glxContractAddress = tokenContract_;
        return true;
    }

    /**
    * @dev Returns the token name.
    */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Return GLX balance locked in contract GLXP
     */
    function getGLXLockedInContract() public view returns (uint256) {
        return IBEP20(_glxContractAddress).balanceOf(address(this));
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
    * @dev Send quantity of `amount_` in balance address `to_`
    * Set rate unlock to 10% and unlock the token after 2629743 blocks than block transaction ( 6 month )
    *
    * Emit `Transfer`
    *
    * Requirements
    * - Caller **MUST** is an admin
    * - User have not already token locked, `balanceOf` == 0
    * - Balance locked in contract **MUST** be > to `amount_`
    */
    function deliverToAccountWithRate10(address to_, uint256 amount_) public onlyAdmin returns (bool) {
        require(_balances[to_] == 0, "GLXP: user have already token locked");

        uint256 tokenLocked = getGLXLockedInContract();
        require((tokenLocked - _totalSupply + 1) > amount_, "GLXP: Balance enough of token locked");

        _balances[to_] += amount_;
        _totalSupply += amount_;

        LockInfo memory lockInfoAddress;
        lockInfoAddress.amountUnlock = amount_.div(10);
        lockInfoAddress.timestampLock = _SWAP_DATE + _TIME_ONE_MONTH;
        lockInfoAddress.lockedByAdmin = false;
        lockInfoAddress.unlockManual = false;
        lockInfoAddress.swapped = 0;

        _addressLockInfo[to_] = lockInfoAddress;

        emit Transfer(_msgSender(), to_, amount_);
        return true;
    }



    /**
    * @dev Send quantity of `amount_` in balance address `to_`
    * This transfer **MUST** be unlock by admin by `unlockSwap` call
    *
    * Emit `Transfer`
    *
    * Requirements
    * - Caller **MUST** is an admin
    * - User have not already token locked, `balanceOf` == 0
    * - Balance locked in contract **MUST** be > to `amount_`
    */
    function deliverToAccountManual(address to_, uint256 amount_) public onlyAdmin returns (bool) {
        require(_balances[to_] == 0, "GLXP: user have already token locked");

        uint256 tokenLocked = getGLXLockedInContract();
        require((tokenLocked - _totalSupply + 1) > amount_, "GLXP: Balance enough of token locked");

        _balances[to_] += amount_;
        _totalSupply += amount_;

        LockInfo memory lockInfoAddress;
        lockInfoAddress.amountUnlock = amount_;
        lockInfoAddress.timestampLock = 0;
        lockInfoAddress.lockedByAdmin = true;
        lockInfoAddress.unlockManual = true;
        lockInfoAddress.swapped = 0;


        _addressLockInfo[to_] = lockInfoAddress;

        emit Transfer(_msgSender(), to_, amount_);
        return true;
    }

    /**
    * @dev Returns info of lock token by `owner_` address
    * order of return `amountUnlock`, `timestampUnlock`, `lockedByAdmin`, `unlockManual`
    */
    function getInfoLockedByAddress(address owner_) public view returns(uint256, uint256, bool, bool) {
        uint256 amountUnlock = _addressLockInfo[owner_].amountUnlock;
        uint256 timestampUnlock = _addressLockInfo[owner_].timestampLock;
        bool lockedByAdmin = _addressLockInfo[owner_].lockedByAdmin;
        bool unlockManual = _addressLockInfo[owner_].unlockManual;

        return (amountUnlock, timestampUnlock, lockedByAdmin, unlockManual);
    }

    /**
    * @dev Returns how much token are unlocked by `owner_`
    */
    function getTokenUnlock(address owner_) public view returns(uint256) {
        LockInfo memory lockInfoAddress = _addressLockInfo[owner_];

        if (lockInfoAddress.lockedByAdmin) {
            return 0;
        }
        if (lockInfoAddress.unlockManual) {
            return lockInfoAddress.amountUnlock;
        }

        if (block.timestamp < lockInfoAddress.timestampLock) {
            return 0;
        }
        uint256 rate = (block.timestamp - lockInfoAddress.timestampLock) / _TIME_ONE_WEEK;
        if (rate == 0) {
            return 0;
        }
        if (((lockInfoAddress.amountUnlock * rate) - lockInfoAddress.swapped) > _balances[owner_]) {
            return _balances[owner_];
        }
        return (lockInfoAddress.amountUnlock * rate) - lockInfoAddress.swapped;
    }

    /**
    * @dev Unlock manual swap for `unlockAddress_`
    *
    * Emit `BalanceUnlocked`
    *
    * Requirements:
    * - Swap **MUST** be locked by admin to can unlock it
    */
    function unlockSwap(address unlockAddress_) public onlyAdmin returns(bool) {
        require(_addressLockInfo[unlockAddress_].lockedByAdmin, "GLXP: Address amount is not locked by admin");

        _addressLockInfo[unlockAddress_].lockedByAdmin = false;
        emit BalanceUnlocked(_msgSender(), unlockAddress_);
        return true;
    }

    /**
    * @dev Swap GLXP unlock in caller address to GLX caller address
    *
    * Emit `GLXPSwapped`
    *
    * Requirements
    * - Token **MUST** be unlocked
    */
    function swapGLXPtoGLX() public returns(bool) {
        require(_balances[_msgSender()] > 0, "GLXP: balance of sender is 0");

        LockInfo memory lockInfoAddress = _addressLockInfo[_msgSender()];
        require(block.timestamp > lockInfoAddress.timestampLock, "GLXP: token is already locked");
        require(!lockInfoAddress.lockedByAdmin, "GLXP: swap is already locked by admin");
        uint256 tokenToUnlock = getTokenUnlock(_msgSender());

        IBEP20(_glxContractAddress).transfer(_msgSender(), tokenToUnlock);

        _addressLockInfo[_msgSender()].swapped = _addressLockInfo[_msgSender()].swapped + tokenToUnlock;
        _totalSupply = _totalSupply - tokenToUnlock;
        _balances[_msgSender()] = _balances[_msgSender()] - tokenToUnlock;

        emit GLXPSwapped(_msgSender(), tokenToUnlock);

        return true;
    }


}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.4;

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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.4;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.4;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.4;

import "../utils/Context.sol";
import "./Ownable.sol";
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
abstract contract AdminRole is Ownable {

    mapping(address => bool) _adminAddress;
    modifier onlyAdmin() {
        require(_adminAddress[_msgSender()] == true , "GLXM: caller is not a admin");
        _;
    }
    event AdminSet(address indexed from, address indexed newAdmin, bool action);

    /**
     * @dev Initializes the contract setting the deployer as a admin.
     */
    constructor () {
        _adminAddress[_msgSender()] = true;
    }

    /**
   * @dev Add to list of admin `newAdmin_` address
   *
   * Emits an {AddedAdmin} event
   *
   * Requirements:
   * - Caller **MUST** is an admin
   * - `newAdmin_` address **MUST** is not an admin
   */
    function addAdmin(address newAdmin_) public onlyAdmin returns (bool){
        require(_adminAddress[newAdmin_] == false, "GLXM: Address is already admin");
        _adminAddress[newAdmin_] = true;

        emit AdminSet(_msgSender(), newAdmin_, true);
        return true;
    }

    /**
    * @dev Remove to list of admin `newAdmin_` address
    *
    * Emits an {AddedAdmin} event
    *
    * Requirements:
    * - Caller **MUST** is an admin
    * - newAdmin_ address **MUST** is an admin
    */
    function removeAdmin(address adminToRemove_) public onlyAdmin returns (bool){
        require(_adminAddress[_msgSender()] == true, "GLXM: Address is not a admin");
        _adminAddress[adminToRemove_] = false;

        emit AdminSet(_msgSender(), adminToRemove_, false);
        return true;
    }

    /**
    * @dev Return if `adminAddress_` is admin
    */
    function checkIfAdmin(address adminAddress_) public view returns(bool) {
        return _adminAddress[adminAddress_];
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.4;

interface IBEP20 {

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
    * @dev Returns the token symbol.
    */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token decimals.
    */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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