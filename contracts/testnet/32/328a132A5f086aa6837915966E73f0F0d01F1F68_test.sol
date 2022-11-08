/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
function totalSupply() external view returns (uint256);

function balanceOf(address who) external view returns (uint256);

function allowance(address owner, address spender)
external
view
returns (uint256);

function transfer(address to, uint256 value) external returns (bool);

function approve(address spender, uint256 value) external returns (bool);

function transferFrom(
address from,
address to,
uint256 value
) external returns (bool);

event Transfer(address indexed from, address indexed to, uint256 value);

event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}

abstract contract ERC20Detailed is IERC20
{
string private _name;
string private _symbol;
uint8 private _decimals;

constructor(
string memory name_,
string memory symbol_,
uint8 decimals_
) {
_name = name_;
_symbol = symbol_;
_decimals = decimals_;
}

function name() public view returns (string memory) {
return _name;
}

function symbol() public view returns (string memory) {
return _symbol;
}

function decimals() public view returns (uint8) {
return _decimals;
}
}

abstract contract Context {
function _msgSender() internal view virtual returns (address) {
return msg.sender;
}

function _msgData() internal view virtual returns (bytes calldata) {
return msg.data;
}
}

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

contract test is Ownable, ERC20Detailed {
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public override allowance;
mapping(address => mapping(address => uint256)) private _allowedFragments;
mapping(address => bool) _isFeeExempt;

string public _name = "test";
string public _symbol = "BNB";
uint8 public _decimals = 7;
uint256 public totalSupply = 3 * 10 ** 7;

constructor() ERC20Detailed(_name, _symbol, _decimals) Ownable() {
balances[msg.sender] = totalSupply;

_isFeeExempt[msg.sender] = true;
_isFeeExempt[address(this)] = true;

_transferOwnership(msg.sender);
emit Transfer(address(0x0), msg.sender, totalSupply);
}

function balanceOf(address owner) public override view returns (uint) {
return balances[owner];
}

function transfer(address to, uint value) public override returns (bool) {
require(balanceOf(msg.sender) >= value, 'balance too low');
balances[to] += value;
balances[msg.sender] -= value;
emit Transfer(msg.sender, to, value);
return true;
}

function transferFrom(address from, address to, uint value) public override returns (bool) {
require(balanceOf(from) >= value, 'balance too low');
require(allowance[from][msg.sender] >= value, 'allowance too low');
balances[to] += value;
balances[from] -= value;
emit Transfer(from, to, value);
return true;
}

function approve(address spender, uint value) public override returns (bool) {
allowance[msg.sender][spender] = value;
emit Approval(msg.sender, spender, value);
return true;
}
}

// 67839a09-2003-3306-9fa3-9d6b88a1bfe1