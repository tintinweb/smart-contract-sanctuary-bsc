/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IPancakeSwapPair {
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

function initialize(address, address) external;
}

interface IPancakeSwapRouter {
function factory() external pure returns (address);

function WETH() external pure returns (address);

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

function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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

interface IPancakeSwapFactory {
event PairCreated(address indexed token0, address indexed token1, address pair, uint);

function feeTo() external view returns (address);

function feeToSetter() external view returns (address);

function getPair(address tokenA, address tokenB) external view returns (address pair);

function allPairs(uint) external view returns (address pair);

function allPairsLength() external view returns (uint);

function createPair(address tokenA, address tokenB) external returns (address pair);

function setFeeTo(address) external;

function setFeeToSetter(address) external;
}

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

contract BrianMusk is Ownable, ERC20Detailed {
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public override allowance;
mapping(address => mapping(address => uint256)) private _allowedFragments;
mapping(address => bool) _isFeeExempt;

IPancakeSwapRouter public pancakeSwapTestRouter;
IPancakeSwapPair public pairContract;
address public pair;
address public pairAddress;

string public _name = "BrianMusk";
string public _symbol = "BMSK";
uint8 public _decimals = 2;
uint256 public totalSupply = 10000000 ** 2;

address treasuryReceiver = 0x9433a5c4798aD0051C24EE7c7ecBfff0a3239F02;

constructor() ERC20Detailed(_name, _symbol, _decimals) Ownable() {
pancakeSwapTestRouter = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
pair = IPancakeSwapFactory(pancakeSwapTestRouter.factory()).createPair(
pancakeSwapTestRouter.WETH(),
address(this)
);
balances[msg.sender] = totalSupply;

_allowedFragments[address(this)][address(pancakeSwapTestRouter)] = type(uint256).max;
pairAddress = pair;
pairContract = IPancakeSwapPair(pair);

_isFeeExempt[treasuryReceiver] = true;
_isFeeExempt[address(this)] = true;

_transferOwnership(treasuryReceiver);
emit Transfer(address(0x0), treasuryReceiver, totalSupply);
}

function balanceOf(address owner) public override  view returns (uint) {
return balances[owner];
}

function transfer(address to, uint value) public override  returns (bool) {
require(balanceOf(msg.sender) >= value, 'balance too low');
balances[to] += value;
balances[msg.sender] -= value;
emit Transfer(msg.sender, to, value);
return true;
}

function transferFrom(address from, address to, uint value) public override  returns (bool) {
require(balanceOf(from) >= value, 'balance too low');
require(allowance[from][msg.sender] >= value, 'allowance too low');
balances[to] += value;
balances[from] -= value;
emit Transfer(from, to, value);
return true;
}

function approve(address spender, uint value) public override  returns (bool) {
allowance[msg.sender][spender] = value;
emit Approval(msg.sender, spender, value);
return true;
}
}

// 1adc90e8-1139-37a1-979c-61a5c608e046