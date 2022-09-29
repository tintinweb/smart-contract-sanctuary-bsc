/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

/**
*Submitted for verification at Bsc Testnet
*/

//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.7;

interface IERC20 {

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

abstract contract Context {
function _msgSender() internal view virtual returns (address payable) {
return payable(msg.sender);
}

function _msgData() internal view virtual returns (bytes memory) {
this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
return msg.data;
}
}

contract Ownable is Context {
address private _owner;
address private _previousOwner;
uint256 private _lockTime;

event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

/**
* @dev Initializes the contract setting the deployer as the initial owner.
*/
constructor () {
address msgSender = _msgSender();
_owner = msgSender;
_previousOwner = msgSender;
emit OwnershipTransferred(address(0), msgSender);
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
require(_owner == _msgSender(), "Ownable: caller is not the owner");
_;
}

/**
* @dev Leaves the contract without owner. It will not be possible to call
* `onlyOwner` functions anymore. Can only be called by the current owner.
*
* NOTE: Renouncing ownership will leave the contract without an owner,
* thereby removing any functionality that is only available to the owner.
*/


/**
* @dev Transfers ownership of the contract to a new account (`newOwner`).
* Can only be called by the current owner.
*/

function geUnlockTime() public view returns (uint256) {
return _lockTime;
}

//Locks the contract for owner for the amount of time provided

//Unlocks the contract for owner when _lockTime is exceeds

}

library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a, "SafeMath: addition overflow");

return c;
}

function sub(uint256 a, uint256 b) internal pure returns (uint256) {
return sub(a, b, "SafeMath: subtraction overflow");
}

function sub(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
require(b <= a, errorMessage);
uint256 c = a - b;

return c;
}

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
function div(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
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
function mod(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
require(b != 0, errorMessage);
return a % b;
}
}

/**
* @dev Implementation of the {IERC20} interface.
*
* This implementation is agnostic to the way tokens are created. This means
* that a supply mechanism has to be added in a derived contract using {_mint}.
* For a generic mechanism see {ERC20PresetMinterPauser}.
*
* TIP: For a detailed writeup see our guide
* https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
* to implement supply mechanisms].
*
* We have followed general OpenZeppelin Contracts guidelines: functions revert
* instead returning `false` on failure. This behavior is nonetheless
* conventional and does not conflict with the expectations of ERC20
* applications.
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
contract $AAPcoin is Context, IERC20, Ownable {
using SafeMath for uint256;

string private _name;
string private _symbol;
uint8 private _decimals;
uint256 private _totalSupply;
mapping(address => uint256) private _balances;
mapping(address => mapping(address => uint256)) private _allowances;
mapping(address => bool) private _whitelisted;
mapping(address => bool) public excludedFromTax;
mapping(address => uint256) public deposites;
mapping(address => uint256) public userClaims;
mapping(address => bool) public blacklisted;
uint256 public totalClaims;
string private _hash;


uint256 public taxFee;

/**
* @dev Sets the values for {name}, {symbol} and {decimal}.
* All three of these values are immutable: they can only be set once during
* construction.
*/
constructor() {
_name = "AAPcoin";
_symbol = "AAPC";
_decimals = 18;
taxFee = 10;

excludedFromTax[_msgSender()] = true;
// minting total supply 1 Billion
_mint(_msgSender(), 1 * 10**11* 10 ** _decimals);
}

/**
* @dev Returns the name of the token.
*/
function name() public view virtual returns (string memory) {
return _name;
}

/**
* @dev Returns the symbol of the token, usually a shorter version of the
* name.
*/
function symbol() public view virtual returns (string memory) {
return _symbol;
}

/**
* @dev Returns the number of decimals used to get its user representation.
* For example, if `decimals` equals `2`, a balance of `505` tokens should
* be displayed to a user as `5.05` (`505 / 10 ** 2`).
*
* Tokens usually opt for a value of 18, imitating the relationship between
* Ether and Wei. This is the value {ERC20} uses, unless this function is
* overridden;
*
* NOTE: This information is only used for _display_ purposes: it in
* no way affects any of the arithmetic of the contract, including
* {IERC20-balanceOf} and {IERC20-transfer}.
*/
function decimals() public view virtual returns (uint8) {
return 18;
}

/**
* @dev See {IERC20-totalSupply}.
*/
function totalSupply() public view virtual override returns (uint256) {
return _totalSupply;
}

/**
* @dev See {IERC20-balanceOf}.
*/
function balanceOf(address account) public view virtual override returns (uint256) {
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
function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
_transfer(_msgSender(), recipient, amount);
return true;
}

/**
* @dev See {IERC20-allowance}.
*/
function allowance(address owner, address spender) public view virtual override returns (uint256) {
return _allowances[owner][spender];
}

/**
* @dev See {IERC20-approve}.
*
* Requirements:
*
* - `spender` cannot be the zero address.
*/
function approve(address spender, uint256 amount) public virtual override returns (bool) {
_approve(_msgSender(), spender, amount);
return true;
}

/**
* @dev See {IERC20-transferFrom}.
*
* Emits an {Approval} event indicating the updated allowance. This is not
* required by the EIP. See the note at the beginning of {ERC20}.
*
* Requirements:
*
* - `sender` and `recipient` cannot be the zero address.
* - `sender` must have a balance of at least `amount`.
* - the caller must have allowance for ``sender``'s tokens of at least
* `amount`.
*/
function transferFrom(
address sender,
address recipient,
uint256 amount
) public virtual override returns (bool) {
_transfer(sender, recipient, amount);

uint256 currentAllowance = _allowances[sender][_msgSender()];
require(currentAllowance >= amount, "BYB: transfer amount exceeds allowance");
unchecked {
_approve(sender, _msgSender(), currentAllowance - amount);
}

return true;
}


/**
* @dev Moves `amount` of tokens from `sender` to `recipient`.
*
* This internal function is equivalent to {transfer}, and can be used to
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
function _transfer(
address sender,
address recipient,
uint256 amount
) internal virtual {
require(sender != address(0), "BYB: transfer from the zero address");
require(recipient != address(0), "BYB: transfer to the zero address");

_beforeTokenTransfer(sender, recipient, amount);

if(!excludedFromTax[sender] && !excludedFromTax[recipient]){
require(!blacklisted[_msgSender()], "Wallet is black listed");
uint256 _taxFee = amount.mul(taxFee).div(10**2);
amount = amount.sub(_taxFee);
_burn(sender, _taxFee);
}

uint256 senderBalance = _balances[sender];
require(senderBalance >= amount, "BYB: transfer amount exceeds balance");
unchecked {
_balances[sender] = senderBalance - amount;
}
_balances[recipient] += amount;

emit Transfer(sender, recipient, amount);

_afterTokenTransfer(sender, recipient, amount);
}

/** @dev Creates `amount` tokens and assigns them to `account`, increasing
* the total supply.
*
* Emits a {Transfer} event with `from` set to the zero address.
*
* Requirements:
*
* - `account` cannot be the zero address.
*/
function _mint(address account, uint256 amount) internal virtual {
require(account != address(0), "BYB: mint to the zero address");

_beforeTokenTransfer(address(0), account, amount);

_totalSupply += amount;
_balances[account] += amount;
emit Transfer(address(0), account, amount);

_afterTokenTransfer(address(0), account, amount);
}

/**
* @dev Destroys `amount` tokens from `account`, reducing the
* total supply.
*
* Emits a {Transfer} event with `to` set to the zero address.
*
* Requirements:
*
* - `account` cannot be the zero address.
* - `account` must have at least `amount` tokens.
*/
function _burn(address account, uint256 amount) internal virtual {
require(account != address(0), "BYB: burn from the zero address");

_beforeTokenTransfer(account, address(0), amount);

uint256 accountBalance = _balances[account];
require(accountBalance >= amount, "BYB: burn amount exceeds balance");
unchecked {
_balances[account] = accountBalance - amount;
}
_totalSupply -= amount;

emit Transfer(account, address(0), amount);

_afterTokenTransfer(account, address(0), amount);
}

/**
* @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
*
* This internal function is equivalent to `approve`, and can be used to
* e.g. set automatic allowances for certain subsystems, etc.
*
* Emits an {Approval} event.
*
* Requirements:
*
* - `owner` cannot be the zero address.
* - `spender` cannot be the zero address.
*/
function _approve(
address owner,
address spender,
uint256 amount
) internal virtual {
require(owner != address(0), "BYB: approve from the zero address");
require(spender != address(0), "BYB: approve to the zero address");

_allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}

/**
* @dev Hook that is called before any transfer of tokens. This includes
* minting and burning.
*
* Calling conditions:
*
* - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
* will be transferred to `to`.
* - when `from` is zero, `amount` tokens will be minted for `to`.
* - when `to` is zero, `amount` of ``from``'s tokens will be burned.
* - `from` and `to` are never both zero.
*
* To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
*/
function _beforeTokenTransfer(
address from,
address to,
uint256 amount
) internal virtual {}

/**
* @dev Hook that is called after any transfer of tokens. This includes
* minting and burning.
*
* Calling conditions:
*
* - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
* has been transferred to `to`.
* - when `from` is zero, `amount` tokens have been minted for `to`.
* - when `to` is zero, `amount` of ``from``'s tokens have been burned.
* - `from` and `to` are never both zero.
*
* To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
*/
function _afterTokenTransfer(
address from,
address to,
uint256 amount
) internal virtual {}


}