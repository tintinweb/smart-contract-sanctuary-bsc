/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Pair {
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


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

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

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  function finalTotalSupply() external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function burn(uint256 amount) external returns (bool);


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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
Context */
contract  Context{

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ISNOBPair{
      function getReserves() external view returns(uint256 , uint256 , uint32);
      function deposit(uint256 snobAmount,address to) external;
      function withdraw(address addr,uint256 amount) external;
      function sync() external;
}

contract SNOBPair is ISNOBPair,Ownable{
    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    address public _uniswapV2Pair;

    address private _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public _snobAddress;
    address private _pAddress ;
    address private _repoAddress ;
    address private _robotAddress;

    uint256 private _reserve0;  //usdt
    uint256 private _reserve1;  //snob  
    uint32  private _blockTimestampLast;


    uint256 private _topMultiple = 13;
    uint256 private _repoFee = 10;

    struct UserInfo{
        uint256 _snobAmount;
        uint256 _topValue;
    }
    mapping(address => UserInfo) user;

    constructor(){
        _name = "SNOB_PAIR";
        _symbol = "SNOB_PAIR";
    }

    function setOtherAddress(address snob,address pair,address pAddress,address repoAddress,address robotAddress) public onlyOwner{
        _snobAddress = snob;
        _uniswapV2Pair = pair;
        _pAddress = pAddress;
        _repoAddress = repoAddress;
        _robotAddress = robotAddress;
    }

    function deposit(uint256 snobAmount,address to) public override {
        require(msg.sender == _snobAddress,"refuse");
        

        UserInfo storage userInfo = user[to];
        userInfo._snobAmount = userInfo._snobAmount + snobAmount;


        (uint256 reserve0, uint256 reserve1,) =  IUniswapV2Pair(_uniswapV2Pair).getReserves();

        reserve0 =  IUniswapV2Pair(_uniswapV2Pair).token0() == _usdtAddress ?reserve0 : reserve1;
        uint256 uniswapV2PairUsdt = IBEP20(_usdtAddress).balanceOf(_uniswapV2Pair);
        
        uint256 topValue = (uniswapV2PairUsdt.sub(reserve0)).mul(_topMultiple).div(10);


        userInfo._topValue = userInfo._topValue.add(topValue);

  
    }

    function withdraw(address addr,uint256 amount) public override{
        require(msg.sender == _snobAddress,"refuse");

        UserInfo storage userInfo = user[addr] ;
        if(userInfo._snobAmount <= 0){
          return;
        }
  

        uint256 thisUsdtBalance = IBEP20(_usdtAddress).balanceOf(address(this));
        if(thisUsdtBalance <= 0){
          return;
        }
        if(_reserve0 <= 0 || _reserve1<= 0){
            return;
        }

        if(userInfo._snobAmount < amount){
           amount = userInfo._snobAmount;
        }
        
        uint256 usdtAmount = amount.mul(_reserve0).div(_reserve1);
        if(usdtAmount > userInfo._topValue){
            usdtAmount = userInfo._topValue;
        }

        if( usdtAmount > thisUsdtBalance){
            usdtAmount = thisUsdtBalance;
        }

        uint256 repoFeeAmount = usdtAmount.mul(_repoFee).div(100);
        IBEP20(_usdtAddress).transfer(_repoAddress,repoFeeAmount);
        IBEP20(_usdtAddress).transfer(addr,usdtAmount.sub(repoFeeAmount));
        

        uint256 snobTotalSupply = IBEP20(_snobAddress).totalSupply();
        uint256 finalTotalSupply = IBEP20(_snobAddress).finalTotalSupply();

        if(snobTotalSupply > userInfo._snobAmount.add(finalTotalSupply) ){
            IBEP20(_snobAddress).burn(amount);
        }else if(snobTotalSupply <= finalTotalSupply){
            IBEP20(_snobAddress).transfer(_pAddress , amount);
        }else if( (snobTotalSupply > finalTotalSupply) && snobTotalSupply < amount.add(finalTotalSupply) ){
            uint256 destoryAmount = snobTotalSupply.sub(finalTotalSupply);
            IBEP20(_snobAddress).burn(destoryAmount);
            IBEP20(_snobAddress).transfer(_pAddress , amount.sub(destoryAmount));
        }

        _reserve0 = _reserve0.sub(usdtAmount);
        _reserve1 = _reserve1.sub(amount);


         if(userInfo._topValue - usdtAmount == 0 ||  userInfo._snobAmount - amount == 0){
            userInfo._snobAmount = 0;
            userInfo._topValue = 0 ;
        }else{
            userInfo._snobAmount = userInfo._snobAmount - amount;
            userInfo._topValue = userInfo._topValue - usdtAmount ;
        }
    }

    function precomputeWithdraw() public view returns(uint256){
        UserInfo storage userInfo = user[msg.sender] ;
        if(userInfo._snobAmount == 0){
            return 0;
        }
        uint256 thisUsdtBalance = IBEP20(_usdtAddress).balanceOf(address(this));
        uint256 usdtAmount = userInfo._snobAmount.mul(_reserve0).div(_reserve1);
        if(usdtAmount > userInfo._topValue){
            usdtAmount = userInfo._topValue;
        }

        if( usdtAmount > thisUsdtBalance){
            usdtAmount = thisUsdtBalance;
        }

        return usdtAmount;
    }

    function withdraw() public{

        UserInfo storage userInfo = user[msg.sender] ;
        require(userInfo._snobAmount > 0 ,'Insufficient SNOB');

        uint256 thisUsdtBalance = IBEP20(_usdtAddress).balanceOf(address(this));
        require(thisUsdtBalance > 0 ,'Insufficient USDT');
        
        uint256 usdtAmount = userInfo._snobAmount.mul(_reserve0).div(_reserve1);
        if(usdtAmount > userInfo._topValue){
            usdtAmount = userInfo._topValue;
        }

        if( usdtAmount > thisUsdtBalance){
            usdtAmount = thisUsdtBalance;
        }

        uint256 repoFeeAmount = usdtAmount.mul(_repoFee).div(100);
        IBEP20(_usdtAddress).transfer(_repoAddress,repoFeeAmount);
        IBEP20(_usdtAddress).transfer(msg.sender,usdtAmount.sub(repoFeeAmount));
        
        uint256 snobTotalSupply = IBEP20(_snobAddress).totalSupply();
        uint256 finalTotalSupply = IBEP20(_snobAddress).finalTotalSupply();

        if(snobTotalSupply > userInfo._snobAmount.add(finalTotalSupply) ){
            IBEP20(_snobAddress).burn(userInfo._snobAmount);
        }else if(snobTotalSupply <= finalTotalSupply){
            IBEP20(_snobAddress).transfer(_pAddress , userInfo._snobAmount);
        }else if( (snobTotalSupply > finalTotalSupply) && snobTotalSupply < userInfo._snobAmount.add(finalTotalSupply) ){
            uint256 destoryAmount = snobTotalSupply.sub(finalTotalSupply);
            IBEP20(_snobAddress).burn(destoryAmount);
            IBEP20(_snobAddress).transfer(_pAddress , userInfo._snobAmount.sub(destoryAmount));
        }

        _reserve0 = _reserve0.sub(usdtAmount);
        _reserve1 = _reserve1.sub(userInfo._snobAmount);

        userInfo._snobAmount = 0;
        userInfo._topValue = 0 ;
    }

    

    function getReserves() public view override returns(uint256 , uint256 , uint32) {
        return(_reserve0 , _reserve1 , _blockTimestampLast);
    }

    function getUserInfo(address addr)public view  returns(UserInfo memory){
        return user[addr];
    }

    function sync() override public{
        require(msg.sender == _snobAddress || msg.sender == _robotAddress );
        _reserve0 = IBEP20(_usdtAddress).balanceOf(address(this));
        _reserve1 = IBEP20(_snobAddress).balanceOf(address(this));
        _blockTimestampLast = uint32(block.timestamp % 2**32);
    }

}