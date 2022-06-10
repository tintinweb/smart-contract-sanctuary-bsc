/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

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
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);
    
    /**
     * @dev Returns the contract owner.
     */
    function symbol() external view returns (string memory);
    
    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
        address msgSender = _msgSender();
        _owner = msgSender;
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

 // pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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


// pragma solidity >=0.5.0;

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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
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



contract MinterToken is Context,Ownable,IERC20 {
    using SafeMath for uint256;

    struct person {
        uint256 id;
        uint256 usdtIn;//usdt amount
        uint256 tokenIn;//hpm amount
        uint256 reward;//一个周期总的回报
        uint256 rate;//利率
        uint256 addtime;
        uint256 unlockedTime;
        uint256 lockdays;
    }
    mapping (address => bool) private _isMinter;

    mapping (address => person[]) public persons;

    mapping (address => uint256) private _balances;

    person[] public all;
    
    IERC20 public ToToken;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public pancakeroute = 0x99B644D02660e260Cb35058936bf764fB5D3E8fC;//
    address public usdt = 0xfd1f468B64a337f210b4CadDc8EcEB706Fd9E762;
    address public wbnb = 0x68CA842e3C0B967DC5c1C10a49Bd0dDF4B900843;
    address public hpm = 0x933E3404CC14fab93b613D2906E0ABCa1c10743a;
    address public rewardWaller;
    
    string private _name = "Minter";
    string private _symbol = "MT";
    uint8 private _decimals = 18;
    uint256 public _totalSupply = 1;
    uint256 public pv1 = 7;
    uint256 public pv2 = 15;
    uint256 public pv3 = 30;
    uint256 public pv4 = 90;
    uint256 public pv5 = 180;
    uint256 public pv6 = 360;

    uint256 public rate1 = 35;
    uint256 public rate2 = 50;
    uint256 public rate3 = 60;
    uint256 public rate4 = 80;
    uint256 public rate5 = 90;
    uint256 public rate6 = 100;

    uint public pv1Num = 3500 * 10**4 * 10**18;
    uint public pv2Num = 3500 * 10**4 * 10**18;
    uint public pv3Num = 3500 * 10**4 * 10**18;
    uint public pv4Num = 3500 * 10**4 * 10**18;
    uint public pv5Num = 3500 * 10**4 * 10**18;
    uint public pv6Num = 3500 * 10**4 * 10**18;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status = _NOT_ENTERED;
    
    event Transfer (
      address indexed from,
      address indexed to,

      uint256 amount
    );
    constructor (
        
    ) public {
        ToToken = IERC20(hpm);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(pancakeroute);
        uniswapV2Router = _uniswapV2Router;
        rewardWaller = address(this);
    }

    //to recieve ETH 
    receive() external payable {}

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function getAmountsIn(uint256 usdtAmount) public view returns(uint256[] memory){
        address[] memory path = new address[](3);
        path[0] = hpm;
        path[1] = wbnb;
        path[2] = usdt;
        return uniswapV2Router.getAmountsIn(usdtAmount,path);
    }

    function getprice(uint256 usdtAmount) public view returns(uint256){
        usdtAmount = usdtAmount * 10 **18;
        uint256[] memory prices = new uint256[](3);
        
        prices = getAmountsIn(usdtAmount);
        uint256 price = prices[0];
        return price;
    }

    /**
    * @dev Returns the bep token owner.
    */
    function getOwner() external override view returns (address) {
      return owner();
    }

    
    function getEth(uint256 amount) public onlyOwner returns (bool){
      address payable ms = payable(owner());
      ms.transfer(amount);
      return true;
    }

    function Minter(uint256 amountUsdt,uint256 day) public returns(bool) {
        address sender = _msgSender();
        
        require(amountUsdt>0,"Amount is too small");
        uint256[] memory price = new uint256[](3);
        price = getAmountsIn(amountUsdt);
        uint256 tokenAmount = price[0];
        IERC20(ToToken).transferFrom(sender,rewardWaller,tokenAmount);
        IERC20(usdt).transferFrom(sender,rewardWaller,amountUsdt);
        if(day==pv1){
            require(pv1Num >= tokenAmount,"sell out");
            pv1Num = pv1Num.sub(tokenAmount);
        }
            
        if(day==pv2){
            require(pv2Num >= tokenAmount,"sell out");
            pv2Num = pv2Num.sub(tokenAmount);
        }
            
        if(day==pv3){
            require(pv3Num >= tokenAmount,"sell out");
            pv3Num = pv3Num.sub(tokenAmount);
        }
            
        if(day==pv4){
            require(pv4Num >= tokenAmount,"sell out");
            pv4Num = pv4Num.sub(tokenAmount);
        }
            
        if(day==pv5){
            require(pv5Num >= tokenAmount,"sell out");
            pv5Num = pv5Num.sub(tokenAmount);
        }
            
        if(day==pv6){
            require(pv6Num >= tokenAmount,"sell out");
            pv6Num = pv6Num.sub(tokenAmount);
        }
            

        uint unlockedTime = block.timestamp + 3600*24*day;
        uint256 interest = reward(amountUsdt,day);
        uint256 rate = getlv(day);
        uint id = persons[sender].length;

        person memory minter_data;
        minter_data.id = id;
        minter_data.lockdays = day;
        minter_data.usdtIn  = amountUsdt;
        minter_data.tokenIn = tokenAmount;
        minter_data.reward = interest;
        minter_data.addtime = block.timestamp;
        minter_data.unlockedTime = unlockedTime;
        minter_data.rate = rate;
        persons[sender].push(minter_data);
        
        all.push(minter_data);
        
        _balances[sender] = _balances[sender].add(interest);
        return true;
    }


    function reward(uint usdtamount,uint day) private  view returns (uint){
        uint256 rate = getlv(day);
        return usdtamount.mul(2).mul(rate).div(365);
        
    }

    
    function getlv(uint256 day) public view returns(uint256) {
        uint rate;
        
        if(day==pv1) rate = rate1;
        if(day==pv2) rate = rate2;
        if(day==pv3) rate = rate3;
        if(day==pv4) rate = rate4;
        if(day==pv5) rate = rate5;
        if(day==pv6) rate = rate6;
        return rate;
    }

    function withdaw(uint id) public nonReentrant {
        address sender = _msgSender();
        uint index = getIndexForId(id);
        uint unlockedTime = persons[sender][index].unlockedTime;
        require(block.timestamp >=unlockedTime,'loclked');
        uint usdtAmount = persons[sender][index].usdtIn;
        uint tokenAmount = persons[sender][index].tokenIn;
        uint interest = persons[sender][index].reward;
        _balances[sender] = _balances[sender].sub(interest);
        interest = interest.add(tokenAmount);
        IERC20(ToToken).transferFrom(address(this),sender,interest);
        IERC20(usdt).transferFrom(address(this),sender,usdtAmount);
        if(persons[sender].length>1)
            persons[sender][index] = persons[sender][persons[sender].length-1];
        persons[sender].pop();

    }

    function getCount(address addr) public view returns(uint){
        return persons[addr].length;
    }

    function getIndexForId(uint id) private view returns(uint){
        uint index;
        address sender = _msgSender();
        uint leng = persons[sender].length-1;
        for(uint i=0;i<leng;i++){
            if(persons[sender][i].id==id){
                index = i;
            }
        }
        return index;
    }

    

    function balanceOfToken(address token) public view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function approveToken (address token,uint256 amount) public onlyOwner returns(bool) {
        IERC20(token).approve(address(this),amount);
        return true;
    }

    function getToken(IERC20 token,address to,uint256 amount) public onlyOwner{
        token.transferFrom(address(this),to,amount);
    }
    function setRewardWaller(address RewardWallter) public onlyOwner{
        rewardWaller = RewardWallter;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to,uint256 amount) public  override returns(bool){}
    
    function allowance(address owner, address spender) public view override returns (uint256) {}
    function approve(address spender, uint256 amount) public override returns (bool) { }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {}

  
}