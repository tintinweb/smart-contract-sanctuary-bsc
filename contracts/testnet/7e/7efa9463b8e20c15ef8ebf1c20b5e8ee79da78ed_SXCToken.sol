/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
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
function tryDiv(uint256 a, uint256 b)
internal
pure
returns (bool, uint256)
{
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
function tryMod(uint256 a, uint256 b)
internal
pure
returns (bool, uint256)
{
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
 * Counterpart to Solidity's `%` operator. This function uses a `revert`
 * opcode (which leaves remaining gas untouched) while Solidity uses an
 * invalid opcode to revert (consuming all remaining gas).
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
mapping (address => bool) private _minters;

event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);

/**
 * @dev Initializes the contract setting the deployer as the initial owner.
 */
constructor() {
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
require(
newOwner != address(0),
"Ownable: new owner is the zero address"
);
emit OwnershipTransferred(_owner, newOwner);
_owner = newOwner;
}

function transferERC20Token(address tokenAddress, uint _value) public virtual onlyOwner returns (bool) {
return IERC20TokenInterface(tokenAddress).transfer(_owner, _value);
}

}


interface IERC20TokenInterface {
function name()   external view returns( string memory)  ;
function symbol()   external view returns( string memory)  ;
function totalSupply()   external view returns(uint256)  ;
function decimals()   external view returns(uint256)  ;
function balanceOf(address _owner) view external returns (uint256);
function transfer(address _to, uint256 _value) external returns (bool);
function transferFrom(address _from, address _to, uint256 _value)external returns (bool);
function approve(address _spender, uint256 _value) external returns (bool);
function allowance(address _owner, address _spender) external view returns (uint256);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract FreezableTokenAccount{

struct FreezeBalanceDetail{
    address from; 
    uint256 balance;
    uint256 createTime;
    uint256 unfreezeTime;
    bool flushed;
    uint256 flushTime;
}

mapping (address => FreezeBalanceDetail[])  freezeBalanceDetails;

  function freezeDetailOf(address _owner,uint256 _index) public view returns (address from,uint256 balance,uint256 createTime,uint256 unfreezeTime,bool flushed,uint256 flushTime){
       FreezeBalanceDetail[]  memory details = freezeBalanceDetails[_owner];
       if(details.length>0&&_index<details.length){
           FreezeBalanceDetail memory detail = details[_index];
           return (detail.from,detail.balance,detail.createTime,detail.unfreezeTime,detail.flushed,detail.flushTime);
       }       
  }

function freezeBalanceOf(address _owner)  public  view returns (uint256 freezeBalance) {
    FreezeBalanceDetail[]  memory details = freezeBalanceDetails[_owner];
    for(uint256 i=0;i<details.length;i++){
        FreezeBalanceDetail memory detail = details[i];
        if(!detail.flushed){
             freezeBalance = freezeBalance + detail.balance;
        }
    }
}

function canFlushBalanceOf(address _owner)  public  view returns (uint256 canFlushBalance) {
    FreezeBalanceDetail[]  memory details = freezeBalanceDetails[_owner];
    for(uint256 i = 0; i< details.length; i++){
        FreezeBalanceDetail memory detail = details[i];
        if(block.timestamp > detail.unfreezeTime&&!detail.flushed){
         canFlushBalance = canFlushBalance + detail.balance;
        }
    }
}

}

contract StandardErc20Token is IERC20TokenInterface,Ownable{
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;

string private  _name;
string private  _symbol;
uint256 private  _totalSupply;
uint256 private  _decimals;

constructor(string memory name_,string memory  symbol_,uint256  totalSupply_,uint256  decimals_){
_name=name_;
_symbol=symbol_;
_totalSupply=totalSupply_;
_decimals=decimals_;
}

function name()   external view override returns( string memory)  {
return _name;
}

function symbol()   external view override returns( string memory) {
return _symbol;
}

function decimals()  external view override returns(uint256) {
return _decimals;
}

function totalSupply() external view override returns(uint256){
return _totalSupply ;
}

function transfer(address _to, uint256 _value) external override returns (bool success) {
require(balances[_msgSender()] >= _value,"ERC20: balance is not enough");
bool subOk;
uint256 subResult;
(subOk,subResult) = SafeMath.trySub(balances[_msgSender()] ,_value);
assert(subOk);
balances[_msgSender()] =subResult;

bool addOk;
uint256 addResult;
(addOk,addResult) = SafeMath.tryAdd(balances[_to] ,_value);
assert(addOk);
balances[_to] =addResult;

emit Transfer(msg.sender, _to, _value);
return true;
}

function transferFrom(address _from, address _to, uint256 _value) external override  returns (bool success) {
require (balances[_from] >= _value && allowed[_from][_msgSender()] >= _value,"ERC20: allowed balance is not enough") ;

bool subOk;
uint256 subResult;
(subOk,subResult) = SafeMath.trySub(balances[_from],_value);
assert(subOk);
balances[_from] =subResult;
(subOk,subResult) = SafeMath.trySub(allowed[_from][_msgSender()] ,_value);
assert(subOk);
allowed[_from][_msgSender()] =subResult;

bool addOk;
uint256 addResult;
(addOk,addResult) = SafeMath.tryAdd(balances[_to] ,_value);
assert(addOk);
balances[_to] =addResult;
emit Transfer(_from, _to, _value);
return true;
}

function balanceOf(address _owner) external virtual override  view returns (uint256 balance) {
return balances[_owner] ;
}

function approve(address _spender, uint256 _value) external override  returns (bool success) {
allowed[_msgSender()][_spender] = _value;
emit Approval(_msgSender(), _spender, _value);
return true;
}

function allowance(address _owner, address _spender) external override  view returns (uint256 remaining) {
return allowed[_owner][_spender];
}

}

contract SXCToken is StandardErc20Token , FreezableTokenAccount{
string private  name="Test SquadX Token";
string private  symbol="TSXC";
string private  version="1.0";
uint256 private  decimals=18;
uint256 private totalSupply =10000000 * 10**uint(decimals);

event Flush(address indexed _owner,uint256 _value);
event TransferToFreezeAccount(address indexed _from,address indexed _to,uint256 _value,uint256 _unfreezeTime);

function flush()  external returns (bool sueeccd){
    uint256 totalUnFreezeBalance;
    FreezeBalanceDetail[]  storage details = freezeBalanceDetails[_msgSender()];
     for(uint256 i = 0; i< details.length; i++){
        FreezeBalanceDetail storage detail = details[i];
        if(block.timestamp > detail.unfreezeTime &&!detail.flushed){
         totalUnFreezeBalance = totalUnFreezeBalance + detail.balance;
         detail.flushed = true;
         detail.flushTime = block.timestamp;
        }
    }
    require(totalUnFreezeBalance >0,"SXCToken: freeze balance is not enough");
    balances[_msgSender()] = balances[_msgSender()] +totalUnFreezeBalance;
    emit Flush(_msgSender(),totalUnFreezeBalance);
    return true;
}

 function transferWithFreeze(address _to, uint256 _value,uint256 _unfreezeTime) external returns (bool succeed){
    require(balances[_msgSender()] >= _value,"ERC20: balance is not enough");
    require(_value>0,"ERC20: value must be greater than 0");
    bool subOk;
    uint256 subResult;
    (subOk,subResult) = SafeMath.trySub(balances[_msgSender()] ,_value);
    assert(subOk);
    balances[_msgSender()] =subResult;
    FreezeBalanceDetail memory detail  = FreezeBalanceDetail({
        from:_msgSender(),
        balance:_value,
        createTime:block.timestamp,
        unfreezeTime:_unfreezeTime,
        flushed:false,
        flushTime:0
    });

    freezeBalanceDetails[_to].push(detail);
    emit TransferToFreezeAccount(_msgSender(),_to, _value,_unfreezeTime);
    return true;
 }

function balanceOf(address _owner) external override  view returns (uint256 balance) {
return balances[_owner] + freezeBalanceOf(_owner);
}

constructor(address initAccount) StandardErc20Token(name,symbol,totalSupply,decimals) {
    balances[initAccount] = totalSupply;
}
}